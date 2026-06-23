class PracticeQuestion {
  final String id;
  final String question;

  final String optionA;
  final String optionB;
  final String? optionC;
  final String? optionD;

  final String correctAnswer;

  PracticeQuestion({
    required this.id,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.correctAnswer,
    this.optionC,
    this.optionD,
  });

  factory PracticeQuestion.fromMap(Map<String, dynamic> map) {
    return PracticeQuestion(
      id: map['id']?.toString() ?? '',
      question: map['question']?.toString() ?? '',
      optionA: map['option_a']?.toString() ?? '',
      optionB: map['option_b']?.toString() ?? '',
      optionC: map['option_c']?.toString(),
      optionD: map['option_d']?.toString(),
      correctAnswer: map['correct_answer']?.toString() ?? '',
    );
  }
}
