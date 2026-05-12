import 'package:flutter/material.dart';

import '../../viewmodels/app_scope.dart';

Future<void> exportNextPeriodToCalendar(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  final added = await AppScope.of(context).addNextPeriodToCalendar();
  if (!context.mounted) return;

  messenger.showSnackBar(
    SnackBar(
      content: Text(
        added
            ? 'Calendar app opened. Confirm the event there to save it.'
            : 'No calendar app was found on this device.',
      ),
    ),
  );
}
