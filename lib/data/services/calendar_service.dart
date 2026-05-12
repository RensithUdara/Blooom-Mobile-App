import 'package:add_2_calendar/add_2_calendar.dart';

class CalendarService {
  Future<bool> addPeriodReminder({
    required DateTime startDate,
    required int periodLength,
  }) {
    final event = Event(
      title: 'Blooom period reminder',
      description: 'Predicted period window from Blooom.',
      startDate: startDate,
      endDate: startDate.add(Duration(days: periodLength)),
      allDay: true,
      iosParams: const IOSParams(reminder: Duration(hours: 9)),
    );
    return Add2Calendar.addEvent2Cal(event);
  }
}
