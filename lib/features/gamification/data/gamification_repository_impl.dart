import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/achievement_model.dart';
import '../models/leaderboard_model.dart';
import '../models/student_points_model.dart';
import '../models/study_streak_model.dart';
import 'gamification_repository.dart';

class GamificationRepositoryImpl
    implements GamificationRepository {
  final SupabaseClient client;

  GamificationRepositoryImpl(
    this.client,
  );

  @override
  Future<List<AchievementModel>>
      getAchievements() async {
    final data = await client
        .from('achievements')
        .select();

    return data
        .map<AchievementModel>(
          (e) =>
              AchievementModel.fromMap(e),
        )
        .toList();
  }

  @override
  Future<StudentPointsModel>
      getPoints() async {
    final user =
        client.auth.currentUser!;

    final data = await client
        .from('student_points')
        .select()
        .eq(
          'student_id',
          user.id,
        )
        .single();

    return StudentPointsModel
        .fromMap(data);
  }

  @override
  Future<StudyStreakModel>
      getStudyStreak() async {
    final user =
        client.auth.currentUser!;

    final data = await client
        .from('study_streaks')
        .select()
        .eq(
          'student_id',
          user.id,
        )
        .single();

    return StudyStreakModel
        .fromMap(data);
  }

  @override
  Future<List<LeaderboardModel>>
      getLeaderboard() async {
    final data = await client
        .from('student_points')
        .select()
        .order(
          'points',
          ascending: false,
        );

    return data
        .map<LeaderboardModel>(
          (e) =>
              LeaderboardModel.fromMap(e),
        )
        .toList();
  }
}