import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/bloom_date_utils.dart';
import '../viewmodels/app_scope.dart';
import '../widgets/common/animated_content.dart';
import '../widgets/common/calendar_export.dart';
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
        final cycleCard = SoftCard(
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
        );
        final fertilityText = vm.profile.fertilitySuggestionsEnabled
            ? vm.fertilitySuggestion
            : 'Fertility day suggestions are off in Profile.';
        final pregnancyCard = vm.profile.pregnancyTrackingEnabled
            ? SoftCard(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.surface,
                    AppColors.mint.withValues(alpha: 0.15),
                    AppColors.sky.withValues(alpha: 0.14),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.child_friendly_outlined),
                        const SizedBox(width: 8),
                        Text(
                          'Pregnancy tracker',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (vm.hasPregnancyTrackingDate) ...[
                      Text(
                        'Week ${vm.pregnancyWeek}, ${vm.pregnancyTrimester.toLowerCase()}. '
                        'Estimated due date is ${BloomDateUtils.full(vm.estimatedDueDate!)}.',
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: (vm.pregnancyDay ?? 0) / 280,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      const SizedBox(height: 10),
                      Text('${vm.daysUntilDueDate} days until due date'),
                    ] else
                      const Text(
                        'Log a period or set the last period date in Profile to start tracking.',
                      ),
                  ],
                ),
              )
            : null;
        final insightCard = SoftCard(
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
              const SizedBox(height: 8),
              Text(
                fertilityText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
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
                      onPressed: () => exportNextPeriodToCalendar(context),
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Calendar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
        return AnimatedPageList(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
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
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 900) {
                  return Column(
                    children: [
                      cycleCard,
                      const SizedBox(height: 16),
                      insightCard,
                      if (pregnancyCard != null) ...[
                        const SizedBox(height: 16),
                        pregnancyCard,
                      ],
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: cycleCard),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          insightCard,
                          if (pregnancyCard != null) ...[
                            const SizedBox(height: 16),
                            pregnancyCard,
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 900 ? 4 : 2;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: columns,
                  childAspectRatio: columns == 4 ? 1.35 : 1.18,
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
                    if (vm.profile.pregnancyTrackingEnabled)
                      MetricTile(
                        icon: Icons.child_care,
                        label: 'Pregnancy',
                        value: vm.pregnancyWeek == null
                            ? 'Set date'
                            : 'Week ${vm.pregnancyWeek}',
                        color: AppColors.lemon,
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}
