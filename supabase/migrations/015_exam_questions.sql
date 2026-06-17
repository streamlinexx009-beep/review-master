
create table exam_questions (
 id uuid primary key default gen_random_uuid(),
 exam_id uuid references exams(id) on delete cascade,
 question_text text not null,
 option_a text, option_b text, option_c text, option_d text,
 correct_answer text not null,
 explanation text
);
