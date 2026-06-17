
create table notes (
 id uuid primary key default gen_random_uuid(),
 student_id uuid references profiles(id) on delete cascade,
 material_id uuid references materials(id) on delete cascade,
 content text not null,
 created_at timestamptz default now()
);
