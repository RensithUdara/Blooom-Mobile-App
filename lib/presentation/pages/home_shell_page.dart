import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../viewmodels/app_scope.dart';
import '../widgets/common/gradient_background.dart';
import 'calendar_page.dart';
import 'home_page.dart';
import 'insights_page.dart';
import 'logs_page.dart';
import 'settings_page.dart';

class HomeShellPage extends StatefulWidget {
  const HomeShellPage({super.key});

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  static const _pages = [
    HomePage(),
    CalendarPage(),
    InsightsPage(),
    LogsPage(),
    SettingsPage(),
  ];

  static const _items = [
    _BottomNavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
    _BottomNavItem(
      Icons.calendar_month_outlined,
      Icons.calendar_month_rounded,
      'Calendar',
    ),
    _BottomNavItem(Icons.insights_outlined, Icons.insights_rounded, 'Insights'),
    _BottomNavItem(Icons.add_circle_outline, Icons.add_circle, 'Logs'),
    _BottomNavItem(Icons.person_outline, Icons.person_rounded, 'Profile'),
  ];

  int _previousTab = 0;

  @override
  Widget build(BuildContext context) {
    final vm = AppScope.of(context);
    return AnimatedBuilder(
      animation: vm,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            return GradientBackground(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: SafeArea(
                  child: vm.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : isWide
                      ? Row(
                          children: [
                            _DesktopSideNav(
                              items: _items,
                              selectedIndex: vm.selectedTab,
                              onSelected: (index) => _selectTab(vm, index),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 1180,
                                    ),
                                    child: _AnimatedPageSwitcher(
                                      selectedTab: vm.selectedTab,
                                      previousTab: _previousTab,
                                      child: _pages[vm.selectedTab],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Align(
                          alignment: Alignment.topCenter,
                          child: _AnimatedPageSwitcher(
                            selectedTab: vm.selectedTab,
                            previousTab: _previousTab,
                            child: _pages[vm.selectedTab],
                          ),
                        ),
                ),
                bottomNavigationBar: isWide
                    ? null
                    : _AnimatedBottomBar(
                        items: _items,
                        selectedIndex: vm.selectedTab,
                        onSelected: (index) => _selectTab(vm, index),
                      ),
              ),
            );
          },
        );
      },
    );
  }

  void _selectTab(dynamic vm, int index) {
    if (index == vm.selectedTab) return;
    setState(() => _previousTab = vm.selectedTab);
    vm.setTab(index);
  }
}

class _AnimatedPageSwitcher extends StatelessWidget {
  const _AnimatedPageSwitcher({
    required this.selectedTab,
    required this.previousTab,
    required this.child,
  });

  final int selectedTab;
  final int previousTab;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final selectedKey = ValueKey('page-$selectedTab');
        final isIncoming = child.key == selectedKey;
        final direction = selectedTab >= previousTab ? 1.0 : -1.0;
        final offset = Tween<Offset>(
          begin: Offset((isIncoming ? 0.10 : -0.05) * direction, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        final scale = Tween<double>(
          begin: 0.985,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return ClipRect(
          child: FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: animation.drive(offset),
              child: ScaleTransition(
                scale: animation.drive(scale),
                child: child,
              ),
            ),
          ),
        );
      },
      child: KeyedSubtree(key: ValueKey('page-$selectedTab'), child: child),
    );
  }
}

class _DesktopSideNav extends StatelessWidget {
  const _DesktopSideNav({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_BottomNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 248,
      margin: const EdgeInsets.fromLTRB(18, 18, 0, 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.34),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(AppConstants.logoAsset, width: 48, height: 48),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppConstants.appName, style: theme.textTheme.titleLarge),
                  Text(
                    'Health companion',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          for (var i = 0; i < items.length; i++)
            _DesktopSideNavItem(
              item: items[i],
              selected: i == selectedIndex,
              onTap: () => onSelected(i),
            ),
          const Spacer(),
          Text(
            'Private on this device',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopSideNavItem extends StatelessWidget {
  const _DesktopSideNavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _BottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: selected
                ? LinearGradient(
                    colors: [
                      AppColors.rose200.withValues(alpha: 0.82),
                      AppColors.rose300.withValues(alpha: 0.44),
                    ],
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                selected ? item.selectedIcon : item.icon,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Text(
                item.label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedBottomBar extends StatelessWidget {
  const _AnimatedBottomBar({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_BottomNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.22 : 0.16,
              ),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Material(
            color: theme.colorScheme.surface.withValues(alpha: 0.94),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: _AnimatedBottomBarItem(
                        item: items[i],
                        selected: i == selectedIndex,
                        onTap: () => onSelected(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedBottomBarItem extends StatelessWidget {
  const _AnimatedBottomBarItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _BottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;
    final idleColor = theme.colorScheme.onSurfaceVariant;
    return Semantics(
      selected: selected,
      button: true,
      label: item.label,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: selected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.rose200.withValues(alpha: 0.82),
                      AppColors.rose300.withValues(alpha: 0.46),
                    ],
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutBack,
                scale: selected ? 1.12 : 1,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Icon(
                    selected ? item.selectedIcon : item.icon,
                    key: ValueKey('${item.label}-$selected'),
                    size: selected ? 23 : 22,
                    color: selected ? selectedColor : idleColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                style: theme.textTheme.labelSmall!.copyWith(
                  fontSize: selected ? 11 : 10,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  color: selected ? theme.colorScheme.onSurface : idleColor,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem {
  const _BottomNavItem(this.icon, this.selectedIcon, this.label);

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
