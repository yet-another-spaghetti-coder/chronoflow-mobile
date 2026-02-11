import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:chronoflow/core/di/service_locator.dart';
import 'package:chronoflow/features/app/routes.dart';
import 'package:chronoflow/features/app/themes.dart';
import 'package:chronoflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<AuthBloc>()),
      ],
      child: AdaptiveApp.router(
        title: 'ChronoFlow',
        themeMode: ThemeMode.system,
        materialLightTheme: AppThemes.materialLightTheme,
        materialDarkTheme: AppThemes.materialDarkTheme,
        cupertinoLightTheme: AppThemes.cupertinoLightTheme,
        cupertinoDarkTheme: AppThemes.cupertinoDarkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
