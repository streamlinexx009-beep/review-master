class TopicAverageModel {

  final String topicName;

  final double average;

  const TopicAverageModel({
    required this.topicName,
    required this.average,
  });

  factory TopicAverageModel.fromMap(
    Map<String,dynamic> map,
  ) {
    return TopicAverageModel(
      topicName:
          map['topic_name'],
      average:
          (map['average']
                  as num)
              .toDouble(),
    );
  }
}