import 'package:flutter/material.dart';

import 'app/blooom_app.dart';
import 'data/repositories/tracker_repository.dart';
import 'data/services/auth_service.dart';
import 'data/services/calendar_service.dart';
import 'data/services/database_service.dart';
import 'data/services/notification_service.dart';
import 'presentation/viewmodels/app_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final databaseService = DatabaseService();
  final notificationService = NotificationService();
  await notificationService.initialize();

  final viewModel = AppViewModel(
    repository: TrackerRepository(databaseService),
    notificationService: notificationService,
    calendarService: CalendarService(),
    authService: AuthService(),
  );
  await viewModel.initialize();

  runApp(BlooomApp(viewModel: viewModel));
}
