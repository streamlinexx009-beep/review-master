-- ReviewMaster Supabase security hardening migration
-- Date: 2026-06-20
-- Purpose:
--   1. Enable Row Level Security on public application tables.
--   2. Add baseline role/user policies for students, instructors, and admins.
--   3. Harden SECURITY DEFINER functions by fixing search_path and revoking public RPC execution.
--   4. Add indexes for foreign keys flagged by Supabase performance advisors.
--
-- IMPORTANT:
-- Review these policies against your frontend data flow before applying to production.
-- In particular, question tables include correct_answer columns, so client-side reads can expose answers.

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

-- Harden existing SECURITY DEFINER functions that advisors flagged.
-- Keep handle_new_user executable by Supabase Auth triggers, but not as a public RPC.
do $$
begin
  if exists (
    select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'handle_new_user'
  ) then
    alter function public.handle_new_user() set search_path = public, auth;
    revoke execute on function public.handle_new_user() from anon, authenticated;
  end if;

  if exists (
    select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'calculate_topic_mastery'
  ) then
    alter function public.calculate_topic_mastery(uuid, uuid) set search_path = public, auth;
  end if;
end $$;

-- -----------------------------------------------------------------------------
-- Enable RLS
-- -----------------------------------------------------------------------------

alter table public.profiles enable row level security;
alter table public.subjects enable row level security;
alter table public.topics enable row level security;
alter table public.materials enable row level security;
alter table public.bookmarks enable row level security;
alter table public.notes enable row level security;
alter table public.quizzes enable row level security;
alter table public.quiz_questions enable row level security;
alter table public.quiz_attempts enable row level security;
alter table public.flashcards enable row level security;
alter table public.flashcard_favorites enable row level security;
alter table public.study_plans enable row level security;
alter table public.study_tasks enable row level security;
alter table public.exams enable row level security;
alter table public.exam_questions enable row level security;
alter table public.exam_attempts enable row level security;
alter table public.exam_attempt_answers enable row level security;
alter table public.achievements enable row level security;
alter table public.student_achievements enable row level security;
alter table public.student_points enable row level security;
alter table public.study_streaks enable row level security;
alter table public.notifications enable row level security;
alter table public.batches enable row level security;
alter table public.batch_students enable row level security;
alter table public.batch_subjects enable row level security;
alter table public.learning_contents enable row level security;
alter table public.topic_flashcards enable row level security;
alter table public.topic_quiz_questions enable row level security;
alter table public.topic_exams enable row level security;
alter table public.topic_exam_questions enable row level security;
alter table public.topic_summaries enable row level security;
alter table public.topic_progress enable row level security;
alter table public.flashcard_reviews enable row level security;
alter table public.topic_mastery enable row level security;
alter table public.topic_exam_attempts enable row level security;
alter table public.topic_exam_attempt_answers enable row level security;
alter table public.practice_attempts enable row level security;
alter table public.practice_questions enable row level security;

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
-- Public learning catalog: readable by signed-in users, writable by staff
-- -----------------------------------------------------------------------------

drop policy if exists review_master_subjects_select on public.subjects;
create policy review_master_subjects_select on public.subjects
for select to authenticated using (true);

drop policy if exists review_master_subjects_write on public.subjects;
create policy review_master_subjects_write on public.subjects
for all to authenticated
using (public.is_instructor_or_admin())
with check (public.is_instructor_or_admin());

drop policy if exists review_master_topics_select on public.topics;
create policy review_master_topics_select on public.topics
for select to authenticated using (true);

drop policy if exists review_master_topics_write on public.topics;
create policy review_master_topics_write on public.topics
for all to authenticated
using (public.is_instructor_or_admin())
with check (public.is_instructor_or_admin());

drop policy if exists review_master_learning_contents_select on public.learning_contents;
create policy review_master_learning_contents_select on public.learning_contents
for select to authenticated using (true);

drop policy if exists review_master_learning_contents_write on public.learning_contents;
create policy review_master_learning_contents_write on public.learning_contents
for all to authenticated
using (public.is_instructor_or_admin())
with check (public.is_instructor_or_admin());

drop policy if exists review_master_topic_summaries_select on public.topic_summaries;
create policy review_master_topic_summaries_select on public.topic_summaries
for select to authenticated using (true);

drop policy if exists review_master_topic_summaries_write on public.topic_summaries;
create policy review_master_topic_summaries_write on public.topic_summaries
for all to authenticated
using (public.is_instructor_or_admin())
with check (public.is_instructor_or_admin());

