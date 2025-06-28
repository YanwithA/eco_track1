import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eco_track1/main.dart';
import 'package:eco_track1/screens/splash_screen.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app using the correct class name (EcoTrackApp)
    await tester.pumpWidget(const EcoTrackApp());

    // Verify the splash screen is shown (your initial screen)
    expect(find.byType(SplashScreen), findsOneWidget);

    // Verify no debug banner
    expect(find.byWidgetPredicate(
          (widget) => widget is Banner && widget.message == 'DEBUG',
    ), findsNothing);
  });

  testWidgets('App uses correct theme settings', (WidgetTester tester) async {
    await tester.pumpWidget(const EcoTrackApp());

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

    // Verify theme configuration
    expect(materialApp.theme, isNotNull);
    expect(materialApp.darkTheme, isNotNull);
    expect(materialApp.themeMode, ThemeMode.system);
    expect(materialApp.debugShowCheckedModeBanner, false);
    expect(materialApp.title, 'EcoTrack');
  });
}