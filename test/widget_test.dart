import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:period_tracker/core/constants/app_constants.dart';

void main() {
  testWidgets('Blooom logo smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Image(image: AssetImage(AppConstants.logoAsset))),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
  });
}
