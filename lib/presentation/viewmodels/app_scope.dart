import 'package:flutter/widgets.dart';

import 'app_view_model.dart';

class AppScope extends InheritedNotifier<AppViewModel> {
  const AppScope({
    super.key,
    required AppViewModel viewModel,
    required super.child,
  }) : super(notifier: viewModel);

  static AppViewModel of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in context');
    return scope!.notifier!;
  }
}
