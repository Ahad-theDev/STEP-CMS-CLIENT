import 'package:cms/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('wheel scrolls login from the desktop gutter', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1100, 440));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pumpAndSettle();
    final scroll = tester.state<ScrollableState>(find.byType(Scrollable).first);
    expect(scroll.position.maxScrollExtent, greaterThan(0));
    await tester.sendEventToBinding(
      const PointerScrollEvent(
        position: Offset(30, 200),
        scrollDelta: Offset(0, 160),
      ),
    );
    await tester.pumpAndSettle();
    expect(scroll.position.pixels, greaterThan(0));
  });

  testWidgets('touch scrolls login from the phone gutter', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 440));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pumpAndSettle();
    final scroll = tester.state<ScrollableState>(find.byType(Scrollable).first);
    await tester.dragFrom(const Offset(8, 360), const Offset(0, -220));
    await tester.pumpAndSettle();
    expect(scroll.position.pixels, greaterThan(0));
  });
}
