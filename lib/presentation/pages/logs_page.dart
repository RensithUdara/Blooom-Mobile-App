import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/bloom_date_utils.dart';
import '../../data/models/period_entry.dart';
import '../../data/models/wellness_log.dart';
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
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: vm,
      builder: (context, _) {
        final latestMood = vm.wellnessLogs.isEmpty
            ? 'No mood logged'
            : '${vm.wellnessLogs.first.mood} today';
        final periodSubtitle = vm.periods.isEmpty
            ? 'Start with your last period'
            : '${vm.periods.length} saved period logs';
        final actionRow = Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => showLogPeriodSheet(context),
                icon: const Icon(Icons.water_drop),
                label: const Text('Period'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => showLogWellnessSheet(context),
                icon: const Icon(Icons.spa),
                label: const Text('Wellness'),
              ),
            ),
          ],
        );
        final summaryCard = SoftCard(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.rose50,
              AppColors.rose200.withValues(alpha: 0.62),
              AppColors.lemon.withValues(alpha: 0.20),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  icon: Icons.favorite,
                  label: 'Cycle logs',
                  value: vm.periods.length.toString(),
                  caption: periodSubtitle,
                  color: AppColors.rose400,
                ),
              ),
              Container(
                width: 1,
                height: 66,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.46),
              ),
              Expanded(
                child: _SummaryItem(
                  icon: Icons.mood,
                  label: 'Daily health',
                  value: vm.wellnessLogs.length.toString(),
                  caption: latestMood,
                  color: AppColors.lavender,
                ),
              ),
            ],
          ),
        );
        final periodSection = _LogSection(
          title: 'Period history',
          count: vm.periods.length,
          empty: const EmptyState(
            icon: Icons.favorite_outline,
            title: 'No period logs yet',
            message: 'Add your last period to start cycle predictions.',
          ),
          isEmpty: vm.periods.isEmpty,
          children: vm.periods
              .map(
                (period) => _PeriodLogCard(
                  period: period,
                  onDelete: period.id == null
                      ? null
                      : () => _confirmDeletePeriod(context, period.id!),
                ),
              )
              .toList(),
        );
        final wellnessSection = _LogSection(
          title: 'Daily health',
          count: vm.wellnessLogs.length,
          empty: const EmptyState(
            icon: Icons.spa_outlined,
            title: 'No wellness logs yet',
            message: 'Track mood, symptoms, sleep, water and more.',
          ),
          isEmpty: vm.wellnessLogs.isEmpty,
          children: vm.wellnessLogs
              .take(12)
              .map((log) => _WellnessLogCard(log: log))
              .toList(),
        );
        return AnimatedPageList(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
          children: [
            summaryCard,
            const SizedBox(height: 12),
            actionRow,
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 900) {
                  return Column(
                    children: [
                      periodSection,
                      const SizedBox(height: 18),
                      wellnessSection,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: periodSection),
                    const SizedBox(width: 16),
                    Expanded(child: wellnessSection),
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

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final String caption;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: color.withValues(alpha: 0.16),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 8),
            Text(label, style: theme.textTheme.labelLarge),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          caption,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _LogSection extends StatelessWidget {
  const _LogSection({
    required this.title,
    required this.count,
    required this.empty,
    required this.isEmpty,
    required this.children,
  });

  final String title;
  final int count;
  final Widget empty;
  final bool isEmpty;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
            _CountBadge(count: count),
          ],
        ),
        const SizedBox(height: 10),
        if (isEmpty)
          SizedBox(
            width: double.infinity,
            child: SoftCard(child: empty),
          )
        else
          ...children,
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        count.toString(),
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _PeriodLogCard extends StatelessWidget {
  const _PeriodLogCard({required this.period, this.onDelete});

  final PeriodEntry period;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SoftCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.rose100,
            child: const Icon(Icons.water_drop, color: AppColors.rose500),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${BloomDateUtils.dayMonth(period.startDate)} - '
                  '${BloomDateUtils.dayMonth(period.endDate)}',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: Icons.timelapse,
                      label: '${period.periodLength} days',
                    ),
                    _InfoChip(
                      icon: Icons.opacity,
                      label: 'Flow ${period.flowIntensity}/5',
                    ),
                  ],
                ),
                if (period.notes.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    period.notes.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Delete period log',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class _WellnessLogCard extends StatelessWidget {
  const _WellnessLogCard({required this.log});

  final WellnessLog log;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final details = [
      _InfoChip(icon: Icons.bolt, label: 'Energy ${log.energyLevel}/5'),
      if (log.symptoms.isNotEmpty)
        _InfoChip(icon: Icons.healing, label: log.symptoms.take(2).join(', ')),
      if (log.sleepHours != null)
        _InfoChip(icon: Icons.bedtime, label: '${log.sleepHours}h sleep'),
      if (log.waterGlasses != null)
        _InfoChip(icon: Icons.water_drop, label: '${log.waterGlasses} water'),
      if (log.temperatureC != null)
        _InfoChip(icon: Icons.thermostat, label: '${log.temperatureC} C'),
      if (log.hadSex)
        _InfoChip(
          icon: Icons.favorite,
          label: log.protectedSex ? 'Protected' : 'Unprotected',
        ),
    ];

    return SoftCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: _moodColor(log.mood).withValues(alpha: 0.20),
            child: Text(
              _moodEmoji(log.mood),
              style: const TextStyle(fontSize: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(log.mood, style: theme.textTheme.titleMedium),
                    ),
                    Text(
                      BloomDateUtils.dayMonth(log.date),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: details),
                if (log.notes.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    log.notes.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _moodEmoji(String mood) {
  return switch (mood.toLowerCase()) {
    'calm' => '🙂',
    'happy' => '😊',
    'energetic' => '⚡',
    'sad' => '😔',
    'anxious' => '😟',
    'irritated' => '😤',
    _ => '🙂',
  };
}

Color _moodColor(String mood) {
  return switch (mood.toLowerCase()) {
    'calm' => AppColors.mint,
    'happy' => AppColors.lemon,
    'energetic' => AppColors.sky,
    'sad' => AppColors.lavender,
    'anxious' => AppColors.rose300,
    'irritated' => AppColors.rose500,
    _ => AppColors.rose400,
  };
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.66,
        ),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.26),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
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
