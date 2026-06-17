class QuizAttemptModel {

  final String id;

  final String quizId;

  final String studentId;

  final double score;

  final bool passed;

  const QuizAttemptModel({
    required this.id,
    required this.quizId,
    required this.studentId,
    required this.score,
    required this.passed,
  });

  factory QuizAttemptModel.fromMap(
    Map<String,dynamic> map,
  ) {
    return QuizAttemptModel(
      id: map['id'],
      quizId: map['quiz_id'],
      studentId:
          map['student_id'],
      score:
          (map['score'] as num)
              .toDouble(),
      passed:
          map['passed'],
    );
  }
}