-- ReviewMaster student-safe question RPCs
-- Date: 2026-06-22
-- Purpose:
--   Give students question payloads without correct_answer before submission.
--   Staff can still manage raw question tables through existing staff policies.

begin;

create or replace function public.get_exam_questions_safe(p_exam_id uuid)
returns table (
  id uuid,
  exam_id uuid,
  question_text text,
  option_a text,
  option_b text,
  option_c text,
  option_d text,
  created_at timestamptz
)
language sql
stable
security definer
set search_path = public, private, auth
as $$
  select
    q.id,
    q.exam_id,
    q.question_text,
    q.option_a,
    q.option_b,
    q.option_c,
    q.option_d,
    q.created_at
  from public.exam_questions q
  join public.exams e on e.id = q.exam_id
  where q.exam_id = p_exam_id
    and (
      e.is_published = true
      or e.created_by = auth.uid()
      or private.is_instructor_or_admin()
    )
  order by q.created_at;
$$;

revoke all on function public.get_exam_questions_safe(uuid) from public, anon;
grant execute on function public.get_exam_questions_safe(uuid) to authenticated;

create or replace function public.get_practice_questions_safe(
  p_topic_id uuid,
  p_limit integer default 10
)
returns table (
  id uuid,
  topic_id uuid,
  question text,
  option_a text,
  option_b text,
  option_c text,
  option_d text,
  created_at timestamptz
)
language sql
stable
security definer
set search_path = public, private, auth
as $$
  select
    q.id,
    q.topic_id,
    q.question,
    q.option_a,
    q.option_b,
    q.option_c,
    q.option_d,
    q.created_at
  from public.topic_quiz_questions q
  where q.topic_id = p_topic_id
  order by random()
  limit least(greatest(coalesce(p_limit, 10), 1), 50);
$$;

revoke all on function public.get_practice_questions_safe(uuid, integer) from public, anon;
grant execute on function public.get_practice_questions_safe(uuid, integer) to authenticated;

create or replace function public.get_topic_exam_questions_safe(p_exam_id uuid)
returns table (
  id uuid,
  exam_id uuid,
  question text,
  option_a text,
  option_b text,
  option_c text,
  option_d text,
  created_at timestamptz
)
language sql
stable
security definer
set search_path = public, private, auth
as $$
  select
    q.id,
    q.exam_id,
    q.question,
    q.option_a,
    q.option_b,
    q.option_c,
    q.option_d,
    q.created_at
  from public.topic_exam_questions q
  join public.topic_exams e on e.id = q.exam_id
  where q.exam_id = p_exam_id
    and (
      e.status = 'published'
      or private.is_instructor_or_admin()
    )
  order by q.created_at;
$$;

revoke all on function public.get_topic_exam_questions_safe(uuid) from public, anon;
grant execute on function public.get_topic_exam_questions_safe(uuid) to authenticated;

commit;
