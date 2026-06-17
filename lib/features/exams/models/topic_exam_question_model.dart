class TopicExamQuestionModel {
  final String id;
  final String examId;
  final String question;
  final String optionA;
  final String optionB;
  final String? optionC;
  final String? optionD;
  final String correctAnswer;

  TopicExamQuestionModel({
    required this.id,
    required this.examId,
    required this.question,
    required this.optionA,
    required this.optionB,
    this.optionC,
    this.optionD,
    required this.correctAnswer,
  });

  factory TopicExamQuestionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TopicExamQuestionModel(
      id: json['id'],
      examId: json['exam_id'],
      question: json['question'],
      optionA: json['option_a'],
      optionB: json['option_b'],
      optionC: json['option_c'],
      optionD: json['option_d'],
      correctAnswer: json['correct_answer'],
    );
  }
}