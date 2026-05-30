import 'package:go_router/go_router.dart';
import '../../features/investments/presentation/pages/login_page.dart';
import '../../features/investments/presentation/pages/register_page.dart';
import '../../features/investments/presentation/pages/dashboard_page.dart';
import '../../features/investments/presentation/pages/investment_form_page.dart';
import '../../features/investments/presentation/pages/onboarding_chat_page.dart';
import '../../features/investments/presentation/providers/auth_provider.dart';
import '../../features/investments/domain/entities/investment.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isEntrevistaConcluida = authProvider.entrevistaConcluida;
        final location = state.matchedLocation;
        final isPublic = location == '/login' || location == '/register';

        if (!isAuthenticated && !isPublic) return '/login';
        
        if (isAuthenticated) {
          if (!isEntrevistaConcluida && location != '/onboarding') {
            return '/onboarding';
          }
          if (isEntrevistaConcluida && location == '/onboarding') {
            return '/';
          }
          if (isPublic) {
            return !isEntrevistaConcluida ? '/onboarding' : '/';
          }
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingChatPage(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: '/add',
          builder: (context, state) => const InvestmentFormPage(),
        ),
        GoRoute(
          path: '/edit',
          builder: (context, state) {
            final investment = state.extra as Investment?;
            return InvestmentFormPage(investment: investment);
          },
        ),
      ],
    );
  }
}
