import 'package:flutter/material.dart';

import '../../core/utils/bloom_date_utils.dart';
import '../viewmodels/app_scope.dart';
import '../widgets/calendar/month_cycle_calendar.dart';
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
        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          children: [
            Text('Calendar', style: Theme.of(context).textTheme.headlineSmall),
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
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                'Your period is likely to start on or around '
                '${BloomDateUtils.full(vm.nextPeriodStart)}.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
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
