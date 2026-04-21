import 'package:go_router/go_router.dart';
import '../../features/investments/presentation/pages/login_page.dart';
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
        final isLoggingIn = state.matchedLocation == '/login';

        if (!isAuthenticated && !isLoggingIn) return '/login';
        if (isAuthenticated && isLoggingIn) return '/';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
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
