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
    final cells = List<DateTime?>.filled(leading, null)
      ..addAll(
        List.generate(
          daysInMonth,
          (index) => DateTime(month.year, month.month, index + 1),
        ),
      );

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
            return DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(
                  color: isToday
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 2,
                ),
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
            );
          },
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
