import '../models/achievement_model.dart';
import '../models/leaderboard_model.dart';
import '../models/student_points_model.dart';
import '../models/study_streak_model.dart';

abstract class GamificationRepository {

  Future<List<AchievementModel>>
      getAchievements();

  Future<StudentPointsModel>
      getPoints();

  Future<StudyStreakModel>
      getStudyStreak();

  Future<List<LeaderboardModel>>
      getLeaderboard();
}