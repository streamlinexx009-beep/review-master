-- ReviewMaster post-RLS security cleanup
-- Date: 2026-06-21
-- Purpose:
--   1. Move RLS helper functions out of the exposed public API schema.
--   2. Remove legacy broad/duplicate policies left from earlier migrations.
--   3. Remove broad storage object listing for the public materials bucket.
--   4. Tighten direct RPC execution grants for helper and trigger functions.

begin;

-- Keep helper functions available to RLS policies, but out of the exposed public API schema.
create schema if not exists private;
revoke all on schema private from public;
grant usage on schema private to authenticated, service_role;

create or replace function private.current_user_role()
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

create or replace function private.is_admin()
returns boolean
language sql
stable
security definer
set search_path = private, public, auth
as $$
  select coalesce(private.current_user_role() = 'admin', false)
$$;

create or replace function private.is_instructor_or_admin()
returns boolean
language sql
stable
security definer
set search_path = private, public, auth
as $$
  select coalesce(private.current_user_role() in ('admin', 'instructor'), false)
$$;

revoke all on function private.current_user_role() from public, anon, authenticated;
revoke all on function private.is_admin() from public, anon, authenticated;
revoke all on function private.is_instructor_or_admin() from public, anon, authenticated;
grant execute on function private.current_user_role() to authenticated, service_role;
grant execute on function private.is_admin() to authenticated, service_role;
grant execute on function private.is_instructor_or_admin() to authenticated, service_role;

-- Remove legacy policies that overlap with the review_master policy set.
drop policy if exists "Users can view own profile" on public.profiles;
drop policy if exists "Users can update own profile" on public.profiles;

drop policy if exists "Allow users to view subjects" on public.subjects;
drop policy if exists "Allow authenticated users to create subjects" on public.subjects;
drop policy if exists "Allow authenticated users to update subjects" on public.subjects;
drop policy if exists "Allow users to delete their own subjects" on public.subjects;

drop policy if exists "Allow read materials" on public.materials;
drop policy if exists "Allow insert materials" on public.materials;
drop policy if exists "Allow update own materials" on public.materials;
drop policy if exists "Allow delete own materials" on public.materials;

-- Public buckets can serve objects by URL without broad object listing.
drop policy if exists review_master_materials_bucket_authenticated_read on storage.objects;

-- Recreate helper-backed policies to use private helpers rather than public RPC-callable helpers.
drop policy if exists review_master_profiles_select on public.profiles;
create policy review_master_profiles_select
on public.profiles for select to authenticated
using (id = (select auth.uid()) or private.is_instructor_or_admin());

drop policy if exists review_master_profiles_insert on public.profiles;
create policy review_master_profiles_insert
on public.profiles for insert to authenticated
with check (id = (select auth.uid()) or private.is_admin());

drop policy if exists review_master_profiles_update on public.profiles;
create policy review_master_profiles_update
on public.profiles for update to authenticated
using (id = (select auth.uid()) or private.is_admin())
with check (id = (select auth.uid()) or private.is_admin());

-- Shared learning catalog: signed-in read, staff write.
do $$
declare
  t text;
begin
  foreach t in array array[
    'subjects','topics','learning_contents','topic_summaries','topic_flashcards','achievements'
  ] loop
    execute format('drop policy if exists review_master_staff_write on public.%I', t);
    execute format(
      'create policy review_master_staff_write on public.%I for all to authenticated using (private.is_instructor_or_admin()) with check (private.is_instructor_or_admin())',
      t
    );
  end loop;
end $$;

-- Materials.
drop policy if exists review_master_materials_insert on public.materials;
create policy review_master_materials_insert on public.materials
for insert to authenticated
with check (uploaded_by = (select auth.uid()) or private.is_instructor_or_admin());

drop policy if exists review_master_materials_update on public.materials;
create policy review_master_materials_update on public.materials
for update to authenticated
using (uploaded_by = (select auth.uid()) or private.is_instructor_or_admin())
with check (uploaded_by = (select auth.uid()) or private.is_instructor_or_admin());

drop policy if exists review_master_materials_delete on public.materials;
create policy review_master_materials_delete on public.materials
for delete to authenticated
using (uploaded_by = (select auth.uid()) or private.is_instructor_or_admin());

-- Direct student-owned tables.
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
      'create policy review_master_owner_access on public.%I for all to authenticated using (%I = (select auth.uid()) or private.is_instructor_or_admin()) with check (%I = (select auth.uid()) or private.is_instructor_or_admin())',
      tbl, col, col
    );
  end loop;
end $$;

-- Study tasks inherit ownership from their study plan.
drop policy if exists review_master_study_tasks_owner_access on public.study_tasks;
create policy review_master_study_tasks_owner_access on public.study_tasks
for all to authenticated
using (
  private.is_instructor_or_admin()
  or exists (
    select 1 from public.study_plans sp
    where sp.id = study_tasks.study_plan_id
      and sp.student_id = (select auth.uid())
  )
)
with check (
  private.is_instructor_or_admin()
  or exists (
    select 1 from public.study_plans sp
    where sp.id = study_tasks.study_plan_id
      and sp.student_id = (select auth.uid())
  )
);

-- Assessments.
drop policy if exists review_master_quizzes_select on public.quizzes;
create policy review_master_quizzes_select on public.quizzes
for select to authenticated
using (status = 'published' or created_by = (select auth.uid()) or private.is_instructor_or_admin());

