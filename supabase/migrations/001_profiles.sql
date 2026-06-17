
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  email text unique,
  role text not null check (role in ('admin','instructor','student')),
  created_at timestamptz default now()
);
