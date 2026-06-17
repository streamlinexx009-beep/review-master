import '../models/recommendation_model.dart';

class RecommendationService {
  RecommendationModel generate({
    required String topicName,
    required double mastery,
  }) {
    if (mastery < 50) {
      return RecommendationModel(
        topicName: topicName,
        mastery: mastery,
        level: 'Needs Attention',
        actions: [
          'Review flashcards',
          'Retake quiz',
          'Study topic again',
        ],
      );
    }

    if (mastery < 80) {
      return RecommendationModel(
        topicName: topicName,
        mastery: mastery,
        level: 'Improving',
        actions: [
          'Take another quiz',
          'Review weak concepts',
        ],
      );
    }

    return RecommendationModel(
      topicName: topicName,
      mastery: mastery,
      level: 'Strong',
      actions: [
        'Proceed to next topic',
        'Take mock exam',
      ],
    );
  }
}