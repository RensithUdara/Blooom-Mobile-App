import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings: settings);
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> schedulePeriodReminders(DateTime nextPeriod) async {
    await _plugin.cancelAll();
    final reminderDates = <DateTime>[
      nextPeriod.subtract(const Duration(days: 2)),
      nextPeriod,
    ];

    for (var index = 0; index < reminderDates.length; index++) {
      final reminderDate = DateTime(
        reminderDates[index].year,
        reminderDates[index].month,
        reminderDates[index].day,
        9,
      );
      if (!reminderDate.isAfter(DateTime.now())) continue;

      await _plugin.zonedSchedule(
        id: index + 100,
        title: index == 0
            ? 'Your period may start soon'
            : 'Predicted period starts today',
        body: index == 0
            ? 'Blooom predicts your period in about 2 days. Keep care items ready.'
            : 'Blooom marked today as your predicted period start.',
        scheduledDate: tz.TZDateTime.from(reminderDate, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'blooom_cycle_reminders',
            'Cycle reminders',
            channelDescription:
                'Period and fertile window reminders from Blooom',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }
}
