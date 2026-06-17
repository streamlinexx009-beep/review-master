
create table materials (
 id uuid primary key default gen_random_uuid(),
 title text not null,
 description text,
 subject_id uuid references subjects(id) on delete cascade,
 topic_id uuid references topics(id) on delete set null,
 file_url text not null,
 uploaded_by uuid references profiles(id),
 created_at timestamptz default now()
);
