
create table quizzes (
 id uuid primary key default gen_random_uuid(),
 title text not null,
 description text,
 subject_id uuid references subjects(id),
 passing_score integer default 75,
 time_limit integer default 15,
 created_by uuid references profiles(id),
 created_at timestamptz default now()
);
