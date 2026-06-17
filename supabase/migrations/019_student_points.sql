
create table student_points (
 id uuid primary key default gen_random_uuid(),
 student_id uuid unique references profiles(id) on delete cascade,
 points integer default 0,
 level integer default 1
);
