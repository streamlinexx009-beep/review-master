import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';
import '../services/profile_service.dart';

import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/analytics/screens/student_performance_screen.dart';
import '../../features/analytics/screens/topic_performance_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/batches/screens/batch_details_screen.dart';
import '../../features/batches/screens/batches_screen.dart';
import '../../features/dashboard/screens/instructor_dashboard_screen.dart';
import '../../features/dashboard/screens/student_dashboard_screen.dart';
import '../../features/exams/screens/create_exam_screen.dart';
import '../../features/exams/screens/create_question_screen.dart';
import '../../features/exams/screens/exams_screen.dart';
import '../../features/exams/screens/take_exam_screen.dart';
import '../../features/exams/screens/take_topic_exam_screen.dart';
import '../../features/exams/screens/topic_exam_screen.dart';
import '../../features/flashcards/screens/flashcards_screen.dart';
import '../../features/flashcards/screens/topic_flashcards_screen.dart';
import '../../features/materials/screens/materials_screen.dart';
import '../../features/materials/screens/pdf_viewer_screen.dart';
import '../../features/materials/screens/subject_materials_screen.dart';
import '../../features/materials/screens/upload_material_screen.dart';
import '../../features/practice/screens/practice_history_screen.dart';
import '../../features/practice/screens/practice_quiz_player_screen.dart';
import '../../features/practice/screens/practice_quiz_screen.dart';
import '../../features/quizzes/screens/take_quiz_screen.dart';
import '../../features/results/screens/results_screen.dart';
import '../../features/study_planner/screens/study_planner_screen.dart';
import '../../features/subjects/screens/create_subject_screen.dart';
import '../../features/subjects/screens/subject_details_screen.dart';
import '../../features/subjects/screens/subjects_screen.dart';
import '../../features/summaries/screens/topic_summary_screen.dart';
import '../../features/topics/screens/topic_details_screen.dart';
import '../../features/topics/screens/topics_screen.dart';
import '../../shared/widgets/google_shell.dart';

int _getIndexFromLocation(String location) {
  if (location.startsWith('/subjects') ||
      location.startsWith('/materials') ||
      location.startsWith('/pdf-viewer') ||
      location.startsWith('/flashcards') ||
      location.startsWith('/exams') ||
      location.startsWith('/create-exam') ||
      location.startsWith('/take-exam') ||
      location.startsWith('/take-topic-exam') ||
      location.startsWith('/create-question') ||
      location.startsWith('/results') ||
      location.startsWith('/topics')) {
    return 1;
  }

  if (location.startsWith('/analytics') || location.startsWith('/topic-performance')) return 2;
  if (location.startsWith('/study-planner')) return 3;
  if (location.startsWith('/batches')) return 4;
  return 0;
}

Widget _routeErrorScreen(String message) {
  return Scaffold(
    appBar: AppBar(title: const Text('Something went wrong')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    ),
  );
}

void _goToShellDestination(BuildContext context, int index) {
  switch (index) {
    case 0:
      context.go('/dashboard');
      break;
    case 1:
      context.go('/subjects');
      break;
    case 2:
      context.go('/analytics');
      break;
    case 3:
      context.go('/study-planner');
      break;
    case 4:
      context.go('/batches');
      break;
  }
}

