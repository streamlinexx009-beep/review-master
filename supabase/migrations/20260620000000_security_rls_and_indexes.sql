-- ReviewMaster Supabase security hardening migration
-- Date: 2026-06-20
-- Purpose:
--   1. Enable Row Level Security on public application tables.
--   2. Add baseline role/user policies for students, instructors, and admins.
--   3. Harden SECURITY DEFINER functions by fixing search_path and revoking public RPC execution.
--   4. Add indexes for foreign keys flagged by Supabase performance advisors.
--
-- IMPORTANT:
-- Review against your frontend before applying directly to production.
-- Question tables contain correct_answer columns. RLS cannot hide individual columns;
-- use views/RPCs that omit answers during active exams/quizzes if students should not see them.

begin;

-- -----------------------------------------------------------------------------
-- Helper functions for RLS policies
-- -----------------------------------------------------------------------------

create or replace function public.current_user_role()
returns text
language sql
stable
security definer
set search_path = public, auth
as $$
  select p.role
  from public.profiles p
  where p.id = auth.uid()
  limit 1
$$;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public, auth
as $$
  select coalesce(public.current_user_role() = 'admin', false)
$$;

create or replace function public.is_instructor_or_admin()
returns boolean
language sql
stable
security definer
set search_path = public, auth
as $$
  select coalesce(public.current_user_role() in ('admin', 'instructor'), false)
$$;

revoke all on function public.current_user_role() from public;
revoke all on function public.is_admin() from public;
revoke all on function public.is_instructor_or_admin() from public;
grant execute on function public.current_user_role() to authenticated;
grant execute on function public.is_admin() to authenticated;
grant execute on function public.is_instructor_or_admin() to authenticated;

-- Harden existing functions without assuming their signatures.
do $$
declare
  r record;
begin
  for r in
    select p.oid::regprocedure::text as fn, p.proname
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname in ('handle_new_user', 'calculate_topic_mastery')
  loop
    execute format('alter function %s set search_path = public, auth', r.fn);

    if r.proname = 'handle_new_user' then
      execute format('revoke execute on function %s from anon, authenticated', r.fn);
    end if;
  end loop;
end $$;

-- -----------------------------------------------------------------------------
-- Enable RLS on all exposed application tables
-- -----------------------------------------------------------------------------

do $$
declare
  t text;
begin
  foreach t in array array[
    'profiles','subjects','topics','materials','bookmarks','notes','quizzes','quiz_questions',
    'quiz_attempts','flashcards','flashcard_favorites','study_plans','study_tasks','exams',
    'exam_questions','exam_attempts','exam_attempt_answers','achievements','student_achievements',
    'student_points','study_streaks','notifications','batches','batch_students','batch_subjects',
    'learning_contents','topic_flashcards','topic_quiz_questions','topic_exams','topic_exam_questions',
    'topic_summaries','topic_progress','flashcard_reviews','topic_mastery','topic_exam_attempts',
    'topic_exam_attempt_answers','practice_attempts','practice_questions'
  ] loop
    execute format('alter table public.%I enable row level security', t);
  end loop;
end $$;

-- -----------------------------------------------------------------------------
-- Profiles
-- -----------------------------------------------------------------------------

drop policy if exists review_master_profiles_select on public.profiles;
create policy review_master_profiles_select
on public.profiles for select to authenticated
using (id = (select auth.uid()) or public.is_instructor_or_admin());

drop policy if exists review_master_profiles_insert on public.profiles;
create policy review_master_profiles_insert
on public.profiles for insert to authenticated
with check (id = (select auth.uid()) or public.is_admin());

drop policy if exists review_master_profiles_update on public.profiles;
create policy review_master_profiles_update
on public.profiles for update to authenticated
using (id = (select auth.uid()) or public.is_admin())
with check (id = (select auth.uid()) or public.is_admin());

-- -----------------------------------------------------------------------------
-- Shared learning catalog: signed-in read, staff write
-- -----------------------------------------------------------------------------

do $$
declare
  t text;
