import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/achievement_model.dart';
import '../models/leaderboard_model.dart';
import '../models/student_points_model.dart';
import '../models/study_streak_model.dart';
import 'gamification_repository.dart';

class GamificationRepositoryImpl implements GamificationRepository {
  final SupabaseClient client;

  GamificationRepositoryImpl(this.client);

  User _requireUser() {
    final user = client.auth.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    return user;
  }

  @override
  Future<List<AchievementModel>> getAchievements() async {
    final data = await client.from('achievements').select().order('points');

    return data.map<AchievementModel>((e) => AchievementModel.fromMap(e)).toList();
  }

  @override
  Future<StudentPointsModel> getPoints() async {
    final user = _requireUser();

    final data = await client
        .from('student_points')
        .select()
        .eq('student_id', user.id)
        .maybeSingle();

    if (data == null) {
      return const StudentPointsModel(points: 0, level: 1);
    }

    return StudentPointsModel.fromMap(data);
  }

  @override
  Future<StudyStreakModel> getStudyStreak() async {
    final user = _requireUser();

    final data = await client
        .from('study_streaks')
        .select()
        .eq('student_id', user.id)
        .maybeSingle();

    if (data == null) {
      return const StudyStreakModel(currentStreak: 0, longestStreak: 0);
    }

    return StudyStreakModel.fromMap(data);
  }

  @override
  Future<List<LeaderboardModel>> getLeaderboard() async {
    final data = await client
        .from('student_points')
        .select()
        .order('points', ascending: false)
        .limit(50);

    return data.map<LeaderboardModel>((e) => LeaderboardModel.fromMap(e)).toList();
  }
}
