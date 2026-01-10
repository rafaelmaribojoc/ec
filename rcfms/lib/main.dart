import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'core/constants/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/services/router_service.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/moca/bloc/moca_assessment_bloc.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/resident_repository.dart';
import 'data/repositories/form_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow all orientations for responsive design
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const RCFMSApp());
}

class RCFMSApp extends StatelessWidget {
  const RCFMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => ResidentRepository()),
        RepositoryProvider(create: (_) => FormRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            )..add(AuthCheckRequested()),
          ),
          BlocProvider(
            create: (context) => MocaAssessmentBloc(),
          ),
        ],
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return MaterialApp.router(
              title: 'RCFMS - Resident Care & Facility Management',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: ThemeMode.light,
              routerConfig: RouterService.router,
            );
          },
        ),
      ),
    );
  }
}
