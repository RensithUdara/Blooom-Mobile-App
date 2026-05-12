import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:period_tracker/core/constants/app_constants.dart';
import 'package:period_tracker/data/repositories/tracker_repository.dart';
import 'package:period_tracker/data/services/auth_service.dart';
import 'package:period_tracker/data/services/calendar_service.dart';
import 'package:period_tracker/data/services/database_service.dart';
import 'package:period_tracker/data/services/notification_service.dart';
import 'package:period_tracker/presentation/viewmodels/app_view_model.dart';
import 'package:period_tracker/presentation/widgets/calendar/month_cycle_calendar.dart';

void main() {
  testWidgets('Blooom logo smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Image(image: AssetImage(AppConstants.logoAsset))),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('Month cycle calendar builds with leading blank cells', (
    WidgetTester tester,
  ) async {
    final viewModel = AppViewModel(
      repository: TrackerRepository(DatabaseService()),
      notificationService: NotificationService(),
      calendarService: CalendarService(),
      authService: AuthService(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: MonthCycleCalendar(
              viewModel: viewModel,
              month: DateTime(2026, 5),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(MonthCycleCalendar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
