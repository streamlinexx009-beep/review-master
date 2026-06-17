import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/exam_attempt_model.dart';
import '../models/exam_model.dart';
import '../models/exam_question_model.dart';
import 'exam_repository.dart';
import '../models/exam_attempt_answer_model.dart';

class ExamRepositoryImpl
implements ExamRepository {
final SupabaseClient client;

ExamRepositoryImpl(
this.client,
);

@override
Future<List<ExamModel>>
getExams() async {
final data =
await client
.from('exams')
.select();


return data
    .map<ExamModel>(
      (e) => ExamModel.fromMap(e),
    )
    .toList();


}

@override
Future<List<ExamQuestionModel>>
getQuestions(
String examId,
) async {
final data =
await client
.from('exam_questions')
.select()
.eq(
'exam_id',
examId,
);

return data
    .map<ExamQuestionModel>(
      (e) =>
          ExamQuestionModel.fromMap(
        e,
      ),
    )
    .toList();


}

@override
Future<void> createExam({
required String title,
required String description,
required String subjectId,
required int passingScore,
required int timeLimit,
}) async {
await client
.from('exams')
.insert({
'title': title,
'description': description,
'subject_id': subjectId,
'passing_score': passingScore,
'time_limit': timeLimit,
});
}

@override
Future<void> createQuestion({
required String examId,
required String questionText,
required String optionA,
required String optionB,
required String optionC,
required String optionD,
required String correctAnswer,
}) async {
await client
.from('exam_questions')
.insert({
'exam_id': examId,
'question_text': questionText,
'option_a': optionA,
'option_b': optionB,
'option_c': optionC,
'option_d': optionD,
'correct_answer': correctAnswer,
});
}

@override
Future<void> submitExam({
required String examId,
required double score,
required bool passed,
required List<Map<String, dynamic>>
answers,
}) async {
final user =
client.auth.currentUser;


if (user == null) {
  throw Exception(
    'User not authenticated',
  );
}

final attempt =
    await client
        .from('exam_attempts')
        .insert({
          'exam_id': examId,
          'student_id': user.id,
          'score': score,
          'passed': passed,
        })
        .select()
        .single();

final attemptId =
    attempt['id'] as String;

final answerRows =
    answers.map((answer) {
  return {
    'attempt_id': attemptId,
    'question_id':
        answer['question_id'],
    'selected_answer':
        answer['selected_answer'],
    'correct_answer':
        answer['correct_answer'],
    'is_correct':
        answer['is_correct'],
  };
}).toList();

if (answerRows.isNotEmpty) {
  await client
      .from(
        'exam_attempt_answers',
      )
      .insert(answerRows);
}

}

@override
Future<List<ExamAttemptModel>>
getMyAttempts() async {

  
final user =
client.auth.currentUser;


if (user == null) {
  throw Exception(
    'User not authenticated',
  );
}

final response =
    await client
        .from('exam_attempts')
        .select('''
          *,
          exams (
            title
          )
        ''')
        .eq(
          'student_id',
          user.id,
        )
        .order(
          'created_at',
          ascending: false,
        );

return response
    .map<ExamAttemptModel>(
      (e) =>
          ExamAttemptModel.fromMap(
        e,
      ),
    )
    .toList();

}

@override
Future<List<ExamAttemptAnswerModel>>
getAttemptAnswers(
  String attemptId,
) async {
  final response =
      await client
          .from(
            'exam_attempt_answers',
          )
          .select('''
            *,
            exam_questions (
              question_text,
              option_a,
              option_b,
              option_c,
              option_d
            )
          ''')
          .eq(
            'attempt_id',
            attemptId,
          );

  return response
      .map<ExamAttemptAnswerModel>(
        (e) =>
            ExamAttemptAnswerModel
                .fromMap(e),
      )
      .toList();
}
}
