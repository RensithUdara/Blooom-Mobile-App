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
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: vm,
      builder: (context, _) {
        final cycleChart = _InsightChartCard(
          title: 'Cycle length',
          subtitle: '${vm.recentCycleLengths.length} tracked cycles',
          icon: Icons.bar_chart_rounded,
          color: AppColors.rose400,
          gradientColors: [
            theme.colorScheme.surface,
            AppColors.rose100.withValues(alpha: 0.54),
          ],
          child: CycleLengthBarChart(values: vm.recentCycleLengths),
        );
        final symptomChart = _InsightChartCard(
          title: 'Symptoms mix',
          subtitle: '${vm.symptomCounts.length} symptom types',
          icon: Icons.pie_chart_outline,
          color: AppColors.lavender,
          height: 200,
          gradientColors: [
            AppColors.sky.withValues(alpha: 0.15),
            AppColors.lavender.withValues(alpha: 0.24),
            AppColors.rose100.withValues(alpha: 0.36),
          ],
          child: SymptomPieChart(counts: vm.symptomCounts),
        );
        final energyChart = _InsightChartCard(
          title: 'Energy trend',
          subtitle: '${vm.wellnessLogs.length} daily logs',
          icon: Icons.show_chart,
          color: AppColors.sky,
          gradientColors: [
            theme.colorScheme.surface,
            AppColors.sky.withValues(alpha: 0.20),
          ],
          child: HealthLineChart(viewModel: vm),
        );
        final confidencePercent = (vm.cycleRegularityScore * 100).round();
        final confidenceCard = SoftCard(
          padding: const EdgeInsets.all(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.rose50.withValues(alpha: 0.96),
              AppColors.lemon.withValues(alpha: 0.28),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 58,
                height: 58,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: vm.cycleRegularityScore,
                      strokeWidth: 6,
                      strokeCap: StrokeCap.round,
                      color: AppColors.rose400,
                      backgroundColor: AppColors.rose100,
                    ),
                    Text(
                      '$confidencePercent%',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prediction confidence',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'More logged cycles will make Blooom smarter on this device.',
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
        final fertilityCard = _InsightInfoCard(
          title: 'Fertility timing',
          icon: Icons.favorite_outline,
          color: AppColors.lemon,
          gradientColors: [
            AppColors.lemon.withValues(alpha: 0.26),
            AppColors.rose100.withValues(alpha: 0.26),
          ],
          body: vm.profile.fertilitySuggestionsEnabled
              ? vm.fertilitySuggestion
              : 'Best conception day suggestions are turned off.',
          chips: [
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
        );
        final pregnancyCard = _InsightInfoCard(
          title: 'Pregnancy',
          icon: Icons.child_friendly_outlined,
          color: AppColors.mint,
          gradientColors: [
            AppColors.mint.withValues(alpha: 0.24),
            AppColors.rose100.withValues(alpha: 0.24),
            AppColors.lavender.withValues(alpha: 0.10),
          ],
          body: vm.profile.pregnancyTrackingEnabled
              ? vm.hasPregnancyTrackingDate
                    ? 'Week ${vm.pregnancyWeek}, ${vm.pregnancyTrimester.toLowerCase()}. '
                          '${vm.pregnancyMilestone}'
                    : 'Choose the last period start date in Profile.'
              : 'Turn on pregnancy tracking in Profile to see week, trimester and due date.',
          chips: [
            if (vm.hasPregnancyTrackingDate)
              _DateChip(
                icon: Icons.flag_outlined,
                label: 'Due date',
                value: BloomDateUtils.dayMonth(vm.estimatedDueDate!),
              ),
          ],
        );
        return AnimatedPageList(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
          children: [
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

class _InsightChartCard extends StatelessWidget {
  const _InsightChartCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.gradientColors,
    required this.child,
    this.height = 190,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<Color> gradientColors;
  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SoftCard(
      padding: const EdgeInsets.all(16),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientColors,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _InsightIcon(icon: icon, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: height,
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.36),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.20),
              ),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _InsightInfoCard extends StatelessWidget {
  const _InsightInfoCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.gradientColors,
    required this.body,
    required this.chips,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<Color> gradientColors;
  final String body;
  final List<Widget> chips;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SoftCard(
      padding: const EdgeInsets.all(16),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientColors,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _InsightIcon(icon: icon, color: color),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
            ],
          ),
          const SizedBox(height: 12),
          Text(body, style: theme.textTheme.bodyMedium?.copyWith(height: 1.35)),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 8, children: chips),
          ],
        ],
      ),
    );
  }
}

class _InsightIcon extends StatelessWidget {
  const _InsightIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 20),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.34),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: theme.colorScheme.primary),
          const SizedBox(width: 7),
          Text(
            '$label: $value',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
