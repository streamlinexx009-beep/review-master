-- ReviewMaster server-side practice and topic-exam scoring
-- Date: 2026-06-22
-- Purpose:
--   Move saved scoring for practice quizzes and topic exams to Postgres.
--   Flutter can still calculate local feedback for UX, but persisted score,
--   passed, correct_answer, and is_correct values are calculated server-side.

begin;

create or replace function public.submit_practice_attempt_secure(
  p_topic_id uuid,
  p_answers jsonb
)
returns uuid
language plpgsql
security definer
set search_path = public, private, auth
as $$
declare
  v_user_id uuid := auth.uid();
  v_attempt_id uuid;
  v_total_questions integer;
  v_correct_answers integer;
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  if p_answers is null or jsonb_typeof(p_answers) <> 'array' then
    raise exception 'Answers must be a JSON array';
  end if;

  with submitted_answers as (
    select distinct on ((answer_item ->> 'question_id')::uuid)
      (answer_item ->> 'question_id')::uuid as question_id,
      coalesce(answer_item ->> 'selected_answer', '') as selected_answer
    from jsonb_array_elements(p_answers) as answer_item
    where answer_item ? 'question_id'
    order by (answer_item ->> 'question_id')::uuid
  )
  select
    count(q.id)::integer,
    count(q.id) filter (
      where coalesce(sa.selected_answer, '') = q.correct_answer
    )::integer
  into v_total_questions, v_correct_answers
  from public.topic_quiz_questions q
  join submitted_answers sa on sa.question_id = q.id
  where q.topic_id = p_topic_id;

  if coalesce(v_total_questions, 0) = 0 then
    raise exception 'Practice attempt has no valid questions';
  end if;

  insert into public.practice_attempts (
    user_id,
    topic_id,
    score,
    total_questions
  ) values (
    v_user_id,
    p_topic_id,
    v_correct_answers,
    v_total_questions
  )
  returning id into v_attempt_id;

  perform public.calculate_topic_mastery(v_user_id, p_topic_id)
  where exists (
    select 1
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname = 'calculate_topic_mastery'
  );

  return v_attempt_id;
end;
$$;

revoke all on function public.submit_practice_attempt_secure(uuid, jsonb) from public, anon;
grant execute on function public.submit_practice_attempt_secure(uuid, jsonb) to authenticated;

create or replace function public.submit_topic_exam_attempt_secure(
  p_exam_id uuid,
  p_answers jsonb
)
returns uuid
language plpgsql
security definer
set search_path = public, private, auth
as $$
declare
  v_user_id uuid := auth.uid();
  v_attempt_id uuid;
  v_topic_id uuid;
  v_passing_score numeric := 75;
  v_total_questions integer;
  v_correct_answers integer;
  v_score numeric;
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  if p_answers is null or jsonb_typeof(p_answers) <> 'array' then
    raise exception 'Answers must be a JSON array';
  end if;

  select te.topic_id
    into v_topic_id
  from public.topic_exams te
  where te.id = p_exam_id
    and (
      te.status = 'published'
      or private.is_instructor_or_admin()
    )
  limit 1;

  if v_topic_id is null then
    raise exception 'Topic exam not found or unavailable';
  end if;

  with submitted_answers as (
    select distinct on ((answer_item ->> 'question_id')::uuid)
      (answer_item ->> 'question_id')::uuid as question_id,
      coalesce(answer_item ->> 'selected_answer', '') as selected_answer
    from jsonb_array_elements(p_answers) as answer_item
    where answer_item ? 'question_id'
    order by (answer_item ->> 'question_id')::uuid
  )
  select
    count(q.id)::integer,
    count(q.id) filter (
      where coalesce(sa.selected_answer, '') = q.correct_answer
    )::integer
  into v_total_questions, v_correct_answers
  from public.topic_exam_questions q
  left join submitted_answers sa on sa.question_id = q.id
  where q.exam_id = p_exam_id;

  if coalesce(v_total_questions, 0) = 0 then
    raise exception 'Topic exam has no questions';
  end if;

  v_score := round((v_correct_answers::numeric / v_total_questions::numeric) * 100, 2);

  insert into public.topic_exam_attempts (
    topic_exam_id,
    student_id,
    score,
    passed
  ) values (
    p_exam_id,
    v_user_id,
    v_score,
    v_score >= v_passing_score
  )
  returning id into v_attempt_id;

  with submitted_answers as (
    select distinct on ((answer_item ->> 'question_id')::uuid)
      (answer_item ->> 'question_id')::uuid as question_id,
      coalesce(answer_item ->> 'selected_answer', '') as selected_answer
    from jsonb_array_elements(p_answers) as answer_item
    where answer_item ? 'question_id'
    order by (answer_item ->> 'question_id')::uuid
  )
  insert into public.topic_exam_attempt_answers (
    attempt_id,
    question_id,
    selected_answer,
    correct_answer,
    is_correct
  )
  select
    v_attempt_id,
    q.id,
    coalesce(sa.selected_answer, ''),
    q.correct_answer,
    coalesce(sa.selected_answer, '') = q.correct_answer
  from public.topic_exam_questions q
  left join submitted_answers sa on sa.question_id = q.id
  where q.exam_id = p_exam_id
  order by q.created_at;

  perform public.calculate_topic_mastery(v_user_id, v_topic_id)
  where exists (
    select 1
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname = 'calculate_topic_mastery'
  );

  return v_attempt_id;
end;
$$;

revoke all on function public.submit_topic_exam_attempt_secure(uuid, jsonb) from public, anon;
grant execute on function public.submit_topic_exam_attempt_secure(uuid, jsonb) to authenticated;

commit;