-- Materials: signed-in users can read; uploader/staff can manage.
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
-- Student-owned personal tables
-- -----------------------------------------------------------------------------

drop policy if exists review_master_bookmarks_owner on public.bookmarks;
create policy review_master_bookmarks_owner on public.bookmarks
for all to authenticated
using (student_id = (select auth.uid()) or public.is_instructor_or_admin())
with check (student_id = (select auth.uid()) or public.is_instructor_or_admin());

drop policy if exists review_master_notes_owner on public.notes;
create policy review_master_notes_owner on public.notes
for all to authenticated
using (student_id = (select auth.uid()) or public.is_instructor_or_admin())
with check (student_id = (select auth.uid()) or public.is_instructor_or_admin());

drop policy if exists review_master_flashcard_favorites_owner on public.flashcard_favorites;
create policy review_master_flashcard_favorites_owner on public.flashcard_favorites
for all to authenticated
using (student_id = (select auth.uid()) or public.is_instructor_or_admin())
with check (student_id = (select auth.uid()) or public.is_instructor_or_admin());

drop policy if exists review_master_study_plans_owner on public.study_plans;
create policy review_master_study_plans_owner on public.study_plans
for all to authenticated
using (student_id = (select auth.uid()) or public.is_instructor_or_admin())
with check (student_id = (select auth.uid()) or public.is_instructor_or_admin());

drop policy if exists review_master_study_tasks_owner on public.study_tasks;
create policy review_master_study_tasks_owner on public.study_tasks
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

-- Question tables are staff-managed. SELECT is limited to authenticated users for compatibility,
-- but the presence of correct_answer columns means the frontend should avoid exposing these rows
-- directly during tests. Prefer RPCs/views that omit answers until submission.
drop policy if exists review_master_quiz_questions_select on public.quiz_questions;
create policy review_master_quiz_questions_select on public.quiz_questions
for select to authenticated using (true);

drop policy if exists review_master_quiz_questions_write on public.quiz_questions;
create policy review_master_quiz_questions_write on public.quiz_questions
for all to authenticated
using (public.is_instructor_or_admin())
with check (public.is_instructor_or_admin());

drop policy if exists review_master_exam_questions_select on public.exam_questions;
create policy review_master_exam_questions_select on public.exam_questions
for select to authenticated using (true);

drop policy if exists review_master_exam_questions_write on public.exam_questions;
create policy review_master_exam_questions_write on public.exam_questions
for all to authenticated
using (public.is_instructor_or_admin())
with check (public.is_instructor_or_admin());

drop policy if exists review_master_topic_quiz_questions_select on public.topic_quiz_questions;
create policy review_master_topic_quiz_questions_select on public.topic_quiz_questions
for select to authenticated using (true);

drop policy if exists review_master_topic_quiz_questions_write on public.topic_quiz_questions;
create policy review_master_topic_quiz_questions_write on public.topic_quiz_questions
for all to authenticated
using (public.is_instructor_or_admin())
with check (public.is_instructor_or_admin());

drop policy if exists review_master_topic_exam_questions_select on public.topic_exam_questions;
create policy review_master_topic_exam_questions_select on public.topic_exam_questions
for select to authenticated using (true);

drop policy if exists review_master_topic_exam_questions_write on public.topic_exam_questions;
create policy review_master_topic_exam_questions_write on public.topic_exam_questions
for all to authenticated
using (public.is_instructor_or_admin())
with check (public.is_instructor_or_admin());

drop policy if exists review_master_practice_questions_select on public.practice_questions;
create policy review_master_practice_questions_select on public.practice_questions
for select to authenticated using (true);

drop policy if exists review_master_practice_questions_write on public.practice_questions;
create policy review_master_practice_questions_write on public.practice_questions
for all to authenticated
using (public.is_instructor_or_admin())
with check (public.is_instructor_or_admin());

-- Topic flashcards have no status/creator column, so they are readable by signed-in users and managed by staff.
drop policy if exists review_master_topic_flashcards_select on public.topic_flashcards;
create policy review_master_topic_flashcards_select on public.topic_flashcards
for select to authenticated using (true);

drop policy if exists review_master_topic_flashcards_write on public.topic_flashcards;
create policy review_master_topic_flashcards_write on public.topic_flashcards
for all to authenticated
using (public.is_instructor_or_admin())
with check (public.is_instructor_or_admin());

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

-- -----------------------------------------------------------------------------
-- Attempts, answers, mastery, progress
-- -----------------------------------------------------------------------------

