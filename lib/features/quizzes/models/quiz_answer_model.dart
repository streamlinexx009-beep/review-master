class QuizAnswerModel {

  final String id;

  final String attemptId;

  final String questionId;

  final String studentAnswer;

  final bool isCorrect;

  const QuizAnswerModel({
    required this.id,
    required this.attemptId,
    required this.questionId,
    required this.studentAnswer,
    required this.isCorrect,
  });

  factory QuizAnswerModel.fromMap(
    Map<String,dynamic> map,
  ) {
    return QuizAnswerModel(
      id: map['id'],
      attemptId:
          map['attempt_id'],
      questionId:
          map['question_id'],
      studentAnswer:
          map['student_answer'],
      isCorrect:
          map['is_correct'],
    );
  }
}