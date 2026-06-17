
create table topics (
 id uuid primary key default gen_random_uuid(),
 subject_id uuid references subjects(id) on delete cascade,
 name text not null,
 description text,
 created_at timestamptz default now()
);
