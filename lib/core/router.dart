import 'package:go_router/go_router.dart';
import '../features/splash/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/home/home_screen.dart';
import '../features/plan/plan_screen.dart';
import '../features/search/search_screen.dart';
import '../features/compare/compare_screen.dart';
import '../features/favoris/favoris_screen.dart';
import '../features/profil/profil_screen.dart';
import '../features/avis/avis_screen.dart';
import '../features/apropos/apropos_screen.dart';
import '../domain/entities/compte_entity.dart';

class AppRoutes {
  static const splash      = '/';
  static const onboarding  = '/onboarding';
  static const home        = '/home';
  static const plan        = '/plan';
  static const search      = '/search';
  static const compare     = '/compare';
  static const favoris     = '/favoris';
  static const profil      = '/profil';
  static const avis        = '/avis';       // ✅ nouveau
  static const apropos     = '/apropos';    // ✅ nouveau
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '${AppRoutes.plan}/:type',
      builder: (context, state) {
        final type = state.pathParameters['type']!;
        final plan = PlanComptable.values.firstWhere(
          (p) => p.name == type,
          orElse: () => PlanComptable.syscohada,
        );
        return PlanScreen(plan: plan);
      },
    ),
    GoRoute(
      path: AppRoutes.search,
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: AppRoutes.compare,
      builder: (context, state) => const CompareScreen(),
    ),
    GoRoute(
      path: AppRoutes.favoris,
      builder: (context, state) => const FavorisScreen(),
    ),
    GoRoute(
      path: AppRoutes.profil,
      builder: (context, state) => const ProfilScreen(),
    ),
    GoRoute(
      path: AppRoutes.avis,
      builder: (context, state) => const AvisScreen(),    // ✅ nouveau
    ),
    GoRoute(
      path: AppRoutes.apropos,
      builder: (context, state) => const AproposScreen(), // ✅ nouveau
    ),
  ],
);