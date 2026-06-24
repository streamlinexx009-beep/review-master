# ReviewHub System Improvement Plan

This document captures practical upgrades that will make ReviewHub more reliable, secure, and polished.

## 1. Assessment integrity

Current state: student-facing assessment screens now have safe RPC paths for loading questions without sending answer keys, and saved scoring has server-side RPC paths. The remaining important follow-up is broad end-to-end testing after applying the Supabase migrations.

Recommended path:

1. Use server-side scoring RPCs for all saved attempts.
2. Replace raw question-table reads with student-facing RPCs/views that omit `correct_answer`.
3. Return correct answers only after an attempt is submitted, and only for review screens.
4. Add attempt locking so students cannot submit multiple conflicting attempts for the same exam if the exam policy disallows it.

Status in this branch:

- `submit_exam_attempt_secure_result` returns server-calculated exam scores.
- `submit_practice_attempt_secure_result` returns server-calculated practice scores.
- `submit_topic_exam_attempt_secure_result` returns server-calculated topic-exam scores.
- `get_exam_questions_safe`, `get_practice_questions_safe`, and `get_topic_exam_questions_safe` omit answer keys for student-facing screens.
- Raw question-table reads are locked down for students after the safe RPC migration is applied.
- Flutter tries secure RPCs first and falls back to legacy submission if the matching migration is not applied yet.

## 2. Role and access control

Recommended path:

1. Keep RLS as the source of truth.
2. Keep frontend route guards for user experience.
3. Prevent users from updating their own `profiles.role`.
4. Create a small admin-only role management screen instead of letting profile updates touch role fields.

Status in this branch:

- Frontend staff-only routes are guarded for students.
- A migration prevents profile role self-escalation.

## 3. Dashboard and navigation

Recommended path:

1. Keep the Quez-inspired sidebar and soft cards.
2. Use real data for dashboard metrics instead of static placeholder numbers.
3. Add loading, empty, and error states for every dashboard card.
4. Keep all module names consistent across sidebar, routes, and page titles.

Suggested dashboard metrics:

- Active subjects
- Upcoming exams
- Completed attempts
- Average score
- Study streak
- Weakest topics

## 4. Product experience

Recommended path:

1. Add onboarding after registration.
2. Let users choose role only through an approved invite/enrollment process.
3. Add a notification center for upcoming exams, deadlines, and instructor announcements.
4. Add global search that actually searches subjects, materials, exams, and topics.
5. Add clear empty states with primary actions, such as “Create your first subject”.

## 5. Quality and deployment

Recommended path:

1. Keep GitHub CI running `flutter analyze` and a web build.
2. Add widget tests for login, routing, and dashboard rendering.
3. Add Supabase migration checks in CI.
4. Add environment-based Supabase config for dev/staging/prod.
5. Create a release checklist for applying migrations before deploying the matching Flutter code.

## 6. Data model cleanup

Recommended path:

1. Standardize naming: use either `student_id` or `user_id`, not both, unless there is a strong reason.
2. Standardize status values, for example `draft`, `published`, `archived`.
3. Add unique indexes where duplicate enrollment or duplicate favorites should be impossible.
4. Add database constraints for scores, passing percentages, and answer choices.

## Priority order

1. Apply role-escalation migration.
2. Apply server-side exam scoring migration.
3. Apply server-side practice and topic-exam scoring migration.
4. Apply safe question delivery and raw question-table lockdown migrations.
5. Replace dashboard placeholder stats with live provider-backed data.
6. Add CI migration validation and basic widget tests.
