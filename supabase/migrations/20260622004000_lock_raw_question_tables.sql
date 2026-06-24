-- ReviewMaster raw question table lockdown
-- Date: 2026-06-22
-- Purpose:
--   After safe question-delivery RPCs are available, stop students from reading
--   raw question tables directly. Raw tables may contain correct_answer.
--   Staff still keep direct select/write access for authoring and management.

begin;

create or replace function public.get_exam_attempt_answers_safe(p_attempt_id uuid)
returns table (
  question_id uuid,
  question_text text,
  option_a text,
  option_b text,
  option_c text,
  option_d text,
  selected_answer text,
  correct_answer text,
  is_correct boolean
)
language sql
stable
security definer
set search_path = public, private, auth
as $$
  select
    q.id as question_id,
    q.question_text,
    q.option_a,
    q.option_b,
    q.option_c,
    q.option_d,
    a.selected_answer,
    a.correct_answer,
    a.is_correct
  from public.exam_attempt_answers a
  join public.exam_attempts ea on ea.id = a.attempt_id
  join public.exam_questions q on q.id = a.question_id
  where a.attempt_id = p_attempt_id
    and (
      ea.student_id = auth.uid()
      or private.is_instructor_or_admin()
    )
  order by q.created_at;
$$;

revoke all on function public.get_exam_attempt_answers_safe(uuid) from public, anon;
grant execute on function public.get_exam_attempt_answers_safe(uuid) to authenticated;

create or replace function public.get_topic_exam_attempt_answers_safe(p_attempt_id uuid)
returns table (
  question_id uuid,
  question text,
  option_a text,
  option_b text,
  option_c text,
  option_d text,
  selected_answer text,
  correct_answer text,
  is_correct boolean
)
language sql
stable
security definer
set search_path = public, private, auth
as $$
  select
    q.id as question_id,
    q.question,
    q.option_a,
    q.option_b,
    q.option_c,
    q.option_d,
    a.selected_answer,
    a.correct_answer,
    a.is_correct
  from public.topic_exam_attempt_answers a
  join public.topic_exam_attempts tea on tea.id = a.attempt_id
  join public.topic_exam_questions q on q.id = a.question_id
  where a.attempt_id = p_attempt_id
    and (
      tea.student_id = auth.uid()
      or private.is_instructor_or_admin()
    )
  order by q.created_at;
$$;

revoke all on function public.get_topic_exam_attempt_answers_safe(uuid) from public, anon;
grant execute on function public.get_topic_exam_attempt_answers_safe(uuid) to authenticated;

do $$
declare
  t text;
begin
  foreach t in array array[
    'quiz_questions',
    'exam_questions',
    'topic_quiz_questions',
    'topic_exam_questions',
    'practice_questions'
  ] loop
    execute format('drop policy if exists review_master_questions_read on public.%I', t);
    execute format('drop policy if exists review_master_questions_staff_select on public.%I', t);
    execute format(
      'create policy review_master_questions_staff_select on public.%I for select to authenticated using (private.is_instructor_or_admin())',
      t
    );
  end loop;
end $$;

commit;
