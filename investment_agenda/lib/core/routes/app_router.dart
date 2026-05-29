import 'package:go_router/go_router.dart';
import '../../features/investments/presentation/pages/login_page.dart';
import '../../features/investments/presentation/pages/register_page.dart';
import '../../features/investments/presentation/pages/dashboard_page.dart';
import '../../features/investments/presentation/pages/investment_form_page.dart';
import '../../features/investments/presentation/providers/auth_provider.dart';
import '../../features/investments/domain/entities/investment.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final location = state.matchedLocation;
        final isPublic = location == '/login' || location == '/register';

        if (!isAuthenticated && !isPublic) return '/login';
        if (isAuthenticated && isPublic) return '/';
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
