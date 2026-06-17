
create table study_plans (
 id uuid primary key default gen_random_uuid(),
 student_id uuid references profiles(id) on delete cascade,
 title text not null,
 description text,
 target_date date,
 status text default 'pending',
 created_at timestamptz default now()
);
