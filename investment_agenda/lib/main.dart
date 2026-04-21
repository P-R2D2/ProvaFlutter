import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/investments/presentation/providers/auth_provider.dart';
import 'features/investments/presentation/providers/investment_provider.dart';
import 'features/investments/data/repositories/investment_repository_impl.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => InvestmentProvider(
            repository: InvestmentRepositoryImpl(),
          )..loadInvestments(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return MaterialApp.router(
      title: 'Investment Agenda',
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.createRouter(authProvider),
    );
  }
}