begin
  foreach t in array array[
    'subjects','topics','learning_contents','topic_summaries','topic_flashcards','achievements'
  ] loop
    execute format('drop policy if exists review_master_authenticated_read on public.%I', t);
    execute format('create policy review_master_authenticated_read on public.%I for select to authenticated using (true)', t);

    execute format('drop policy if exists review_master_staff_write on public.%I', t);
    execute format(
      'create policy review_master_staff_write on public.%I for all to authenticated using (public.is_instructor_or_admin()) with check (public.is_instructor_or_admin())',
      t
    );
  end loop;
end $$;

-- Materials: signed-in users can read; uploader or staff can manage.
drop policy if exists review_master_materials_select on public.materials;
create policy review_master_materials_select on public.materials
for select to authenticated using (true);

drop policy if exists review_master_materials_insert on public.materials;
create policy review_master_materials_insert on public.materials
for insert to authenticated
with check (uploaded_by = (select auth.uid()) or public.is_instructor_or_admin());

drop policy if exists review_master_materials_update on public.materials;
create policy review_master_materials_update on public.materials
for update to authenticated
using (uploaded_by = (select auth.uid()) or public.is_instructor_or_admin())
with check (uploaded_by = (select auth.uid()) or public.is_instructor_or_admin());

drop policy if exists review_master_materials_delete on public.materials;
create policy review_master_materials_delete on public.materials
for delete to authenticated
using (uploaded_by = (select auth.uid()) or public.is_instructor_or_admin());

-- -----------------------------------------------------------------------------
-- Direct student-owned tables
-- -----------------------------------------------------------------------------

do $$
declare
  item text[];
  tbl text;
  col text;
begin
  foreach item slice 1 in array array[
    array['bookmarks','student_id'],
    array['notes','student_id'],
    array['flashcard_favorites','student_id'],
    array['study_plans','student_id'],
    array['quiz_attempts','student_id'],
    array['exam_attempts','student_id'],
    array['topic_exam_attempts','student_id'],
    array['practice_attempts','user_id'],
    array['topic_progress','student_id'],
    array['topic_mastery','student_id'],
    array['flashcard_reviews','student_id'],
    array['student_achievements','student_id'],
    array['student_points','student_id'],
    array['study_streaks','student_id'],
    array['notifications','user_id']
  ] loop
    tbl := item[1];
    col := item[2];

    execute format('drop policy if exists review_master_owner_access on public.%I', tbl);
    execute format(
      'create policy review_master_owner_access on public.%I for all to authenticated using (%I = (select auth.uid()) or public.is_instructor_or_admin()) with check (%I = (select auth.uid()) or public.is_instructor_or_admin())',
      tbl, col, col
    );
  end loop;
end $$;

-- Study tasks inherit ownership from their study plan.
drop policy if exists review_master_study_tasks_owner_access on public.study_tasks;
create policy review_master_study_tasks_owner_access on public.study_tasks
for all to authenticated
using (
  public.is_instructor_or_admin()
  or exists (
    select 1 from public.study_plans sp
    where sp.id = study_tasks.study_plan_id
      and sp.student_id = (select auth.uid())
  )
)
with check (
  public.is_instructor_or_admin()
  or exists (
    select 1 from public.study_plans sp
    where sp.id = study_tasks.study_plan_id
      and sp.student_id = (select auth.uid())
  )
);

-- -----------------------------------------------------------------------------
-- Assessments and question banks
-- -----------------------------------------------------------------------------

-- Quizzes / flashcards use status where available. Staff can manage drafts.
drop policy if exists review_master_quizzes_select on public.quizzes;
create policy review_master_quizzes_select on public.quizzes
for select to authenticated
using (status = 'published' or created_by = (select auth.uid()) or public.is_instructor_or_admin());

drop policy if exists review_master_quizzes_write on public.quizzes;
create policy review_master_quizzes_write on public.quizzes
for all to authenticated
using (created_by = (select auth.uid()) or public.is_instructor_or_admin())
with check (created_by = (select auth.uid()) or public.is_instructor_or_admin());

drop policy if exists review_master_flashcards_select on public.flashcards;
create policy review_master_flashcards_select on public.flashcards
for select to authenticated
using (status = 'published' or created_by = (select auth.uid()) or public.is_instructor_or_admin());

