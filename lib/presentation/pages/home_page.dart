import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/bloom_date_utils.dart';
import '../viewmodels/app_scope.dart';
import '../widgets/common/animated_content.dart';
import '../widgets/common/metric_tile.dart';
import '../widgets/common/soft_card.dart';
import '../widgets/home/cycle_ring.dart';
import 'log_period_sheet.dart';
import 'log_wellness_sheet.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = AppScope.of(context);
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: vm,
      builder: (context, _) {
        return AnimatedPageList(
          children: [
            Row(
              children: [
                Hero(
                  tag: 'blooom-logo',
                  child: Image.asset(
                    AppConstants.logoAsset,
                    width: 52,
                    height: 52,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vm.profile.name.trim().isEmpty
                            ? 'Welcome to Blooom'
                            : 'Hi, ${vm.profile.name}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'How do you feel today?',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => vm.toggleDarkMode(!vm.profile.darkMode),
                  icon: Icon(
                    vm.profile.darkMode ? Icons.light_mode : Icons.dark_mode,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SoftCard(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.primary.withValues(alpha: 0.10),
                  AppColors.lemon.withValues(alpha: 0.16),
                ],
              ),
              child: Column(
                children: [
                  CycleRing(
                    day: vm.currentCycleDay,
                    cycleLength: vm.averageCycleLength,
                    phase: vm.currentPhase,
                  ),
                  FilledButton.icon(
                    onPressed: () => showLogPeriodSheet(context),
                    icon: const Icon(Icons.favorite),
                    label: const Text('Log Period'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.18,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                MetricTile(
                  icon: Icons.event_available,
                  label: 'Next period',
                  value: '${vm.daysUntilNextPeriod} days',
                  color: AppColors.rose400,
                ),
                MetricTile(
                  icon: Icons.bubble_chart,
                  label: 'Ovulation',
                  value: BloomDateUtils.dayMonth(vm.ovulationDate),
                  color: AppColors.lavender,
                ),
                MetricTile(
                  icon: Icons.repeat,
                  label: 'Cycle length',
                  value: '${vm.averageCycleLength} days',
                  color: AppColors.sky,
                ),
                MetricTile(
                  icon: Icons.water_drop,
                  label: 'Period length',
                  value: '${vm.averagePeriodLength} days',
                  color: AppColors.mint,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Smart insight', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Your fertile window is predicted around '
                    '${BloomDateUtils.dayMonth(vm.fertileStart)} - '
                    '${BloomDateUtils.dayMonth(vm.fertileEnd)}. '
                    'Cycle confidence is ${(vm.cycleRegularityScore * 100).round()}%.',
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => showLogWellnessSheet(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Daily log'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: vm.addNextPeriodToCalendar,
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('Google Calendar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
