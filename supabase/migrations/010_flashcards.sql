
create table flashcards (
 id uuid primary key default gen_random_uuid(),
 subject_id uuid references subjects(id) on delete cascade,
 topic_id uuid references topics(id) on delete set null,
 front_text text not null,
 back_text text not null,
 created_by uuid references profiles(id),
 created_at timestamptz default now()
);
