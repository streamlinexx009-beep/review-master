class QuestionModel {
  final String id;
  final String topicId;
  final String question;

  final String optionA;
  final String optionB;
  final String? optionC;
  final String? optionD;

  final String correctAnswer;

  const QuestionModel({
    required this.id,
    required this.topicId,
    required this.question,
    required this.optionA,
    required this.optionB,
    this.optionC,
    this.optionD,
    required this.correctAnswer,
  });

  factory QuestionModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return QuestionModel(
      id: map['id'] as String,
      topicId:
          map['topic_id']
              as String,
      question:
          map['question']
              as String,
      optionA:
          map['option_a']
              as String,
      optionB:
          map['option_b']
              as String,
      optionC:
          map['option_c']
              as String?,
      optionD:
          map['option_d']
              as String?,
      correctAnswer:
          map['correct_answer']
              as String,
    );
  }
}