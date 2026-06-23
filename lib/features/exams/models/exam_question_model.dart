class ExamQuestionModel {
  final String id;
  final String examId;
  final String questionText;

  final String? optionA;
  final String? optionB;
  final String? optionC;
  final String? optionD;

  final String correctAnswer;

  const ExamQuestionModel({
    required this.id,
    required this.examId,
    required this.questionText,
    required this.correctAnswer,
    this.optionA,
    this.optionB,
    this.optionC,
    this.optionD,
  });

  factory ExamQuestionModel.fromMap(Map<String, dynamic> map) {
    return ExamQuestionModel(
      id: map['id']?.toString() ?? '',
      examId: map['exam_id']?.toString() ?? '',
      questionText: map['question_text']?.toString() ?? '',
      optionA: map['option_a']?.toString(),
      optionB: map['option_b']?.toString(),
      optionC: map['option_c']?.toString(),
      optionD: map['option_d']?.toString(),
      correctAnswer: map['correct_answer']?.toString() ?? '',
    );
  }
}
