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

  factory ExamQuestionModel.fromMap(
    Map<String,dynamic> map,
  ) {
    return ExamQuestionModel(
      id: map['id'],
      examId: map['exam_id'],
      questionText:
          map['question_text'],
      optionA: map['option_a'],
      optionB: map['option_b'],
      optionC: map['option_c'],
      optionD: map['option_d'],
      correctAnswer:
          map['correct_answer'],
    );
  }
}