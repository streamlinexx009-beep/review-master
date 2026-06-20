-- ReviewMaster split broad staff write policies
-- Date: 2026-06-21
-- Purpose:
--   Replace broad FOR ALL staff/write policies with command-specific INSERT,
--   UPDATE, and DELETE policies to avoid overlapping permissive SELECT policies.

begin;

-- Shared catalog tables: keep existing authenticated read policy and split staff writes.
do $$
declare
  t text;
begin
  foreach t in array array[
    'subjects','topics','learning_contents','topic_summaries','topic_flashcards','achievements'
  ] loop
    execute format('drop policy if exists review_master_staff_write on public.%I', t);

    execute format('drop policy if exists review_master_staff_insert on public.%I', t);
    execute format('create policy review_master_staff_insert on public.%I for insert to authenticated with check (private.is_instructor_or_admin())', t);

    execute format('drop policy if exists review_master_staff_update on public.%I', t);
    execute format('create policy review_master_staff_update on public.%I for update to authenticated using (private.is_instructor_or_admin()) with check (private.is_instructor_or_admin())', t);

    execute format('drop policy if exists review_master_staff_delete on public.%I', t);
    execute format('create policy review_master_staff_delete on public.%I for delete to authenticated using (private.is_instructor_or_admin())', t);
  end loop;
end $$;

-- Question tables: keep authenticated read policy and split staff writes.
do $$
declare
  t text;
begin
  foreach t in array array[
    'quiz_questions','exam_questions','topic_quiz_questions','topic_exam_questions','practice_questions'
  ] loop
    execute format('drop policy if exists review_master_questions_staff_write on public.%I', t);

    execute format('drop policy if exists review_master_questions_staff_insert on public.%I', t);
    execute format('create policy review_master_questions_staff_insert on public.%I for insert to authenticated with check (private.is_instructor_or_admin())', t);

    execute format('drop policy if exists review_master_questions_staff_update on public.%I', t);
    execute format('create policy review_master_questions_staff_update on public.%I for update to authenticated using (private.is_instructor_or_admin()) with check (private.is_instructor_or_admin())', t);

    execute format('drop policy if exists review_master_questions_staff_delete on public.%I', t);
    execute format('create policy review_master_questions_staff_delete on public.%I for delete to authenticated using (private.is_instructor_or_admin())', t);
  end loop;
end $$;

-- Batches.
drop policy if exists review_master_batches_write on public.batches;
drop policy if exists review_master_batches_insert on public.batches;
create policy review_master_batches_insert on public.batches
for insert to authenticated
with check (private.is_instructor_or_admin());
drop policy if exists review_master_batches_update on public.batches;
create policy review_master_batches_update on public.batches
for update to authenticated
using (private.is_instructor_or_admin())
with check (private.is_instructor_or_admin());
drop policy if exists review_master_batches_delete on public.batches;
create policy review_master_batches_delete on public.batches
for delete to authenticated
using (private.is_instructor_or_admin());

drop policy if exists review_master_batch_students_write on public.batch_students;
drop policy if exists review_master_batch_students_insert on public.batch_students;
create policy review_master_batch_students_insert on public.batch_students
for insert to authenticated
with check (private.is_instructor_or_admin());
drop policy if exists review_master_batch_students_update on public.batch_students;
create policy review_master_batch_students_update on public.batch_students
for update to authenticated
using (private.is_instructor_or_admin())
with check (private.is_instructor_or_admin());
drop policy if exists review_master_batch_students_delete on public.batch_students;
create policy review_master_batch_students_delete on public.batch_students
for delete to authenticated
using (private.is_instructor_or_admin());

drop policy if exists review_master_batch_subjects_write on public.batch_subjects;
drop policy if exists review_master_batch_subjects_insert on public.batch_subjects;
create policy review_master_batch_subjects_insert on public.batch_subjects
for insert to authenticated
with check (private.is_instructor_or_admin());
drop policy if exists review_master_batch_subjects_update on public.batch_subjects;
create policy review_master_batch_subjects_update on public.batch_subjects
for update to authenticated
using (private.is_instructor_or_admin())
with check (private.is_instructor_or_admin());
drop policy if exists review_master_batch_subjects_delete on public.batch_subjects;
create policy review_master_batch_subjects_delete on public.batch_subjects
for delete to authenticated
using (private.is_instructor_or_admin());

-- Assessments where a separate select policy exists.
drop policy if exists review_master_quizzes_write on public.quizzes;
drop policy if exists review_master_quizzes_insert on public.quizzes;
create policy review_master_quizzes_insert on public.quizzes
for insert to authenticated
with check (created_by = (select auth.uid()) or private.is_instructor_or_admin());
drop policy if exists review_master_quizzes_update on public.quizzes;
create policy review_master_quizzes_update on public.quizzes
for update to authenticated
using (created_by = (select auth.uid()) or private.is_instructor_or_admin())
with check (created_by = (select auth.uid()) or private.is_instructor_or_admin());
drop policy if exists review_master_quizzes_delete on public.quizzes;
create policy review_master_quizzes_delete on public.quizzes
for delete to authenticated
using (created_by = (select auth.uid()) or private.is_instructor_or_admin());

drop policy if exists review_master_flashcards_write on public.flashcards;
drop policy if exists review_master_flashcards_insert on public.flashcards;
create policy review_master_flashcards_insert on public.flashcards
for insert to authenticated
with check (created_by = (select auth.uid()) or private.is_instructor_or_admin());
drop policy if exists review_master_flashcards_update on public.flashcards;
create policy review_master_flashcards_update on public.flashcards
for update to authenticated
using (created_by = (select auth.uid()) or private.is_instructor_or_admin())
with check (created_by = (select auth.uid()) or private.is_instructor_or_admin());
drop policy if exists review_master_flashcards_delete on public.flashcards;
create policy review_master_flashcards_delete on public.flashcards
for delete to authenticated
using (created_by = (select auth.uid()) or private.is_instructor_or_admin());

drop policy if exists review_master_exams_write on public.exams;
drop policy if exists review_master_exams_insert on public.exams;
create policy review_master_exams_insert on public.exams
for insert to authenticated
with check (created_by = (select auth.uid()) or private.is_instructor_or_admin());
drop policy if exists review_master_exams_update on public.exams;
create policy review_master_exams_update on public.exams
for update to authenticated
using (created_by = (select auth.uid()) or private.is_instructor_or_admin())
with check (created_by = (select auth.uid()) or private.is_instructor_or_admin());
drop policy if exists review_master_exams_delete on public.exams;
create policy review_master_exams_delete on public.exams
for delete to authenticated
using (created_by = (select auth.uid()) or private.is_instructor_or_admin());

drop policy if exists review_master_topic_exams_write on public.topic_exams;
drop policy if exists review_master_topic_exams_insert on public.topic_exams;
create policy review_master_topic_exams_insert on public.topic_exams
for insert to authenticated
with check (private.is_instructor_or_admin());
drop policy if exists review_master_topic_exams_update on public.topic_exams;
create policy review_master_topic_exams_update on public.topic_exams
for update to authenticated
using (private.is_instructor_or_admin())
with check (private.is_instructor_or_admin());
drop policy if exists review_master_topic_exams_delete on public.topic_exams;
create policy review_master_topic_exams_delete on public.topic_exams
for delete to authenticated
using (private.is_instructor_or_admin());

commit;
