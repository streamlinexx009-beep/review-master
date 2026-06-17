
create table quiz_attempts (
 id uuid primary key default gen_random_uuid(),
 quiz_id uuid references quizzes(id) on delete cascade,
 student_id uuid references profiles(id) on delete cascade,
 score numeric(5,2),
 passed boolean,
 created_at timestamptz default now()
);
