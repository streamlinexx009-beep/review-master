class ExamAttemptAnswerModel {
  final String questionId;
  final String questionText;

  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;

  final String selectedAnswer;
  final String correctAnswer;

  final bool isCorrect;

  const ExamAttemptAnswerModel({
    required this.questionId,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
  });

  factory ExamAttemptAnswerModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return ExamAttemptAnswerModel(
      questionId: map['question_id'],

      questionText:
          map['exam_questions']
              ['question_text'],

      optionA:
          map['exam_questions']
              ['option_a'],

      optionB:
          map['exam_questions']
              ['option_b'],

      optionC:
          map['exam_questions']
              ['option_c'],

      optionD:
          map['exam_questions']
              ['option_d'],

      selectedAnswer:
          map['selected_answer'],

      correctAnswer:
          map['correct_answer'],

      isCorrect:
          map['is_correct'],
    );
  }
}