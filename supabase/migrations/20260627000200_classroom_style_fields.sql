-- Classroom-style display fields for subject cards and create-class flow.

begin;

alter table public.subjects
  add column if not exists section text,
  add column if not exists room text,
  add column if not exists banner_color text default '#FF7F64',
  add column if not exists banner_image text;

commit;
