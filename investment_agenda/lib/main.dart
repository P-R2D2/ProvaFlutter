import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
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
import 'features/portfolios/presentation/providers/portfolio_provider.dart';
import 'features/portfolios/data/repositories/portfolio_repository_impl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'features/advisor/presentation/providers/chat_provider.dart';
import 'features/advisor/domain/usecases/send_message_usecase.dart';
import 'features/advisor/data/repositories/chat_repository_impl.dart';
import 'features/advisor/data/datasources/chat_remote_data_source.dart';
import 'features/advisor/presentation/widgets/floating_chat_widget.dart';

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
        ChangeNotifierProxyProvider<AuthProvider, PortfolioProvider>(
          create: (context) {
            final client = context.read<AuthenticatedHttpClient>();
            return PortfolioProvider(
              repository: PortfolioRepositoryImpl(
                client: client,
                getToken: () async => context.read<AuthProvider>().currentToken ?? '',
              ),
            );
          },
          update: (context, auth, provider) {
            if (auth.isAuthenticated && provider != null && provider.portfolios.isEmpty && !provider.isLoading) {
              provider.fetchPortfolios();
            }
            return provider!;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ChatProvider>(
          create: (context) {
            final client = context.read<AuthenticatedHttpClient>();
            return ChatProvider(
              sendMessageUseCase: SendMessageUseCase(
                ChatRepositoryImpl(
                  remoteDataSource: ChatRemoteDataSourceImpl(
                    baseUrl: 'http://localhost:3000', // Assuming local backend, you might want to use a config
                    client: client,
                    secureStorage: const FlutterSecureStorage(),
                  ),
                ),
              ),
            );
          },
          update: (context, auth, chat) => chat!,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    _router = AppRouter.createRouter(authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Investment Agenda',
      theme: AppTheme.darkTheme,
      routerConfig: _router,
    );
  }
}
