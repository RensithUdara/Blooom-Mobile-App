import 'package:flutter/material.dart';

import '../../core/utils/bloom_date_utils.dart';
import '../viewmodels/app_scope.dart';
import '../widgets/common/animated_content.dart';
import '../widgets/common/soft_card.dart';
import 'log_period_sheet.dart';
import 'log_wellness_sheet.dart';

class LogsPage extends StatelessWidget {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = AppScope.of(context);
    return AnimatedBuilder(
      animation: vm,
      builder: (context, _) {
        return AnimatedPageList(
          children: [
            const SectionHeader(
              title: 'Logs',
              subtitle: 'Capture cycle and wellness signals',
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => showLogPeriodSheet(context),
                    icon: const Icon(Icons.favorite),
                    label: const Text('Period'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => showLogWellnessSheet(context),
                    icon: const Icon(Icons.spa),
                    label: const Text('Wellness'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Period history',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            if (vm.periods.isEmpty)
              const SoftCard(
                child: EmptyState(
                  icon: Icons.favorite_outline,
                  title: 'No period logs yet',
                  message: 'Add your last period to start cycle predictions.',
                ),
              )
            else
              ...vm.periods.map(
                (period) => SoftCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(child: Icon(Icons.water_drop)),
                    title: Text(
                      '${BloomDateUtils.dayMonth(period.startDate)} - '
                      '${BloomDateUtils.dayMonth(period.endDate)}',
                    ),
                    subtitle: Text(
                      '${period.periodLength} days  |  Flow ${period.flowIntensity}/5',
                    ),
                    trailing: IconButton(
                      onPressed: period.id == null
                          ? null
                          : () => _confirmDeletePeriod(context, period.id!),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Text(
              'Daily health',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            if (vm.wellnessLogs.isEmpty)
              const SoftCard(
                child: EmptyState(
                  icon: Icons.spa_outlined,
                  title: 'No wellness logs yet',
                  message:
                      'Track mood, symptoms, sleep, water, temperature and more.',
                ),
              )
            else
              ...vm.wellnessLogs
                  .take(12)
                  .map(
                    (log) => SoftCard(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(child: Icon(Icons.mood)),
                        title: Text(
                          '${log.mood}  |  ${BloomDateUtils.dayMonth(log.date)}',
                        ),
                        subtitle: Text(
                          [
                            if (log.symptoms.isNotEmpty)
                              log.symptoms.join(', '),
                            if (log.sleepHours != null)
                              '${log.sleepHours}h sleep',
                            if (log.waterGlasses != null)
                              '${log.waterGlasses} glasses water',
                          ].join('  |  '),
                        ),
                      ),
                    ),
                  ),
          ],
        );
      },
    );
  }
}

Future<void> _confirmDeletePeriod(BuildContext context, int id) async {
  final vm = AppScope.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete period log?'),
        content: const Text(
          'This removes the saved period from this device and updates your predictions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  if (confirmed == true) {
    await vm.deletePeriod(id);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Period log deleted.')));
    }
  }
}
