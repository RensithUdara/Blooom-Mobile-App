import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/bloom_date_utils.dart';
import '../viewmodels/app_scope.dart';
import '../widgets/charts/analytics_charts.dart';
import '../widgets/common/animated_content.dart';
import '../widgets/common/soft_card.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = AppScope.of(context);
    return AnimatedBuilder(
      animation: vm,
      builder: (context, _) {
        final cycleChart = SoftCard(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              AppColors.rose100.withValues(alpha: 0.42),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cycle length',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: CycleLengthBarChart(values: vm.recentCycleLengths),
              ),
            ],
          ),
        );
        final symptomChart = SoftCard(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              AppColors.lavender.withValues(alpha: 0.13),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Symptoms mix',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 190,
                child: SymptomPieChart(counts: vm.symptomCounts),
              ),
            ],
          ),
        );
        final energyChart = SoftCard(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              AppColors.sky.withValues(alpha: 0.14),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Energy trend',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              SizedBox(height: 180, child: HealthLineChart(viewModel: vm)),
            ],
          ),
        );
        final confidenceCard = SoftCard(
          gradient: LinearGradient(
            colors: [
              AppColors.rose50.withValues(alpha: 0.92),
              AppColors.lemon.withValues(alpha: 0.24),
            ],
          ),
          child: Row(
            children: [
              CircularProgressIndicator(
                value: vm.cycleRegularityScore,
                color: AppColors.rose400,
                backgroundColor: AppColors.rose100,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Prediction confidence ${(vm.cycleRegularityScore * 100).round()}%. '
                  'More logged cycles will make Blooom smarter on this device.',
                ),
              ),
            ],
          ),
        );
        final fertilityCard = SoftCard(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              AppColors.lemon.withValues(alpha: 0.18),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fertility timing',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Text(
                vm.profile.fertilitySuggestionsEnabled
                    ? vm.fertilitySuggestion
                    : 'Best conception day suggestions are turned off.',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _DateChip(
                    icon: Icons.favorite_outline,
                    label: 'Best day',
                    value: BloomDateUtils.dayMonth(vm.bestConceptionDay),
                  ),
                  _DateChip(
                    icon: Icons.bubble_chart_outlined,
                    label: 'Ovulation',
                    value: BloomDateUtils.dayMonth(vm.ovulationDate),
                  ),
                ],
              ),
            ],
          ),
        );
        final pregnancyCard = SoftCard(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              AppColors.mint.withValues(alpha: 0.12),
              AppColors.sky.withValues(alpha: 0.10),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pregnancy', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Text(
                vm.profile.pregnancyTrackingEnabled
                    ? vm.hasPregnancyTrackingDate
                          ? 'Week ${vm.pregnancyWeek}, ${vm.pregnancyTrimester.toLowerCase()}. '
                                '${vm.pregnancyMilestone}'
                          : 'Choose the last period start date in Profile.'
                    : 'Turn on pregnancy tracking in Profile to see week, trimester and due date.',
              ),
              if (vm.hasPregnancyTrackingDate) ...[
                const SizedBox(height: 12),
                _DateChip(
                  icon: Icons.flag_outlined,
                  label: 'Due date',
                  value: BloomDateUtils.dayMonth(vm.estimatedDueDate!),
                ),
              ],
            ],
          ),
        );
        return AnimatedPageList(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
          children: [
            const SectionHeader(
              title: 'Insights',
              subtitle: 'Charts become richer as you log real data',
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 900) {
                  return Column(
                    children: [
                      cycleChart,
                      const SizedBox(height: 14),
                      symptomChart,
                      const SizedBox(height: 14),
                      energyChart,
                      const SizedBox(height: 14),
                      confidenceCard,
                      const SizedBox(height: 14),
                      fertilityCard,
                      const SizedBox(height: 14),
                      pregnancyCard,
                    ],
                  );
                }

                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: cycleChart),
                        const SizedBox(width: 16),
                        Expanded(child: symptomChart),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: energyChart),
                        const SizedBox(width: 16),
                        Expanded(child: confidenceCard),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: fertilityCard),
                        const SizedBox(width: 16),
                        Expanded(child: pregnancyCard),
                      ],
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

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text('$label: $value'),
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
    );
  }
}
