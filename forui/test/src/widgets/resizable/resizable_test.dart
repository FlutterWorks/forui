import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide VerticalDivider;

import 'package:flutter_test/flutter_test.dart';

import 'package:forui/forui.dart';
import 'package:forui/src/widgets/resizable/divider.dart';

void main() {
  final top = FResizableRegion(
    initialExtent: 30,
    minExtent: 20,
    builder: (context, snapshot, child) => const Align(child: Text('A')),
  );

  final bottom = FResizableRegion(
    initialExtent: 70,
    minExtent: 20,
    builder: (context, snapshot, child) => const Align(child: Text('B')),
  );

  for (final (index, constructor) in [
    () => FResizable(crossAxisExtent: 0, axis: Axis.vertical, children: [top, bottom]),
  ].indexed) {
    test('[$index] constructor throws error', () => expect(constructor, throwsAssertionError));
  }

  testWidgets('vertical drag downwards', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;

    final vertical = FResizable(
      crossAxisExtent: 50,
      axis: Axis.vertical,
      children: [top, bottom],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(body: Center(child: vertical)),
      ),
    );

    await tester.timedDrag(
      find.byType(VerticalDivider),
      const Offset(0, 100),
      const Duration(seconds: 1),
    );
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(FResizableRegion).first), const Size(50, 80));
    expect(tester.getSize(find.byType(FResizableRegion).last), const Size(50, 20));

    debugDefaultTargetPlatformOverride = null; // This cannot be called in tearDown, Flutter is dumb.
  });

  testWidgets('vertical drag upwards', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;

    final vertical = FResizable(
      crossAxisExtent: 50,
      axis: Axis.vertical,
      children: [top, bottom],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(body: Center(child: vertical)),
      ),
    );

    await tester.timedDrag(
      find.byType(VerticalDivider),
      const Offset(0, -100),
      const Duration(seconds: 1),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byType(FResizableRegion).first),
      const Size(50, 20),
    );
    expect(
      tester.getSize(find.byType(FResizableRegion).last),
      const Size(50, 80),
    );

    debugDefaultTargetPlatformOverride = null; // This cannot be called in tearDown, Flutter is dumb.
  });

  testWidgets('horizontal drag right', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;

    final horizontal = FResizable(
      crossAxisExtent: 50,
      axis: Axis.horizontal,
      children: [top, bottom],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(body: Center(child: horizontal)),
      ),
    );

    await tester.timedDrag(
      find.byType(HorizontalDivider),
      const Offset(100, 0),
      const Duration(seconds: 1),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byType(FResizableRegion).first),
      const Size(80, 50),
    );
    expect(
      tester.getSize(find.byType(FResizableRegion).last),
      const Size(20, 50),
    );

    debugDefaultTargetPlatformOverride = null; // This cannot be called in tearDown, Flutter is dumb.
  });

  testWidgets('horizontal drag left', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;

    final horizontal = FResizable(
      crossAxisExtent: 50,
      axis: Axis.horizontal,
      children: [top, bottom],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(body: Center(child: horizontal)),
      ),
    );

    await tester.timedDrag(
      find.byType(HorizontalDivider),
      const Offset(-100, 0),
      const Duration(seconds: 1),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byType(FResizableRegion).first),
      const Size(20, 50),
    );
    expect(
      tester.getSize(find.byType(FResizableRegion).last),
      const Size(80, 50),
    );

    debugDefaultTargetPlatformOverride = null; // This cannot be called in tearDown, Flutter is dumb.
  });
}
