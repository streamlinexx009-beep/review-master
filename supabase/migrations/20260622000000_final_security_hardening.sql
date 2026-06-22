-- ReviewMaster final security hardening
-- Date: 2026-06-22
-- Purpose:
--   1. Prevent profile role self-escalation from the client.
--   2. Remove broad student read policies from raw question tables that may expose correct_answer.
--
-- Important frontend note:
--   Student-facing exam/quiz flows should use safe RPCs/views that omit correct_answer
--   until server-side scoring is implemented. Staff can still manage raw question tables.

begin;

-- Prevent users from changing their own role directly through PostgREST.
revoke update (role) on public.profiles from authenticated;

create or replace function private.prevent_profile_role_escalation()
returns trigger
language plpgsql
security definer
set search_path = private, public, auth
as $$
begin
  if new.role is distinct from old.role and not private.is_admin() then
    raise exception 'Only admins can change profile roles';
  end if;

  return new;
end;
$$;

revoke all on function private.prevent_profile_role_escalation() from public, anon, authenticated;
grant execute on function private.prevent_profile_role_escalation() to service_role;

drop trigger if exists prevent_profile_role_escalation on public.profiles;
create trigger prevent_profile_role_escalation
before update of role on public.profiles
for each row
execute function private.prevent_profile_role_escalation();

-- Raw question tables can contain correct_answer. Keep staff write access, but do not
-- allow broad direct student reads from these base tables.
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
