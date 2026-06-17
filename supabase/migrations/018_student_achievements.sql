
create table student_achievements (
 id uuid primary key default gen_random_uuid(),
 student_id uuid references profiles(id) on delete cascade,
 achievement_id uuid references achievements(id) on delete cascade
);
