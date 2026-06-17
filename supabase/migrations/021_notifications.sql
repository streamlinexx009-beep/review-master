
create table notifications (
 id uuid primary key default gen_random_uuid(),
 user_id uuid references profiles(id) on delete cascade,
 title text not null,
 message text not null,
 type text not null,
 is_read boolean default false,
 created_at timestamptz default now()
);
