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

  factory ExamAttemptAnswerModel.fromMap(Map<String, dynamic> map) {
    final question = map['exam_questions'];
    final questionMap = question is Map ? Map<String, dynamic>.from(question) : <String, dynamic>{};

    return ExamAttemptAnswerModel(
      questionId: map['question_id']?.toString() ?? '',
      questionText: (questionMap['question_text'] ?? map['question_text'] ?? map['question'])?.toString() ?? '',
      optionA: (questionMap['option_a'] ?? map['option_a'])?.toString() ?? '',
      optionB: (questionMap['option_b'] ?? map['option_b'])?.toString() ?? '',
      optionC: (questionMap['option_c'] ?? map['option_c'])?.toString() ?? '',
      optionD: (questionMap['option_d'] ?? map['option_d'])?.toString() ?? '',
      selectedAnswer: map['selected_answer']?.toString() ?? '',
      correctAnswer: map['correct_answer']?.toString() ?? '',
      isCorrect: map['is_correct'] == true,
    );
  }
}
