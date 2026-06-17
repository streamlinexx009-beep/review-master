
create table bookmarks (
 id uuid primary key default gen_random_uuid(),
 student_id uuid references profiles(id) on delete cascade,
 material_id uuid references materials(id) on delete cascade,
 created_at timestamptz default now(),
 unique(student_id, material_id)
);
