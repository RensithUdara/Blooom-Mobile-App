import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../viewmodels/app_scope.dart';
import '../widgets/charts/analytics_charts.dart';
import '../widgets/common/soft_card.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = AppScope.of(context);
    return AnimatedBuilder(
      animation: vm,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          children: [
            Text('Insights', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 14),
            SoftCard(
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
