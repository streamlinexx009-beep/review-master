
create table study_tasks (
 id uuid primary key default gen_random_uuid(),
 study_plan_id uuid references study_plans(id) on delete cascade,
 title text not null,
 is_completed boolean default false,
 due_date date
);
