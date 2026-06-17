
create table flashcard_favorites (
 id uuid primary key default gen_random_uuid(),
 student_id uuid references profiles(id) on delete cascade,
 flashcard_id uuid references flashcards(id) on delete cascade,
 unique(student_id,flashcard_id)
);
