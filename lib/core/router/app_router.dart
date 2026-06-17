import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';
import '../services/profile_service.dart';

import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';

import '../../features/dashboard/screens/student_dashboard_screen.dart';
import '../../features/dashboard/screens/instructor_dashboard_screen.dart';

import '../../features/subjects/screens/subjects_screen.dart';
import '../../features/materials/screens/materials_screen.dart';
import '../../features/flashcards/screens/flashcards_screen.dart';
import '../../features/exams/screens/exams_screen.dart';
import '../../features/analytics/screens/analytics_dashboard_screen.dart';

import '../../features/admin/screens/admin_dashboard_screen.dart';

import '../../shared/widgets/google_shell.dart';
import '../../features/subjects/screens/subject_details_screen.dart';

import '../../features/materials/screens/upload_material_screen.dart';
import '../../features/materials/screens/subject_materials_screen.dart';
import '../../features/subjects/screens/create_subject_screen.dart';

import '../../features/materials/screens/pdf_viewer_screen.dart';
import '../../features/exams/screens/create_exam_screen.dart';
import '../../features/exams/screens/take_exam_screen.dart';
import '../../features/exams/screens/create_question_screen.dart';
import '../../features/results/screens/results_screen.dart';
import '../../features/batches/screens/batches_screen.dart';
import '../../features/batches/screens/batch_details_screen.dart';
import '../../features/topics/screens/topics_screen.dart';
import '../../features/topics/screens/topic_details_screen.dart';
import '../../features/topics/screens/summary_screen.dart';
import '../../features/flashcards/screens/topic_flashcards_screen.dart';
import '../../features/summaries/screens/topic_summary_screen.dart';
import '../../features/quizzes/screens/take_quiz_screen.dart';
import '../../features/exams/screens/topic_exam_screen.dart';
import '../../features/exams/screens/take_topic_exam_screen.dart';
import '../../features/practice/screens/practice_quiz_screen.dart';
import '../../features/practice/screens/practice_quiz_player_screen.dart';
import '../../features/practice/screens/practice_history_screen.dart';

import '../../features/analytics/screens/topic_performance_screen.dart';
import '../../features/study_planner/screens/study_planner_screen.dart';


int _getIndexFromLocation(String location) {
  switch (location) {
    case '/dashboard':
      return 0;

    case '/subjects':
      return 1;

    case '/materials':
      return 2;

    case '/flashcards':
      return 3;

    case '/exams':
      return 4;

    case '/results':
      return 5;

    case '/analytics':
      return 6;
      
    case '/study-planner':
      return 7;

    case '/batches':
      return 8;

    default:
      return 0;
  }
}

