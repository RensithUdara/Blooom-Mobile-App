import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
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
        return AnimatedPageList(
          children: [
            const SectionHeader(
              title: 'Insights',
              subtitle: 'Charts become richer as you log real data',
            ),
            const SizedBox(height: 14),
            SoftCard(
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
            ),
            const SizedBox(height: 14),
            SoftCard(
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
            ),
            const SizedBox(height: 14),
            SoftCard(
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
            ),
            const SizedBox(height: 14),
            SoftCard(
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
            ),
          ],
        );
      },
    );
  }
}