drop policy if exists review_master_flashcards_write on public.flashcards;
create policy review_master_flashcards_write on public.flashcards
for all to authenticated
using (created_by = (select auth.uid()) or public.is_instructor_or_admin())
with check (created_by = (select auth.uid()) or public.is_instructor_or_admin());

-- Exams use is_published.
drop policy if exists review_master_exams_select on public.exams;
create policy review_master_exams_select on public.exams
for select to authenticated
using (is_published = true or created_by = (select auth.uid()) or public.is_instructor_or_admin());

drop policy if exists review_master_exams_write on public.exams;
create policy review_master_exams_write on public.exams
for all to authenticated
using (created_by = (select auth.uid()) or public.is_instructor_or_admin())
with check (created_by = (select auth.uid()) or public.is_instructor_or_admin());

-- Topic exams use status where available.
drop policy if exists review_master_topic_exams_select on public.topic_exams;
create policy review_master_topic_exams_select on public.topic_exams
for select to authenticated
using (status = 'published' or public.is_instructor_or_admin());

drop policy if exists review_master_topic_exams_write on public.topic_exams;
create policy review_master_topic_exams_write on public.topic_exams
for all to authenticated
using (public.is_instructor_or_admin())
with check (public.is_instructor_or_admin());

-- Question tables: readable by signed-in users for compatibility, staff-managed for writes.
-- NOTE: Because correct_answer columns exist, prefer student-facing views/RPCs that omit answers.
do $$
declare
  t text;
begin
  foreach t in array array[
    'quiz_questions','exam_questions','topic_quiz_questions','topic_exam_questions','practice_questions'
  ] loop
    execute format('drop policy if exists review_master_questions_read on public.%I', t);
    execute format('create policy review_master_questions_read on public.%I for select to authenticated using (true)', t);

    execute format('drop policy if exists review_master_questions_staff_write on public.%I', t);
    execute format(
      'create policy review_master_questions_staff_write on public.%I for all to authenticated using (public.is_instructor_or_admin()) with check (public.is_instructor_or_admin())',
      t
    );
  end loop;
end $$;

-- Attempt-answer tables inherit ownership from parent attempts.
drop policy if exists review_master_exam_attempt_answers_owner on public.exam_attempt_answers;
create policy review_master_exam_attempt_answers_owner on public.exam_attempt_answers
for all to authenticated
using (
  public.is_instructor_or_admin()
  or exists (
    select 1 from public.exam_attempts ea
    where ea.id = exam_attempt_answers.attempt_id
      and ea.student_id = (select auth.uid())
  )
)
with check (
  public.is_instructor_or_admin()
  or exists (
    select 1 from public.exam_attempts ea
    where ea.id = exam_attempt_answers.attempt_id
      and ea.student_id = (select auth.uid())
  )
);

drop policy if exists review_master_topic_exam_attempt_answers_owner on public.topic_exam_attempt_answers;
create policy review_master_topic_exam_attempt_answers_owner on public.topic_exam_attempt_answers
for all to authenticated
using (
  public.is_instructor_or_admin()
  or exists (
    select 1 from public.topic_exam_attempts tea
    where tea.id = topic_exam_attempt_answers.attempt_id
      and tea.student_id = (select auth.uid())
  )
)
with check (
  public.is_instructor_or_admin()
  or exists (
    select 1 from public.topic_exam_attempts tea
    where tea.id = topic_exam_attempt_answers.attempt_id
      and tea.student_id = (select auth.uid())
  )
);

-- -----------------------------------------------------------------------------
-- Batches
-- -----------------------------------------------------------------------------

drop policy if exists review_master_batches_select on public.batches;
create policy review_master_batches_select on public.batches
for select to authenticated
using (
  public.is_instructor_or_admin()
  or exists (
    select 1 from public.batch_students bs
    where bs.batch_id = batches.id
      and bs.student_id = (select auth.uid())
  )
);

drop policy if exists review_master_batches_write on public.batches;
create policy review_master_batches_write on public.batches
for all to authenticated
using (public.is_instructor_or_admin())
with check (public.is_instructor_or_admin());

