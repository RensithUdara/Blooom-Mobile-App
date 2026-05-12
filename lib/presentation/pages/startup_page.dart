import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../viewmodels/app_scope.dart';
import '../widgets/common/gradient_background.dart';
import 'home_shell_page.dart';
import 'onboarding_page.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  bool _showSplash = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() => _showSplash = false);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = AppScope.of(context);
    return AnimatedBuilder(
      animation: vm,
      builder: (context, _) {
        if (_showSplash || vm.isLoading) {
          return const SplashPage();
        }
        if (!vm.profile.onboardingCompleted) {
          return const OnboardingPage();
        }
        return const HomeShellPage();
      },
    );
  }
}

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 132,
                  height: 132,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.88),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.22,
                        ),
                        blurRadius: 36,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Image.asset(AppConstants.logoAsset),
                ),
                const SizedBox(height: 22),
                Text(
                  AppConstants.appName,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(AppConstants.tagline),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
