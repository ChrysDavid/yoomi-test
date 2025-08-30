import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:yoomi_projects/providers/projects_provider.dart';
import 'package:yoomi_projects/widgets/project_card.dart';


/// Helper pour initialiser l'app dans les tests de widgets
class PumpApp {
  /// Pump une app basique avec un widget enfant
  static Future<void> pumpWidget(
    WidgetTester tester,
    Widget child, {
    ProjectsProvider? provider,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: child),
        theme: ThemeData.light(),
      ),
    );
  }

  /// Pump l'app complète avec Provider
  static Future<void> pumpAppWithProvider(
    WidgetTester tester,
    Widget child, {
    ProjectsProvider? provider,
  }) async {
    final testProvider = provider ?? _createTestProvider();
    
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ProjectsProvider>.value(
            value: testProvider,
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: child),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1976D2),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
        ),
      ),
    );
  }

  /// Pump l'app avec navigation
  static Future<void> pumpAppWithNavigation(
    WidgetTester tester,
    Widget home, {
    ProjectsProvider? provider,
  }) async {
    final testProvider = provider ?? _createTestProvider();
    
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ProjectsProvider>.value(
            value: testProvider,
          ),
        ],
        child: MaterialApp(
          home: home,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1976D2),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
        ),
      ),
    );
  }

  /// Pump seulement le widget avec Material wrapper minimal
  static Future<void> pumpMaterial(
    WidgetTester tester,
    Widget child,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: child),
        theme: ThemeData.light(),
      ),
    );
  }

  /// Créer un ProjectsProvider pour les tests avec mocks injectés
  static ProjectsProvider _createTestProvider() {
    // TODO: Modifier ProjectsProvider pour accepter des dépendances injectées
    // En attendant, retourner un provider basique
    return ProjectsProvider();
  }

  /// Pump widget avec thème sombre
  static Future<void> pumpWidgetWithDarkTheme(
    WidgetTester tester,
    Widget child,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: child),
        theme: ThemeData.dark(),
      ),
    );
  }

  /// Pump widget avec taille d'écran spécifique
  static Future<void> pumpWidgetWithSize(
    WidgetTester tester,
    Widget child,
    Size size,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: child),
        theme: ThemeData.light(),
      ),
    );
    
    addTearDown(() => tester.view.resetPhysicalSize());
  }

  /// Helper spécifique pour tester ProjectCard sans ambiguïté
  static Future<void> pumpProjectCard(
    WidgetTester tester,
    Widget child,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: child,
          ),
        ),
        theme: ThemeData.light(),
      ),
    );
  }
}

// Extensions pour les finders plus spécifiques
extension FinderExtensions on CommonFinders {
  /// Trouve un InkWell spécifiquement dans un ProjectCard
  Finder projectCardInkWell() {
    return find.descendant(
      of: find.byType(ProjectCard),
      matching: find.byType(InkWell),
    );
  }

  /// Trouve le premier widget d'un type donné
  Finder firstOfType<T extends Widget>() {
    return find.byType(T).first;
  }
}
