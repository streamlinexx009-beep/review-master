import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/topic_summary_model.dart';
import 'topic_summary_repository.dart';

class TopicSummaryRepositoryImpl
    implements TopicSummaryRepository {
  final SupabaseClient client;

  TopicSummaryRepositoryImpl(
    this.client,
  );

  @override
  Future<TopicSummaryModel?> getSummary(
    String topicId,
  ) async {
    final data = await client
        .from('topic_summaries')
        .select()
        .eq('topic_id', topicId)
        .maybeSingle();

    if (data == null) {
      return null;
    }

    return TopicSummaryModel.fromMap(
      data,
    );
  }
}