final appRouter = GoRouter(
  initialLocation: '/',

  redirect: (context, state) async {
    final loggedIn = AuthService.isLoggedIn;

    const publicRoutes = {
      '/',
      '/login',
      '/register',
      '/forgot-password',
    };

    final isPublic = publicRoutes.contains(
      state.matchedLocation,
    );

    if (!loggedIn && !isPublic) {
      return '/login';
    }

    String? role;

    if (loggedIn) {
      role = await ProfileService.getUserRole();
    }

    // User already logged in
    if (loggedIn && isPublic) {
      switch (role) {
        case 'admin':
          return '/admin';

        case 'instructor':
          return '/instructor';

        case 'student':
        default:
          return '/dashboard';
      }
    }

    // Student protection
    if (role == 'student' &&
        state.matchedLocation.startsWith('/admin')) {
      return '/dashboard';
    }

    if (role == 'student' &&
        state.matchedLocation.startsWith('/instructor')) {
      return '/dashboard';
    }

    // Instructor protection
    if (role == 'instructor' &&
        state.matchedLocation.startsWith('/admin')) {
      return '/instructor';
    }

    return null;
  },

  routes: [
    // Authentication Routes
    GoRoute(
      path: '/',
      builder: (context, state) =>
          const SplashScreen(),
    ),

    GoRoute(
      path: '/login',
      builder: (context, state) =>
          const LoginScreen(),
    ),

    GoRoute(
      path: '/register',
      builder: (context, state) =>
          const RegisterScreen(),
    ),

    GoRoute(
      path: '/forgot-password',
      builder: (context, state) =>
          const ForgotPasswordScreen(),
    ),

    // Student Google UI Shell
    ShellRoute(
      builder: (
        context,
        state,
        child,
      ) {
        return GoogleShell(
          selectedIndex: _getIndexFromLocation(
            state.matchedLocation,
          ),
     onDestinationSelected: (index) {
  switch (index) {
    case 0:
      context.go('/dashboard');
      break;

    case 1:
      context.go('/subjects');
      break;

    case 2:
      context.go('/materials');
      break;

    case 3:
      context.go('/flashcards');
      break;

    case 4:
      context.go('/exams');
      break;

    case 5:
      context.go('/results');
      break;

    case 6:
      context.go('/analytics');
      break;
    case 7:
      context.go('/study-planner');
      break;

    case 8:
      context.go('/batches');
      break;
  }
},
          child: child,
        );
      },
      routes: [
  GoRoute(
    path: '/dashboard',
    builder: (context, state) =>
        const StudentDashboardScreen(),
  ),

  GoRoute(
  path: '/batches',
  builder: (
    context,
    state,
  ) =>
      const BatchesScreen(),
),

GoRoute(
  path: '/batches/:batchId',
  builder: (context, state) {
    final batchId =
        state.pathParameters['batchId']!;

    return BatchDetailsScreen(
      batchId: batchId,
    );
  },
),

  GoRoute(
    path: '/subjects',
    builder: (context, state) =>
        const SubjectsScreen(),
  ),

  GoRoute(
    path: '/create-subject',
    builder: (context, state) =>
        const CreateSubjectScreen(),
  ),

  GoRoute(
    path: '/subjects/:id',
    builder: (context, state) {
      final subjectId =
          state.pathParameters['id']!;

      return SubjectDetailsScreen(
        subjectId: subjectId,
      );
    },
  ),

  GoRoute(
  path: '/subjects/:id/topics',
  builder: (context, state) {
    final subjectId =
        state.pathParameters['id']!;

    return TopicsScreen(
      subjectId: subjectId,
    );
  },
),

GoRoute(
  path: '/topics/:topicId',
  builder: (context, state) {
    final topicId =
        state.pathParameters['topicId']!;

    return TopicDetailsScreen(
      topicId: topicId,
    );
  },
),

GoRoute(
  path: '/topics/:topicId/summary',
  builder: (context, state) {
    return TopicSummaryScreen(
      topicId:
          state.pathParameters['topicId']!,
    );
  },
),
GoRoute(
  path: '/topics/:topicId/flashcards',
  builder: (context, state) {
    final topicId =
        state.pathParameters['topicId']!;

    return TopicFlashcardsScreen(
      topicId: topicId,
    );
  },
),

GoRoute(
  path: '/topics/:topicId/quiz',
  builder: (context, state) {
    return TakeQuizScreen(
      topicId:
          state.pathParameters[
              'topicId']!,
    );
  },
),

GoRoute(
  path: '/topics/:topicId/practice',
  builder: (context, state) {
    return PracticeQuizScreen(
      topicId:
          state.pathParameters['topicId']!,
    );
  },
),

GoRoute(
  path:
      '/topics/:topicId/practice/history',
  builder: (
    context,
    state,
  ) {
    return PracticeHistoryScreen(
      topicId:
          state.pathParameters[
              'topicId']!,
    );
  },
),

GoRoute(
  path: '/topic-performance',
  builder: (context, state) =>
      const TopicPerformanceScreen(),
),

GoRoute(
  path: '/topics/:topicId/practice/play',
  builder: (context, state) {
    return PracticeQuizPlayerScreen(
      topicId:
          state.pathParameters['topicId']!,
    );
  },
),

GoRoute(
  path: '/topics/:topicId/exam',
  builder: (context, state) {
    final topicId =
        state.pathParameters['topicId']!;

    return TopicExamScreen(
      topicId: topicId,
    );
  },
),


GoRoute(
  path: '/take-topic-exam/:examId',
  builder: (context, state) {
    return TakeTopicExamScreen(
      examId:
          state.pathParameters['examId']!,
    );
  },
),

  GoRoute(
    path: '/subjects/:id/materials',
    builder: (context, state) {
      final subjectId =
          state.pathParameters['id']!;

      return SubjectMaterialsScreen(
        subjectId: subjectId,
      );
    },
  ),

  GoRoute(
    path: '/subjects/:id/upload-material',
    builder: (context, state) {
      final subjectId =
          state.pathParameters['id']!;

      return UploadMaterialScreen(
        subjectId: subjectId,
      );
    },
  ),

  GoRoute(
    path: '/materials',
    builder: (context, state) =>
        const MaterialsScreen(),
  ),

GoRoute(
  path: '/pdf-viewer',
  builder: (context, state) {
    final extra =
        state.extra
            as Map<String, dynamic>;

    return PdfViewerScreen(
      title:
          extra['title'] as String,
      pdfUrl:
          extra['pdfUrl'] as String,
    );
  },
),

  GoRoute(
    path: '/flashcards',
    builder: (context, state) =>
        const FlashcardsScreen(),
  ),

  GoRoute(
    path: '/exams',
    builder: (context, state) =>
        const ExamsScreen(),
  ),

  GoRoute(
  path: '/create-exam',
  builder: (context, state) =>
      const CreateExamScreen(),
),

GoRoute(
  path: '/create-question/:examId',
  builder: (context, state) {
    final examId =
        state.pathParameters['examId']!;

    return CreateQuestionScreen(
      examId: examId,
    );
  },
),

GoRoute(
  path: '/take-exam/:id',
  builder: (context, state) {
    final examId =
        state.pathParameters['id']!;

    return TakeExamScreen(
      examId: examId,
    );
  },
),

GoRoute(
  path: '/results',
  builder: (
    context,
    state,
  ) =>
      const ResultsScreen(),
),


  GoRoute(
    path: '/analytics',
    builder: (context, state) =>
        const AnalyticsDashboardScreen(),
  ),

  GoRoute(
  path: '/study-planner',
  builder: (context, state) =>
      const StudyPlannerScreen(),
),

],
    ),



    // Admin Area
    GoRoute(
      path: '/admin',
      builder: (context, state) =>
          const AdminDashboardScreen(),
    ),

    // Instructor Area
    GoRoute(
      path: '/instructor',
      builder: (context, state) =>
          const InstructorDashboardScreen(),
    ),
  ],
);