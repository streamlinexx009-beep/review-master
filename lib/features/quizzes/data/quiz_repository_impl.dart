import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/question_model.dart';
import '../models/quiz_model.dart';
import 'quiz_repository.dart';
import '../../analytics/services/topic_mastery_service.dart';

class QuizRepositoryImpl
    implements QuizRepository {
  final SupabaseClient client;

   final TopicMasteryService
      _topicMasteryService =
          TopicMasteryService();

  QuizRepositoryImpl(
    this.client,
  );

  @override
  Future<List<QuizModel>>
      getQuizzes() async {
    final data =
        await client
            .from('quizzes')
            .select();

    return data
        .map<QuizModel>(
          (e) =>
              QuizModel.fromMap(e),
        )
        .toList();
  }

  @override
  Future<List<QuestionModel>>
      getQuestions(
    String topicId,
  ) async {
    final data =
        await client
            .from(
              'topic_quiz_questions',
            )
            .select()
            .eq(
              'topic_id',
              topicId,
            );

    return data
        .map<QuestionModel>(
          (e) =>
              QuestionModel
                  .fromMap(e),
        )
        .toList();
  }

  @override
  Future<void> createQuiz(
    QuizModel quiz,
  ) async {
    await client
        .from('quizzes')
        .insert({
      'title': quiz.title,
      'description':
          quiz.description,
      'subject_id':
          quiz.subjectId,
      'topic_id':
          quiz.topicId,
      'passing_score':
          quiz.passingScore,
      'time_limit':
          quiz.timeLimit,
    });
  }

  @override
  Future<Map<String, dynamic>>
      submitQuiz({
    required String topicId,
    required String studentId,
    required Map<String, String>
        answers,
  }) async {
    final questions =
        await getQuestions(
      topicId,
    );

    int score = 0;

    for (final question
        in questions) {
      final selected =
          answers[question.id];

      if (selected ==
          question
              .correctAnswer) {
        score++;
      }
    }

    final totalQuestions =
        questions.length;

    final percentage =
        totalQuestions == 0
            ? 0.0
            : (score /
                    totalQuestions) *
                100;

    final passed =
        percentage >= 75;

    await client
    .from('quiz_attempts')
    .insert({
  'student_id': studentId,
  'topic_id': topicId,
  'score': score,
  'total_questions': totalQuestions,
  'percentage': percentage,
  'passed': passed,
});

await _topicMasteryService
    .updateQuizMastery(
  studentId: studentId,
  topicId: topicId,
  score: percentage,
);

    return {
      'score': score,
      'totalQuestions':
          totalQuestions,
      'percentage':
          percentage,
      'passed': passed,
    };
  }


}