final appRouter = GoRouter(
  initialLocation: '/',
  errorBuilder: (context, state) => _routeErrorScreen(
    state.error?.message ?? 'The requested page could not be opened.',
  ),
  redirect: (context, state) async {
    final loggedIn = AuthService.isLoggedIn;
    const publicRoutes = {'/', '/login', '/register', '/forgot-password'};
    final isPublic = publicRoutes.contains(state.matchedLocation);

    if (!loggedIn && !isPublic) return '/login';

    final role = loggedIn ? await ProfileService.getUserRole() : null;

    if (loggedIn && isPublic) {
      switch (role) {
        case 'admin':
          return '/admin';
        case 'instructor':
          return '/subjects';
        case 'student':
        default:
          return '/dashboard';
      }
    }

    if (role == 'student' && state.matchedLocation.startsWith('/admin')) return '/dashboard';
    if (role == 'student' && state.matchedLocation.startsWith('/instructor')) return '/dashboard';
    if (role == 'instructor' && state.matchedLocation.startsWith('/admin')) return '/subjects';

    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
    ShellRoute(
      builder: (context, state, child) {
        return GoogleShell(
          selectedIndex: _getIndexFromLocation(state.matchedLocation),
          onDestinationSelected: (index) => _goToShellDestination(context, index),
          child: child,
        );
      },
      routes: [
        GoRoute(path: '/dashboard', builder: (context, state) => const StudentDashboardScreen()),
        GoRoute(path: '/batches', builder: (context, state) => const BatchesScreen()),
        GoRoute(path: '/batches/:batchId', builder: (context, state) => BatchDetailsScreen(batchId: state.pathParameters['batchId']!)),
        GoRoute(path: '/subjects', builder: (context, state) => const SubjectsScreen()),
        GoRoute(path: '/create-subject', builder: (context, state) => const CreateSubjectScreen()),
        GoRoute(path: '/subjects/:id', builder: (context, state) => SubjectDetailsScreen(subjectId: state.pathParameters['id']!)),
        GoRoute(path: '/subjects/:id/topics', builder: (context, state) => TopicsScreen(subjectId: state.pathParameters['id']!)),
        GoRoute(path: '/subjects/:id/materials', builder: (context, state) => SubjectMaterialsScreen(subjectId: state.pathParameters['id']!)),
        GoRoute(path: '/subjects/:id/upload-material', builder: (context, state) => UploadMaterialScreen(subjectId: state.pathParameters['id']!)),
        GoRoute(path: '/topics/:topicId', builder: (context, state) => TopicDetailsScreen(topicId: state.pathParameters['topicId']!)),
        GoRoute(path: '/topics/:topicId/summary', builder: (context, state) => TopicSummaryScreen(topicId: state.pathParameters['topicId']!)),
        GoRoute(path: '/topics/:topicId/flashcards', builder: (context, state) => TopicFlashcardsScreen(topicId: state.pathParameters['topicId']!)),
        GoRoute(path: '/topics/:topicId/quiz', builder: (context, state) => TakeQuizScreen(topicId: state.pathParameters['topicId']!)),
        GoRoute(path: '/topics/:topicId/practice', builder: (context, state) => PracticeQuizScreen(topicId: state.pathParameters['topicId']!)),
        GoRoute(path: '/topics/:topicId/practice/history', builder: (context, state) => PracticeHistoryScreen(topicId: state.pathParameters['topicId']!)),
        GoRoute(path: '/topics/:topicId/practice/play', builder: (context, state) => PracticeQuizPlayerScreen(topicId: state.pathParameters['topicId']!)),
        GoRoute(path: '/topics/:topicId/exam', builder: (context, state) => TopicExamScreen(topicId: state.pathParameters['topicId']!)),
        GoRoute(path: '/take-topic-exam/:examId', builder: (context, state) => TakeTopicExamScreen(examId: state.pathParameters['examId']!)),
        GoRoute(path: '/topic-performance', builder: (context, state) => const TopicPerformanceScreen()),
        GoRoute(path: '/materials', builder: (context, state) => const MaterialsScreen()),
        GoRoute(
          path: '/pdf-viewer',
          builder: (context, state) {
            final extra = state.extra;
            if (extra is! Map<String, dynamic>) return _routeErrorScreen('Unable to open this PDF because the file details were missing.');
            final title = extra['title'];
            final pdfUrl = extra['pdfUrl'];
            if (title is! String || pdfUrl is! String || title.isEmpty || pdfUrl.isEmpty) return _routeErrorScreen('Unable to open this PDF because the file details were invalid.');
            return PdfViewerScreen(title: title, pdfUrl: pdfUrl);
          },
        ),
        GoRoute(path: '/flashcards', builder: (context, state) => const FlashcardsScreen()),
        GoRoute(path: '/exams', builder: (context, state) => const ExamsScreen()),
        GoRoute(path: '/create-exam', builder: (context, state) => const CreateExamScreen()),
        GoRoute(path: '/create-question/:examId', builder: (context, state) => CreateQuestionScreen(examId: state.pathParameters['examId']!)),
        GoRoute(path: '/take-exam/:id', builder: (context, state) => TakeExamScreen(examId: state.pathParameters['id']!)),
        GoRoute(path: '/results', builder: (context, state) => const ResultsScreen()),
        GoRoute(path: '/analytics', builder: (context, state) => const StudentPerformanceScreen()),
        GoRoute(path: '/study-planner', builder: (context, state) => const StudyPlannerScreen()),
      ],
    ),
    GoRoute(path: '/admin', builder: (context, state) => const AdminDashboardScreen()),
    GoRoute(path: '/instructor', builder: (context, state) => const InstructorDashboardScreen()),
  ],
);
