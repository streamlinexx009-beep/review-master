-- ReviewMaster final security hardening
-- Date: 2026-06-22
-- Purpose:
--   1. Prevent profile role self-escalation from the client.
--   2. Document the next non-breaking step for assessment integrity.
--
-- This migration intentionally does NOT remove direct question-table reads yet,
-- because the current Flutter exam/practice flows still read question rows directly.
-- Removing those policies must be paired with student-safe RPCs/views and
-- server-side scoring to avoid breaking active exam/quiz/practice screens.

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

commit;
