-- Add subject-level join codes so newly registered students only see subjects they join.

begin;

alter table public.subjects
  add column if not exists join_code text,
  add column if not exists join_code_enabled boolean not null default true;

create unique index if not exists subjects_join_code_unique_idx
  on public.subjects (upper(join_code))
  where join_code is not null;

create table if not exists public.subject_students (
  id uuid primary key default gen_random_uuid(),
  subject_id uuid not null references public.subjects(id) on delete cascade,
  student_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz default now(),
  constraint subject_students_unique unique (subject_id, student_id)
);

alter table public.subject_students enable row level security;

create or replace function public.generate_subject_join_code()
returns text
language plpgsql
set search_path = public
as $$
declare
  alphabet constant text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  code text;
  i integer;
begin
  loop
    code := '';
    for i in 1..8 loop
      code := code || substr(alphabet, 1 + floor(random() * length(alphabet))::integer, 1);
    end loop;

    exit when not exists (
      select 1
      from public.subjects s
      where upper(s.join_code) = upper(code)
    );
  end loop;

  return code;
end;
$$;

update public.subjects
set join_code = public.generate_subject_join_code()
where join_code is null;

alter table public.subjects
  alter column join_code set default public.generate_subject_join_code();

drop policy if exists review_master_subject_students_select on public.subject_students;
create policy review_master_subject_students_select
on public.subject_students for select to authenticated
using (student_id = (select auth.uid()) or private.is_instructor_or_admin());

drop policy if exists review_master_subject_students_staff_insert on public.subject_students;
create policy review_master_subject_students_staff_insert
on public.subject_students for insert to authenticated
with check (private.is_instructor_or_admin());

drop policy if exists review_master_subject_students_staff_delete on public.subject_students;
create policy review_master_subject_students_staff_delete
on public.subject_students for delete to authenticated
using (private.is_instructor_or_admin() or student_id = (select auth.uid()));

drop policy if exists review_master_authenticated_read on public.subjects;
drop policy if exists review_master_subjects_select on public.subjects;
create policy review_master_subjects_select
on public.subjects for select to authenticated
using (
  private.is_instructor_or_admin()
  or exists (
    select 1
    from public.subject_students ss
    where ss.subject_id = subjects.id
      and ss.student_id = (select auth.uid())
  )
);

create or replace function public.join_subject_by_code(p_join_code text)
returns table(subject_id uuid, subject_name text)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_subject public.subjects%rowtype;
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then
    raise exception 'You must be logged in to join a subject.';
  end if;

  select *
  into v_subject
  from public.subjects
  where upper(join_code) = upper(regexp_replace(coalesce(p_join_code, ''), '\s+', '', 'g'))
    and join_code_enabled = true
  limit 1;

  if v_subject.id is null then
    raise exception 'Invalid or inactive subject code.';
  end if;

  insert into public.subject_students (subject_id, student_id)
  values (v_subject.id, v_user_id)
  on conflict (subject_id, student_id) do nothing;

  subject_id := v_subject.id;
  subject_name := v_subject.name;
  return next;
end;
$$;

grant execute on function public.join_subject_by_code(text) to authenticated;

commit;
