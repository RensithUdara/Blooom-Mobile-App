import 'package:flutter/material.dart';

import '../viewmodels/app_scope.dart';
import '../widgets/common/gradient_background.dart';
import 'calendar_page.dart';
import 'home_page.dart';
import 'insights_page.dart';
import 'logs_page.dart';
import 'settings_page.dart';

class HomeShellPage extends StatelessWidget {
  const HomeShellPage({super.key});

  static const _pages = [
    HomePage(),
    CalendarPage(),
    InsightsPage(),
    LogsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final vm = AppScope.of(context);
    return AnimatedBuilder(
      animation: vm,
      builder: (context, _) {
        return GradientBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 320),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        final offset = Tween<Offset>(
                          begin: const Offset(0.04, 0),
                          end: Offset.zero,
                        ).animate(animation);
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: offset,
                            child: child,
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey(vm.selectedTab),
                        child: _pages[vm.selectedTab],
                      ),
                    ),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: NavigationBar(
                  selectedIndex: vm.selectedTab,
                  onDestinationSelected: vm.setTab,
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.calendar_month_outlined),
                      label: 'Calendar',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.insights_outlined),
                      label: 'Insights',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.add_circle_outline),
                      label: 'Logs',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_outline),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
