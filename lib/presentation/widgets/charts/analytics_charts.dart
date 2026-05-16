import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../viewmodels/app_view_model.dart';

class CycleLengthBarChart extends StatelessWidget {
  const CycleLengthBarChart({super.key, required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const _EmptyChartMessage(
        icon: Icons.bar_chart,
        message: 'Add at least two periods to see cycle length trends.',
      );
    }

    final chartValues = values;
    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: [
          for (var i = 0; i < chartValues.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: chartValues[i],
                  width: 14,
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [AppColors.rose300, AppColors.rose500],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class SymptomPieChart extends StatelessWidget {
  const SymptomPieChart({super.key, required this.counts});

  final Map<String, int> counts;

  @override
  Widget build(BuildContext context) {
    final entries = counts.entries.take(4).toList();
    if (entries.isEmpty) {
      return const _EmptyChartMessage(
        icon: Icons.pie_chart_outline,
        message: 'Log symptoms to build your symptom mix chart.',
      );
    }

    final data = entries;
    const colors = [
      AppColors.rose400,
      AppColors.lavender,
      AppColors.lemon,
      AppColors.sky,
    ];

    return PieChart(
      PieChartData(
        centerSpaceRadius: 44,
        sectionsSpace: 3,
        sections: [
          for (var i = 0; i < data.length; i++)
            PieChartSectionData(
              value: data[i].value.toDouble(),
              color: colors[i % colors.length],
              title: data[i].key,
              radius: 48,
              titleStyle: const TextStyle(
                color: AppColors.ink,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
        ],
      ),
    );
  }
}

class HealthLineChart extends StatelessWidget {
  const HealthLineChart({super.key, required this.viewModel});

  final AppViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final logs = viewModel.wellnessLogs.take(10).toList().reversed.toList();
    if (logs.isEmpty) {
      return const _EmptyChartMessage(
        icon: Icons.show_chart,
        message: 'Add daily wellness logs to see your energy trend.',
      );
    }

    final spots = [
      for (var i = 0; i < logs.length; i++)
        FlSpot(i.toDouble(), logs[i].energyLevel.toDouble()),
    ];

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 5,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          getDrawingHorizontalLine: (_) => FlLine(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.4),
            strokeWidth: 1,
          ),
          drawVerticalLine: false,
        ),
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.rose500,
            barWidth: 4,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.rose400.withValues(alpha: 0.24),
                  AppColors.rose400.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChartMessage extends StatelessWidget {
  const _EmptyChartMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 10),
          Text('Waiting for data', style: theme.textTheme.titleSmall),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
