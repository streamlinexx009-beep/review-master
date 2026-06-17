import '../models/exam_model.dart';
import '../models/exam_question_model.dart';
import '../models/exam_attempt_model.dart';
import '../models/exam_attempt_answer_model.dart';

abstract class ExamRepository {
  Future<List<ExamModel>> getExams();

  Future<List<ExamQuestionModel>>
      getQuestions(
    String examId,
  );

  Future<void> createExam({
    required String title,
    required String description,
    required String subjectId,
    required int passingScore,
    required int timeLimit,
  });

  Future<void> createQuestion({
    required String examId,
    required String questionText,
    required String optionA,
    required String optionB,
    required String optionC,
    required String optionD,
    required String correctAnswer,
  });

  Future<void> submitExam({
  required String examId,
  required double score,
  required bool passed,
  required List<Map<String, dynamic>> answers,
});

Future<List<ExamAttemptAnswerModel>>
    getAttemptAnswers(
  String attemptId,
);

  Future<List<ExamAttemptModel>>
      getMyAttempts();
}