drop policy if exists review_master_quiz_attempts_owner on public.quiz_attempts;
create policy review_master_quiz_attempts_owner on public.quiz_attempts
for all to authenticated
using (student_id = (select auth.uid()) or public.is_instructor_or_admin())
with check (student_id = (select auth.uid()) or public.is_instructor_or_admin());

drop policy if exists review_master_exam_attempts_owner on public.exam_attempts;
create policy review_master_exam_attempts_owner on public.exam_attempts
for all to authenticated
using (student_id = (select auth.uid()) or public.is_instructor_or_admin())
with check (student_id = (select auth.uid()) or public.is_instructor_or_admin());

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

drop policy if exists review_master_topic_exam_attempts_owner on public.topic_exam_attempts;
create policy review_master_topic_exam_attempts_owner on public.topic_exam_attempts
for all to authenticated
using (student_id = (select auth.uid()) or public.is_instructor_or_admin())
with check (student_id = (select auth.uid()) or public.is_instructor_or_admin());

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

drop policy if exists review_master_practice_attempts_owner on public.practice_attempts;
create policy review_master_practice_attempts_owner on public.practice_attempts
for all to authenticated
using (user_id = (select auth.uid()) or public.is_instructor_or_admin())
with check (user_id = (select auth.uid()) or public.is_instructor_or_admin());

drop policy if exists review_master_topic_progress_owner on public.topic_progress;
create policy review_master_topic_progress_owner on public.topic_progress
for all to authenticated
using (student_id = (select auth.uid()) or public.is_instructor_or_admin())
with check (student_id = (select auth.uid()) or public.is_instructor_or_admin());

drop policy if exists review_master_topic_mastery_owner on public.topic_mastery;
create policy review_master_topic_mastery_owner on public.topic_mastery
for all to authenticated
using (student_id = (select auth.uid()) or public.is_instructor_or_admin())
with check (student_id = (select auth.uid()) or public.is_instructor_or_admin());

drop policy if exists review_master_flashcard_reviews_owner on public.flashcard_reviews;
create policy review_master_flashcard_reviews_owner on public.flashcard_reviews
for all to authenticated
using (student_id = (select auth.uid()) or public.is_instructor_or_admin())
with check (student_id = (select auth.uid()) or public.is_instructor_or_admin());

-- -----------------------------------------------------------------------------
-- Gamification and notifications
-- -----------------------------------------------------------------------------

drop policy if exists review_master_achievements_select on public.achievements;
create policy review_master_achievements_select on public.achievements
for select to authenticated using (true);

drop policy if exists review_master_achievements_write on public.achievements;
create policy review_master_achievements_write on public.achievements
for all to authenticated
using (public.is_instructor_or_admin())
with check (public.is_instructor_or_admin());

drop policy if exists review_master_student_achievements_owner on public.student_achievements;
create policy review_master_student_achievements_owner on public.student_achievements
for all to authenticated
using (student_id = (select auth.uid()) or public.is_instructor_or_admin())
with check (student_id = (select auth.uid()) or public.is_instructor_or_admin());

drop policy if exists review_master_student_points_owner on public.student_points;
create policy review_master_student_points_owner on public.student_points
for all to authenticated
using (student_id = (select auth.uid()) or public.is_instructor_or_admin())
with check (student_id = (select auth.uid()) or public.is_instructor_or_admin());

drop policy if exists review_master_study_streaks_owner on public.study_streaks;
create policy review_master_study_streaks_owner on public.study_streaks
for all to authenticated
using (student_id = (select auth.uid()) or public.is_instructor_or_admin())
with check (student_id = (select auth.uid()) or public.is_instructor_or_admin());

drop policy if exists review_master_notifications_owner on public.notifications;
create policy review_master_notifications_owner on public.notifications
for all to authenticated
using (user_id = (select auth.uid()) or public.is_instructor_or_admin())
with check (user_id = (select auth.uid()) or public.is_instructor_or_admin());

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
-- Remove broad SELECT policies on storage.objects for materials and replace with authenticated read.
drop policy if exists "Anyone can view materials b9j0vg_0" on storage.objects;
drop policy if exists review_master_materials_bucket_authenticated_read on storage.objects;
create policy review_master_materials_bucket_authenticated_read
on storage.objects for select to authenticated
using (bucket_id = 'materials');

-- -----------------------------------------------------------------------------
-- Foreign key indexes flagged by Supabase advisors
-- -----------------------------------------------------------------------------

