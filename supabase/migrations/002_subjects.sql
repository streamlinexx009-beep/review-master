
create table subjects (
 id uuid primary key default gen_random_uuid(),
 name text not null,
 description text,
 created_by uuid references profiles(id),
 created_at timestamptz default now()
);
