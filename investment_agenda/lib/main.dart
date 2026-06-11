import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/network/authenticated_http_client.dart';
import 'features/investments/presentation/providers/auth_provider.dart';
import 'features/investments/presentation/providers/investment_provider.dart';
import 'features/investments/data/repositories/investment_repository_impl.dart';
import 'features/investments/data/datasources/investments_remote_data_source.dart';
import 'features/assets/presentation/providers/assets_provider.dart';
import 'features/assets/domain/usecases/search_assets_usecase.dart';
import 'features/assets/domain/usecases/get_asset_details_usecase.dart';
import 'features/assets/data/repositories/assets_repository_impl.dart';
import 'features/assets/data/datasources/assets_remote_data_source.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        Provider<AuthenticatedHttpClient>(
          create: (context) => AuthenticatedHttpClient(
            getAccessToken: () async => context.read<AuthProvider>().currentToken,
            refreshTokens: () async => context.read<AuthProvider>().refreshSession(),
            onSessionExpired: () => context.read<AuthProvider>().forceSessionExpired(),
          ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, InvestmentProvider>(
          create: (context) {
            final client = context.read<AuthenticatedHttpClient>();
            return InvestmentProvider(
              repository: InvestmentRepositoryImpl(
                remoteDataSource: InvestmentsRemoteDataSource(client: client),
                getToken: () async => context.read<AuthProvider>().currentToken ?? '',
              ),
            );
          },
          update: (context, auth, provider) {
            if (auth.isAuthenticated && provider != null && provider.investments.isEmpty && !provider.isLoading) {
              provider.loadInvestments();
            }
            return provider!;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, AssetsProvider>(
          create: (context) {
            final client = context.read<AuthenticatedHttpClient>();
            return AssetsProvider(
              searchUseCase: SearchAssetsUseCase(
                AssetsRepositoryImpl(
                  remoteDataSource: AssetsRemoteDataSource(client: client),
                  getToken: () async => context.read<AuthProvider>().currentToken ?? '',
                ),
              ),
              getDetailsUseCase: GetAssetDetailsUseCase(
                AssetsRepositoryImpl(
                  remoteDataSource: AssetsRemoteDataSource(client: client),
                  getToken: () async => context.read<AuthProvider>().currentToken ?? '',
                ),
              ),
            );
          },
          update: (context, auth, assets) => assets!,
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