drop policy if exists review_master_quizzes_write on public.quizzes;
create policy review_master_quizzes_write on public.quizzes
for all to authenticated
using (created_by = (select auth.uid()) or private.is_instructor_or_admin())
with check (created_by = (select auth.uid()) or private.is_instructor_or_admin());

drop policy if exists review_master_flashcards_select on public.flashcards;
create policy review_master_flashcards_select on public.flashcards
for select to authenticated
using (status = 'published' or created_by = (select auth.uid()) or private.is_instructor_or_admin());

drop policy if exists review_master_flashcards_write on public.flashcards;
create policy review_master_flashcards_write on public.flashcards
for all to authenticated
using (created_by = (select auth.uid()) or private.is_instructor_or_admin())
with check (created_by = (select auth.uid()) or private.is_instructor_or_admin());

drop policy if exists review_master_exams_select on public.exams;
create policy review_master_exams_select on public.exams
for select to authenticated
using (is_published = true or created_by = (select auth.uid()) or private.is_instructor_or_admin());

drop policy if exists review_master_exams_write on public.exams;
create policy review_master_exams_write on public.exams
for all to authenticated
using (created_by = (select auth.uid()) or private.is_instructor_or_admin())
with check (created_by = (select auth.uid()) or private.is_instructor_or_admin());

drop policy if exists review_master_topic_exams_select on public.topic_exams;
create policy review_master_topic_exams_select on public.topic_exams
for select to authenticated
using (status = 'published' or private.is_instructor_or_admin());

drop policy if exists review_master_topic_exams_write on public.topic_exams;
create policy review_master_topic_exams_write on public.topic_exams
for all to authenticated
using (private.is_instructor_or_admin())
with check (private.is_instructor_or_admin());

-- Question tables.
do $$
declare
  t text;
begin
  foreach t in array array[
    'quiz_questions','exam_questions','topic_quiz_questions','topic_exam_questions','practice_questions'
  ] loop
    execute format('drop policy if exists review_master_questions_staff_write on public.%I', t);
    execute format(
      'create policy review_master_questions_staff_write on public.%I for all to authenticated using (private.is_instructor_or_admin()) with check (private.is_instructor_or_admin())',
      t
    );
  end loop;
end $$;

-- Attempt-answer tables inherit ownership from parent attempts.
drop policy if exists review_master_exam_attempt_answers_owner on public.exam_attempt_answers;
create policy review_master_exam_attempt_answers_owner on public.exam_attempt_answers
for all to authenticated
using (
  private.is_instructor_or_admin()
  or exists (
    select 1 from public.exam_attempts ea
    where ea.id = exam_attempt_answers.attempt_id
      and ea.student_id = (select auth.uid())
  )
)
with check (
  private.is_instructor_or_admin()
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
  private.is_instructor_or_admin()
  or exists (
    select 1 from public.topic_exam_attempts tea
    where tea.id = topic_exam_attempt_answers.attempt_id
      and tea.student_id = (select auth.uid())
  )
)
with check (
  private.is_instructor_or_admin()
  or exists (
    select 1 from public.topic_exam_attempts tea
    where tea.id = topic_exam_attempt_answers.attempt_id
      and tea.student_id = (select auth.uid())
  )
);

-- Batches.
drop policy if exists review_master_batches_select on public.batches;
create policy review_master_batches_select on public.batches
for select to authenticated
using (
  private.is_instructor_or_admin()
  or exists (
    select 1 from public.batch_students bs
    where bs.batch_id = batches.id
      and bs.student_id = (select auth.uid())
  )
);

drop policy if exists review_master_batches_write on public.batches;
create policy review_master_batches_write on public.batches
for all to authenticated
using (private.is_instructor_or_admin())
with check (private.is_instructor_or_admin());

drop policy if exists review_master_batch_students_select on public.batch_students;
create policy review_master_batch_students_select on public.batch_students
for select to authenticated
using (student_id = (select auth.uid()) or private.is_instructor_or_admin());

drop policy if exists review_master_batch_students_write on public.batch_students;
create policy review_master_batch_students_write on public.batch_students
for all to authenticated
using (private.is_instructor_or_admin())
with check (private.is_instructor_or_admin());

drop policy if exists review_master_batch_subjects_select on public.batch_subjects;
create policy review_master_batch_subjects_select on public.batch_subjects
for select to authenticated
using (
  private.is_instructor_or_admin()
  or exists (
    select 1 from public.batch_students bs
    where bs.batch_id = batch_subjects.batch_id
      and bs.student_id = (select auth.uid())
  )
);

drop policy if exists review_master_batch_subjects_write on public.batch_subjects;
create policy review_master_batch_subjects_write on public.batch_subjects
for all to authenticated
using (private.is_instructor_or_admin())
with check (private.is_instructor_or_admin());

-- Restrict direct execution of public helper and trigger functions.
do $$
declare
  r record;
begin
  for r in
    select p.oid::regprocedure::text as fn, p.proname
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname in ('current_user_role', 'is_admin', 'is_instructor_or_admin', 'handle_new_user')
  loop
    execute format('revoke all on function %s from public, anon, authenticated', r.fn);
    execute format('grant execute on function %s to service_role', r.fn);
  end loop;
end $$;

-- calculate_topic_mastery is not SECURITY DEFINER, but should not be anonymously callable.
do $$
declare
  r record;
begin
  for r in
    select p.oid::regprocedure::text as fn
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname = 'calculate_topic_mastery'
  loop
    execute format('revoke execute on function %s from public, anon', r.fn);
    execute format('grant execute on function %s to authenticated, service_role', r.fn);
  end loop;
end $$;

commit;
