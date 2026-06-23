-- ReviewMaster student-safe assessment flows
-- Date: 2026-06-22
-- Purpose:
--   Stop student clients from needing direct access to correct_answer before submit.
--   These RPCs return questions without correct_answer and submit functions return
--   the score/result needed for UI feedback.

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

create or replace function public.submit_exam_attempt_secure(
  p_exam_id uuid,
  p_answers jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, private, auth
as $$
declare
  v_user_id uuid := auth.uid();
  v_attempt_id uuid;
  v_passing_score numeric;
  v_total_questions integer;
  v_correct_answers integer;
  v_score numeric;
  v_passed boolean;
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  if p_answers is null or jsonb_typeof(p_answers) <> 'array' then
    raise exception 'Answers must be a JSON array';
  end if;

  select e.passing_score
    into v_passing_score
  from public.exams e
  where e.id = p_exam_id
    and (
      e.is_published = true
      or e.created_by = v_user_id
      or private.is_instructor_or_admin()
    )
  limit 1;

  if v_passing_score is null then
    raise exception 'Exam not found or unavailable';
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
    count(q.id) filter (where coalesce(sa.selected_answer, '') = q.correct_answer)::integer
  into v_total_questions, v_correct_answers
  from public.exam_questions q
  left join submitted_answers sa on sa.question_id = q.id
  where q.exam_id = p_exam_id;

  if coalesce(v_total_questions, 0) = 0 then
    raise exception 'Exam has no questions';
  end if;

  v_score := round((v_correct_answers::numeric / v_total_questions::numeric) * 100, 2);
  v_passed := v_score >= v_passing_score;

  insert into public.exam_attempts (exam_id, student_id, score, passed)
  values (p_exam_id, v_user_id, v_score, v_passed)
  returning id into v_attempt_id;

  with submitted_answers as (
    select distinct on ((answer_item ->> 'question_id')::uuid)
      (answer_item ->> 'question_id')::uuid as question_id,
      coalesce(answer_item ->> 'selected_answer', '') as selected_answer
    from jsonb_array_elements(p_answers) as answer_item
    where answer_item ? 'question_id'
    order by (answer_item ->> 'question_id')::uuid
  )
  insert into public.exam_attempt_answers (
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
  from public.exam_questions q
  left join submitted_answers sa on sa.question_id = q.id
  where q.exam_id = p_exam_id
  order by q.created_at;

  return jsonb_build_object(
    'attempt_id', v_attempt_id,
    'score', v_score,
    'passed', v_passed,
    'correct_answers', v_correct_answers,
    'total_questions', v_total_questions
  );
end;
$$;

revoke all on function public.submit_exam_attempt_secure(uuid, jsonb) from public, anon;
grant execute on function public.submit_exam_attempt_secure(uuid, jsonb) to authenticated;

create or replace function public.submit_practice_attempt_secure(
  p_topic_id uuid,
  p_answers jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, private, auth
as $$
declare
  v_user_id uuid := auth.uid();
  v_attempt_id uuid;
  v_total_questions integer;
  v_correct_answers integer;
  v_percentage numeric;
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
    count(q.id) filter (where coalesce(sa.selected_answer, '') = q.correct_answer)::integer
  into v_total_questions, v_correct_answers
  from public.topic_quiz_questions q
  join submitted_answers sa on sa.question_id = q.id
  where q.topic_id = p_topic_id;

  if coalesce(v_total_questions, 0) = 0 then
    raise exception 'Practice attempt has no valid questions';
  end if;

  v_percentage := round((v_correct_answers::numeric / v_total_questions::numeric) * 100, 2);

  insert into public.practice_attempts (user_id, topic_id, score, total_questions)
  values (v_user_id, p_topic_id, v_correct_answers, v_total_questions)
  returning id into v_attempt_id;

  return jsonb_build_object(
    'attempt_id', v_attempt_id,
    'score', v_percentage,
    'correct_answers', v_correct_answers,
    'total_questions', v_total_questions
  );
end;
$$;

revoke all on function public.submit_practice_attempt_secure(uuid, jsonb) from public, anon;
grant execute on function public.submit_practice_attempt_secure(uuid, jsonb) to authenticated;

create or replace function public.submit_topic_exam_attempt_secure(
  p_exam_id uuid,
  p_answers jsonb
)
returns jsonb
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
  v_passed boolean;
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
    count(q.id) filter (where coalesce(sa.selected_answer, '') = q.correct_answer)::integer
  into v_total_questions, v_correct_answers
  from public.topic_exam_questions q
  left join submitted_answers sa on sa.question_id = q.id
  where q.exam_id = p_exam_id;

  if coalesce(v_total_questions, 0) = 0 then
    raise exception 'Topic exam has no questions';
  end if;

  v_score := round((v_correct_answers::numeric / v_total_questions::numeric) * 100, 2);
  v_passed := v_score >= v_passing_score;

  insert into public.topic_exam_attempts (topic_exam_id, student_id, score, passed)
  values (p_exam_id, v_user_id, v_score, v_passed)
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

  return jsonb_build_object(
    'attempt_id', v_attempt_id,
    'score', v_score,
    'passed', v_passed,
    'correct_answers', v_correct_answers,
    'total_questions', v_total_questions,
    'topic_id', v_topic_id
  );
end;
$$;

revoke all on function public.submit_topic_exam_attempt_secure(uuid, jsonb) from public, anon;
grant execute on function public.submit_topic_exam_attempt_secure(uuid, jsonb) to authenticated;

commit;