drop policy if exists review_master_batch_students_select on public.batch_students;
create policy review_master_batch_students_select on public.batch_students
for select to authenticated
using (student_id = (select auth.uid()) or public.is_instructor_or_admin());

drop policy if exists review_master_batch_students_write on public.batch_students;
create policy review_master_batch_students_write on public.batch_students
for all to authenticated
using (public.is_instructor_or_admin())
with check (public.is_instructor_or_admin());

drop policy if exists review_master_batch_subjects_select on public.batch_subjects;
create policy review_master_batch_subjects_select on public.batch_subjects
for select to authenticated
using (
  public.is_instructor_or_admin()
  or exists (
    select 1 from public.batch_students bs
    where bs.batch_id = batch_subjects.batch_id
      and bs.student_id = (select auth.uid())
  )
);

drop policy if exists review_master_batch_subjects_write on public.batch_subjects;
create policy review_master_batch_subjects_write on public.batch_subjects
for all to authenticated
using (public.is_instructor_or_admin())
with check (public.is_instructor_or_admin());

-- -----------------------------------------------------------------------------
-- Storage listing hardening for materials bucket
-- -----------------------------------------------------------------------------

-- Public buckets can still serve files via public URLs without broad object listing.
drop policy if exists "Anyone can view materials b9j0vg_0" on storage.objects;
drop policy if exists review_master_materials_bucket_authenticated_read on storage.objects;
create policy review_master_materials_bucket_authenticated_read
on storage.objects for select to authenticated
using (bucket_id = 'materials');

-- -----------------------------------------------------------------------------
-- Foreign key indexes flagged by Supabase advisors
-- -----------------------------------------------------------------------------

do $$
declare
  item text[];
  tbl text;
  col text;
  idx text;
begin
  foreach item slice 1 in array array[
    array['subjects','created_by'],
    array['topics','subject_id'],
    array['materials','subject_id'], array['materials','topic_id'], array['materials','uploaded_by'],
    array['bookmarks','student_id'], array['bookmarks','material_id'],
    array['notes','student_id'], array['notes','material_id'],
    array['quizzes','subject_id'], array['quizzes','created_by'],
    array['quiz_questions','quiz_id'],
    array['quiz_attempts','quiz_id'], array['quiz_attempts','student_id'], array['quiz_attempts','topic_id'],
    array['flashcards','subject_id'], array['flashcards','topic_id'], array['flashcards','created_by'],
    array['flashcard_favorites','student_id'], array['flashcard_favorites','flashcard_id'],
    array['study_plans','student_id'], array['study_tasks','study_plan_id'],
    array['exams','subject_id'], array['exams','created_by'],
    array['exam_questions','exam_id'],
    array['exam_attempts','exam_id'], array['exam_attempts','student_id'],
    array['exam_attempt_answers','attempt_id'], array['exam_attempt_answers','question_id'],
    array['student_achievements','student_id'], array['student_achievements','achievement_id'],
    array['notifications','user_id'],
    array['batch_students','batch_id'], array['batch_students','student_id'],
    array['batch_subjects','batch_id'], array['batch_subjects','subject_id'],
    array['learning_contents','topic_id'],
    array['topic_flashcards','topic_id'],
    array['topic_quiz_questions','topic_id'],
    array['topic_exams','topic_id'],
    array['topic_exam_questions','exam_id'],
    array['topic_summaries','topic_id'],
    array['topic_progress','student_id'], array['topic_progress','topic_id'],
    array['flashcard_reviews','student_id'], array['flashcard_reviews','flashcard_id'],
    array['topic_mastery','student_id'], array['topic_mastery','topic_id'],
    array['topic_exam_attempts','topic_exam_id'], array['topic_exam_attempts','student_id'],
    array['topic_exam_attempt_answers','attempt_id'], array['topic_exam_attempt_answers','question_id'],
    array['practice_attempts','user_id'], array['practice_attempts','topic_id'],
    array['practice_questions','topic_id']
  ] loop
    tbl := item[1];
    col := item[2];
    idx := 'idx_' || tbl || '_' || col;
    execute format('create index if not exists %I on public.%I(%I)', idx, tbl, col);
  end loop;
end $$;

commit;
