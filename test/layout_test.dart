import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oncall/main.dart';

void main() {
  // Logical sizes + safe-area top padding of real phones.
  const screens = {
    'iPhone SE': (Size(375, 667), 20.0),
    'iPhone 16 Pro Max': (Size(440, 956), 62.0),
    'tiny Android': (Size(320, 568), 24.0),
  };

  for (final MapEntry(key: name, value: (size, top)) in screens.entries) {
    testWidgets('no overflow on $name', (tester) async {
      tester.view.physicalSize = size * 2;
      tester.view.devicePixelRatio = 2;
      tester.view.padding = FakeViewPadding(top: top * 2, bottom: 34 * 2);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const OnCallApp());
      // Step through the entrance + a full animation loop.
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(tester.takeException(), isNull);
    });
  }
}
