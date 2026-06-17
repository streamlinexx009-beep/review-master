
create table exam_attempts (
 id uuid primary key default gen_random_uuid(),
 exam_id uuid references exams(id) on delete cascade,
 student_id uuid references profiles(id) on delete cascade,
 score numeric(5,2),
 rank_position integer,
 passed boolean
);
