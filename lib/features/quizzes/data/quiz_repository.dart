import '../models/question_model.dart';
import '../models/quiz_model.dart';

abstract class QuizRepository {
  Future<List<QuizModel>> getQuizzes();

  Future<List<QuestionModel>> getQuestions(
    String topicId,
  );

  Future<void> createQuiz(
    QuizModel quiz,
  );

  Future<Map<String, dynamic>> submitQuiz({
    required String topicId,
    required String studentId,
    required Map<String, String> answers,
  });
}