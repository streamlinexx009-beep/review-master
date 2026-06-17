
create table study_streaks (
 id uuid primary key default gen_random_uuid(),
 student_id uuid unique references profiles(id) on delete cascade,
 current_streak integer default 0,
 longest_streak integer default 0
);
