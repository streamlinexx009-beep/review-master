
create table achievements (
 id uuid primary key default gen_random_uuid(),
 title text not null,
 description text,
 points integer default 0
);
