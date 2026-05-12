import 'dart:async';
import 'dart:math' as math;

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
        if (vm.profile.usesDeviceLock && !vm.isAppUnlocked) {
          return const DeviceLockPage();
        }
        if (vm.profile.usesPinLock && !vm.isAppUnlocked) {
          return const PinUnlockPage();
        }
        return const HomeShellPage();
      },
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _fadeIn;
  late final Animation<double> _titleSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..forward();
    _logoScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.10, 0.62, curve: Curves.easeOutBack),
    );
    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.18, 0.86, curve: Curves.easeOutCubic),
    );
    _titleSlide = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.38, 0.92, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size.square(214),
                            painter: _SplashBloomPainter(
                              progress: _fadeIn.value,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Transform.scale(
                            scale: 0.72 + (_logoScale.value * 0.28),
                            child: Opacity(
                              opacity: _fadeIn.value,
                              child: Container(
                                width: 134,
                                height: 134,
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface.withValues(
                                    alpha: 0.9,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.16,
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.24),
                                      blurRadius: 40,
                                      offset: const Offset(0, 18),
                                    ),
                                  ],
                                ),
                                child: Image.asset(AppConstants.logoAsset),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(0, 20 * (1 - _titleSlide.value)),
                      child: Opacity(
                        opacity: _titleSlide.value,
                        child: Column(
                          children: [
                            Text(
                              AppConstants.appName,
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppConstants.tagline,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 28),
                            _SplashProgress(progress: _controller.value),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashProgress extends StatelessWidget {
  const _SplashProgress({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 118,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: LinearProgressIndicator(
          minHeight: 5,
          value: progress.clamp(0.08, 1),
          color: theme.colorScheme.primary,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
        ),
      ),
    );
  }
}

class _SplashBloomPainter extends CustomPainter {
  _SplashBloomPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final petalPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = color.withValues(alpha: 0.24 * progress);
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withValues(alpha: 0.035 * progress);

    for (var i = 0; i < 8; i++) {
      final angle = (math.pi * 2 / 8) * i + progress * 0.18;
      final petalCenter =
          center + Offset(math.cos(angle), math.sin(angle)) * 34;
      final rect = Rect.fromCenter(
        center: petalCenter,
        width: 86 * progress,
        height: 132 * progress,
      );
      canvas.save();
      canvas.translate(petalCenter.dx, petalCenter.dy);
      canvas.rotate(angle);
      canvas.translate(-petalCenter.dx, -petalCenter.dy);
      canvas.drawOval(rect, fillPaint);
      canvas.drawOval(rect, petalPaint);
      canvas.restore();
    }

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color.withValues(alpha: 0.10 * progress);
    canvas.drawCircle(center, 94 * progress, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _SplashBloomPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class DeviceLockPage extends StatefulWidget {
  const DeviceLockPage({super.key});

  @override
  State<DeviceLockPage> createState() => _DeviceLockPageState();
}

class _DeviceLockPageState extends State<DeviceLockPage> {
  bool _authStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_authStarted) return;
    _authStarted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
  }

  Future<void> _unlock() async {
    final unlocked = await AppScope.of(context).authenticateAppLock();
    if (!unlocked && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not unlock Blooom.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 118,
                      height: 118,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.18,
                            ),
                            blurRadius: 34,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Image.asset(AppConstants.logoAsset),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Blooom is locked',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use your device lock or biometric authentication to continue.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _unlock,
                        icon: const Icon(Icons.lock_open),
                        label: const Text('Unlock'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PinUnlockPage extends StatefulWidget {
  const PinUnlockPage({super.key});

  @override
  State<PinUnlockPage> createState() => _PinUnlockPageState();
}

class _PinUnlockPageState extends State<PinUnlockPage> {
  final _pinController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppConstants.logoAsset,
                      width: 110,
                      height: 110,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Enter PIN',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unlock Blooom to view your private health data.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _pinController,
                      autofocus: true,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: 'Blooom PIN',
                        errorText: _error,
                        counterText: '',
                      ),
                      onSubmitted: (_) => _unlockWithPin(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _unlockWithPin,
                        icon: const Icon(Icons.lock_open),
                        label: const Text('Unlock'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _unlockWithPin() async {
    final pin = _pinController.text.trim();
    if (!RegExp(r'^\d{4,6}$').hasMatch(pin)) {
      setState(() => _error = 'Enter your PIN.');
      return;
    }

    final unlocked = await AppScope.of(context).unlockWithPin(pin);
    if (!unlocked && mounted) {
      setState(() => _error = 'Incorrect PIN.');
      _pinController.clear();
    }
  }
}
