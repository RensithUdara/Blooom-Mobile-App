import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../presentation/pages/startup_page.dart';
import '../presentation/viewmodels/app_scope.dart';
import '../presentation/viewmodels/app_view_model.dart';

class BlooomApp extends StatelessWidget {
  const BlooomApp({super.key, required this.viewModel});

  final AppViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      viewModel: viewModel,
      child: AnimatedBuilder(
        animation: viewModel,
        builder: (context, _) {
          return MaterialApp(
            title: 'Blooom',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: viewModel.themeMode,
            home: const StartupPage(),
          );
        },
      ),
    );
  }
}
