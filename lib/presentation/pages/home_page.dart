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
                padding: const EdgeInsets.all(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.mint.withValues(alpha: 0.22),
                    theme.colorScheme.surface,
                    AppColors.lavender.withValues(alpha: 0.14),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.mint.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.child_friendly_outlined),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Pregnancy tracker',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        if (vm.pregnancyWeek != null)
                          _HomePill(label: 'Week ${vm.pregnancyWeek}'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (vm.hasPregnancyTrackingDate) ...[
                      Text(
                        '${vm.pregnancyTrimester}, '
                        'Estimated due date is ${BloomDateUtils.full(vm.estimatedDueDate!)}.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.35,
                        ),
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
          padding: const EdgeInsets.all(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              AppColors.rose50.withValues(alpha: 0.82),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.lemon.withValues(alpha: 0.26),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.auto_awesome, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Smart insight',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  _HomePill(
                    label:
                        '${(vm.cycleRegularityScore * 100).round()}% confidence',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Your fertile window is predicted around '
                '${BloomDateUtils.dayMonth(vm.fertileStart)} - '
                '${BloomDateUtils.dayMonth(vm.fertileEnd)}.',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.42,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  fertilityText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
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
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
          children: [
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
                  childAspectRatio: columns == 4 ? 1.65 : 1.10,
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

class _HomePill extends StatelessWidget {
  const _HomePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
