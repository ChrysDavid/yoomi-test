import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Extensions utiles pour les tests
extension WidgetTesterX on WidgetTester {
  /// Attend qu'un widget soit présent et le retourne
  Future<Finder> waitForWidget(Finder finder) async {
    await pumpAndSettle();
    expect(finder, findsOneWidget);
    return finder;
  }

  /// Tape sur un widget et attend la fin des animations
  Future<void> tapAndSettle(Finder finder) async {
    await tap(finder);
    await pumpAndSettle();
  }

  /// Entre du texte dans un champ et attend
  Future<void> enterTextAndSettle(Finder finder, String text) async {
    await enterText(finder, text);
    await pumpAndSettle();
  }

  /// Scroll vers un widget
  Future<void> scrollToAndSettle(Finder finder) async {
    await scrollUntilVisible(finder, 500.0);
    await pumpAndSettle();
  }
}

/// Helpers pour les matchers personnalisés
class TestMatchers {
  static Matcher hasErrorText(String text) {
    return predicate<Widget>(
      (widget) => widget is Text && widget.data?.contains(text) == true,
      'Widget with error text "$text"',
    );
  }

  static Matcher isLoadingIndicator() {
    return predicate<Widget>(
      (widget) => widget is CircularProgressIndicator,
      'Loading indicator widget',
    );
  }

  static Matcher hasTextColor(Color color) {
    return predicate<Widget>(
      (widget) => widget is Text && 
                  widget.style?.color == color,
      'Text with color $color',
    );
  }
}

/// Helper pour créer des contexts de test
class TestContexts {
  static BuildContext createMockContext() {
    return _MockBuildContext();
  }
}

class _MockBuildContext extends BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}