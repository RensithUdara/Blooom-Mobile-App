import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/bloom_date_utils.dart';
import '../../../presentation/viewmodels/app_view_model.dart';

class MonthCycleCalendar extends StatelessWidget {
  const MonthCycleCalendar({
    super.key,
    required this.viewModel,
    required this.month,
  });

  final AppViewModel viewModel;
  final DateTime month;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = first.weekday % 7;
    final cells = List<DateTime?>.generate(leading + daysInMonth, (index) {
      if (index < leading) return null;
      return DateTime(month.year, month.month, index - leading + 1);
    });

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map(
                (day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: cells.length,
          itemBuilder: (context, index) {
            final date = cells[index];
            if (date == null) return const SizedBox.shrink();
            final color = _dayColor(date);
            final isToday = BloomDateUtils.isSameDay(date, DateTime.now());
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.92, end: 1),
              duration: Duration(milliseconds: 220 + index * 8),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(
                    color: isToday
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: color == null
                      ? null
                      : [
                          BoxShadow(
                            color: color.withValues(alpha: 0.28),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Center(
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: color == null
                          ? Theme.of(context).colorScheme.onSurface
                          : AppColors.ink,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        const Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _LegendDot(color: AppColors.rose200, label: 'Period'),
            _LegendDot(color: AppColors.rose100, label: 'Predicted'),
            _LegendDot(color: AppColors.lavender, label: 'Fertile'),
            _LegendDot(color: AppColors.lemon, label: 'Ovulation'),
          ],
        ),
      ],
    );
  }

  Color? _dayColor(DateTime date) {
    for (final period in viewModel.periods) {
      if (BloomDateUtils.isBetween(date, period.startDate, period.endDate)) {
        return AppColors.rose200;
      }
    }

    final predictedEnd = viewModel.nextPeriodStart.add(
      Duration(days: viewModel.averagePeriodLength - 1),
    );
    if (BloomDateUtils.isBetween(
      date,
      viewModel.nextPeriodStart,
      predictedEnd,
    )) {
      return AppColors.rose100;
    }
    if (BloomDateUtils.isBetween(
      date,
      viewModel.fertileStart,
      viewModel.fertileEnd,
    )) {
      return AppColors.lavender.withValues(alpha: 0.26);
    }
    if (BloomDateUtils.isSameDay(date, viewModel.ovulationDate)) {
      return AppColors.lemon.withValues(alpha: 0.75);
    }
    return null;
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
