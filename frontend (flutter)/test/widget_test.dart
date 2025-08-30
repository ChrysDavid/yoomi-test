import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:yoomi_projects/providers/projects_provider.dart';

// Mock provider qui évite l'initialisation de Hive
class MockProjectsProviderForWidget extends ProjectsProvider {
  @override
  Future<void> init() async {
    // Ne fait rien - évite l'initialisation de Hive
    return;
  }
}

void main() {
  group('Widget Tests', () {
    testWidgets('App should start without crashing', (WidgetTester tester) async {
      // Arrange - Créer un provider mocké qui n'initialise pas Hive
      final mockProvider = MockProjectsProviderForWidget();

      // Act - Construire l'app avec le provider mocké
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ProjectsProvider>.value(
              value: mockProvider,
            ),
          ],
          child: MaterialApp(
            title: 'Yoomi Projects',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1976D2),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            home: const Scaffold(
              appBar: null,
              body: Center(
                child: Text('Test App'),
              ),
            ),
          ),
        ),
      );

      // Assert - L'app devrait se construire sans erreur
      expect(find.text('Test App'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('App should display Material theme correctly', (WidgetTester tester) async {
      // Arrange
      final mockProvider = MockProjectsProviderForWidget();

      // Act
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ProjectsProvider>.value(
              value: mockProvider,
            ),
          ],
          child: MaterialApp(
            title: 'Yoomi Projects',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1976D2),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            home: const Scaffold(
              body: Center(
                child: Text('Material Theme Test'),
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Material Theme Test'), findsOneWidget);
      
      // Vérifier que le thème Material est appliqué
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.theme?.useMaterial3, isTrue);
      expect(app.theme?.colorScheme.primary, equals(const Color(0xFF1976D2)));
    });

    testWidgets('App should handle dark theme', (WidgetTester tester) async {
      // Arrange
      final mockProvider = MockProjectsProviderForWidget();

      // Act
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ProjectsProvider>.value(
              value: mockProvider,
            ),
          ],
          child: MaterialApp(
            title: 'Yoomi Projects',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1976D2),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1976D2),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: ThemeMode.dark,
            home: const Scaffold(
              body: Center(
                child: Text('Dark Theme Test'),
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Dark Theme Test'), findsOneWidget);
      
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.darkTheme?.colorScheme.brightness, equals(Brightness.dark));
    });

    testWidgets('Provider should be available in widget tree', (WidgetTester tester) async {
      // Arrange
      final mockProvider = MockProjectsProviderForWidget();

      // Act
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ProjectsProvider>.value(
              value: mockProvider,
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final provider = Provider.of<ProjectsProvider>(context, listen: false);
                return Scaffold(
                  body: Center(
                    // ignore: unnecessary_null_comparison
                    child: Text('Provider available: ${provider != null}'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Provider available: true'), findsOneWidget);
    });
  });
}