create index if not exists idx_subjects_created_by on public.subjects(created_by);
create index if not exists idx_topics_subject_id on public.topics(subject_id);
create index if not exists idx_materials_subject_id on public.materials(subject_id);
create index if not exists idx_materials_topic_id on public.materials(topic_id);
create index if not exists idx_materials_uploaded_by on public.materials(uploaded_by);
create index if not exists idx_bookmarks_student_id on public.bookmarks(student_id);
create index if not exists idx_bookmarks_material_id on public.bookmarks(material_id);
create index if not exists idx_notes_student_id on public.notes(student_id);
create index if not exists idx_notes_material_id on public.notes(material_id);
create index if not exists idx_quizzes_subject_id on public.quizzes(subject_id);
create index if not exists idx_quizzes_created_by on public.quizzes(created_by);
create index if not exists idx_quiz_questions_quiz_id on public.quiz_questions(quiz_id);
create index if not exists idx_quiz_attempts_quiz_id on public.quiz_attempts(quiz_id);
create index if not exists idx_quiz_attempts_student_id on public.quiz_attempts(student_id);
create index if not exists idx_quiz_attempts_topic_id on public.quiz_attempts(topic_id);
create index if not exists idx_flashcards_subject_id on public.flashcards(subject_id);
create index if not exists idx_flashcards_topic_id on public.flashcards(topic_id);
create index if not exists idx_flashcards_created_by on public.flashcards(created_by);
create index if not exists idx_flashcard_favorites_student_id on public.flashcard_favorites(student_id);
create index if not exists idx_flashcard_favorites_flashcard_id on public.flashcard_favorites(flashcard_id);
create index if not exists idx_study_plans_student_id on public.study_plans(student_id);
create index if not exists idx_study_tasks_study_plan_id on public.study_tasks(study_plan_id);
create index if not exists idx_exams_subject_id on public.exams(subject_id);
create index if not exists idx_exams_created_by on public.exams(created_by);
create index if not exists idx_exam_questions_exam_id on public.exam_questions(exam_id);
create index if not exists idx_exam_attempts_exam_id on public.exam_attempts(exam_id);
create index if not exists idx_exam_attempts_student_id on public.exam_attempts(student_id);
create index if not exists idx_exam_attempt_answers_attempt_id on public.exam_attempt_answers(attempt_id);
create index if not exists idx_exam_attempt_answers_question_id on public.exam_attempt_answers(question_id);
create index if not exists idx_student_achievements_student_id on public.student_achievements(student_id);
create index if not exists idx_student_achievements_achievement_id on public.student_achievements(achievement_id);
create index if not exists idx_notifications_user_id on public.notifications(user_id);
create index if not exists idx_batch_students_batch_id on public.batch_students(batch_id);
create index if not exists idx_batch_students_student_id on public.batch_students(student_id);
create index if not exists idx_batch_subjects_batch_id on public.batch_subjects(batch_id);
create index if not exists idx_batch_subjects_subject_id on public.batch_subjects(subject_id);
create index if not exists idx_learning_contents_topic_id on public.learning_contents(topic_id);
create index if not exists idx_topic_flashcards_topic_id on public.topic_flashcards(topic_id);
create index if not exists idx_topic_quiz_questions_topic_id on public.topic_quiz_questions(topic_id);
create index if not exists idx_topic_exams_topic_id on public.topic_exams(topic_id);
create index if not exists idx_topic_exam_questions_exam_id on public.topic_exam_questions(exam_id);
create index if not exists idx_topic_summaries_topic_id on public.topic_summaries(topic_id);
create index if not exists idx_topic_progress_student_id on public.topic_progress(student_id);
create index if not exists idx_topic_progress_topic_id on public.topic_progress(topic_id);
create index if not exists idx_flashcard_reviews_student_id on public.flashcard_reviews(student_id);
create index if not exists idx_flashcard_reviews_flashcard_id on public.flashcard_reviews(flashcard_id);
create index if not exists idx_topic_mastery_student_id on public.topic_mastery(student_id);
create index if not exists idx_topic_mastery_topic_id on public.topic_mastery(topic_id);
create index if not exists idx_topic_exam_attempts_topic_exam_id on public.topic_exam_attempts(topic_exam_id);
create index if not exists idx_topic_exam_attempts_student_id on public.topic_exam_attempts(student_id);
create index if not exists idx_topic_exam_attempt_answers_attempt_id on public.topic_exam_attempt_answers(attempt_id);
create index if not exists idx_topic_exam_attempt_answers_question_id on public.topic_exam_attempt_answers(question_id);
create index if not exists idx_practice_attempts_user_id on public.practice_attempts(user_id);
create index if not exists idx_practice_attempts_topic_id on public.practice_attempts(topic_id);
create index if not exists idx_practice_questions_topic_id on public.practice_questions(topic_id);

commit;
