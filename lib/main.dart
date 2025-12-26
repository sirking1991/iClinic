import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/components/scaffold_with_nav.dart';
import 'core/components/command_k_wrapper.dart';
import 'core/security/auto_lock_service.dart';
import 'core/security/auto_lock_wrapper.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/patient/presentation/patient_list_screen.dart';
import 'features/patient/presentation/patient_detail_screen.dart';
import 'features/auth/presentation/lock_screen.dart';
import 'features/auth/presentation/setup_screen.dart';
import 'features/auth/presentation/profile_screen.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/schedule/presentation/schedule_screen.dart';

void main() {
  runApp(const ProviderScope(child: IClinicApp()));
}

final routerProvider = Provider<GoRouter>((ref) {
  final autoLockService = ref.watch(autoLockProvider);

  return GoRouter(
    initialLocation: '/patients',
    refreshListenable: autoLockService,
    redirect: (context, state) {
      final authState = ref.watch(authStateProvider);

      // If still loading account status, don't redirect yet
      if (authState.isLoading) return null;

      final hasAccount = authState.value ?? false;
      final isSetupScreen = state.uri.toString() == '/setup';

      if (!hasAccount && !isSetupScreen) {
        return '/setup';
      }

      if (hasAccount && isSetupScreen) {
        return '/patients';
      }

      final isLocked = autoLockService.isLocked;
      final isLockScreen = state.uri.toString() == '/lock';

      if (isLocked && !isLockScreen && hasAccount) {
        return '/lock';
      }
      if (!isLocked && isLockScreen) {
        return '/patients';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/setup', builder: (context, state) => const SetupScreen()),
      GoRoute(path: '/lock', builder: (context, state) => const LockScreen()),
      ShellRoute(
        builder: (context, state, child) => ScaffoldWithNav(
          child: CommandKWrapper(child: AutoLockWrapper(child: child)),
        ),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: '/patients',
            builder: (context, state) {
              final showAddDialog =
                  state.uri.queryParameters['action'] == 'new';
              return PatientListScreen(showAddDialog: showAddDialog);
            },
          ),
          GoRoute(
            path: '/patient/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '0';
              return PatientDetailScreen(patientId: id);
            },
          ),
          GoRoute(
            path: '/schedule',
            builder: (context, state) {
              final showAddDialog =
                  state.uri.queryParameters['action'] == 'new';
              return ScheduleScreen(showAddDialog: showAddDialog);
            },
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

class IClinicApp extends ConsumerWidget {
  const IClinicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Start manual timer on app start (or rely on first interaction)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(autoLockProvider).startTimer();
    });

    return MaterialApp.router(
      title: 'iClinic',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
