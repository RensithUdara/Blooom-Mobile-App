import 'package:flutter/material.dart';

import '../../core/utils/bloom_date_utils.dart';
import '../viewmodels/app_scope.dart';
import '../widgets/calendar/month_cycle_calendar.dart';
import '../widgets/common/animated_content.dart';
import '../widgets/common/calendar_export.dart';
import '../widgets/common/soft_card.dart';
import 'log_period_sheet.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = AppScope.of(context);
    return AnimatedBuilder(
      animation: vm,
      builder: (context, _) {
        final month = DateTime.now();
        return AnimatedPageList(
          children: [
            const SectionHeader(
              title: 'Calendar',
              subtitle: 'Period, fertile window and ovulation predictions',
            ),
            const SizedBox(height: 14),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined),
                      const SizedBox(width: 8),
                      Text(
                        BloomDateUtils.monthYear(month),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      Text('${month.year}'),
                    ],
                  ),
                  const SizedBox(height: 18),
                  MonthCycleCalendar(viewModel: vm, month: month),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SoftCard(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.secondaryContainer,
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your period is likely to start on or around '
                      '${BloomDateUtils.full(vm.nextPeriodStart)}.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () => exportNextPeriodToCalendar(context),
              icon: const Icon(Icons.calendar_today),
              label: const Text('Add prediction to calendar'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => showLogPeriodSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Add period date'),
            ),
          ],
        );
      },
    );
  }
}
