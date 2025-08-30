import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yoomi_projects/models/project.dart';
import 'package:yoomi_projects/widgets/project_card.dart';

import '../../helpers/pump_app.dart';
import '../../mocks/test_data.dart';

void main() {
  group('ProjectCard Widget Tests', () {
    late Project testProject;

    setUp(() {
      testProject = TestData.sampleProject;
    });

    testWidgets('should display project information correctly', (WidgetTester tester) async {
      // Arrange & Act
      await PumpApp.pumpWidget(
        tester,
        ProjectCard(project: testProject),
      );

      // Assert
      expect(find.text(testProject.name), findsOneWidget);
      expect(find.text(testProject.status.displayName), findsOneWidget);
      expect(find.text('${testProject.amount.toStringAsFixed(0)} €'), findsOneWidget);
      expect(find.text('10/01/2024'), findsOneWidget); // Formatted date
    });

    testWidgets('should display status chip with correct color', (WidgetTester tester) async {
      // Arrange & Act
      await PumpApp.pumpWidget(
        tester,
        ProjectCard(project: testProject),
      );

      // Assert
      final statusChip = find.byWidgetPredicate(
        (widget) => widget is Container && 
                    widget.decoration is BoxDecoration &&
                    (widget.decoration as BoxDecoration).color == 
                    Color(testProject.status.colorValue).withOpacity(0.2),
      );
      expect(statusChip, findsOneWidget);
    });

    testWidgets('should display different status colors for different statuses', (WidgetTester tester) async {
      final testProjects = [
        TestData.sampleProject.copyWith(status: ProjectStatus.draft),
        TestData.sampleProject.copyWith(status: ProjectStatus.published),
        TestData.sampleProject.copyWith(status: ProjectStatus.archived),
      ];

      for (final project in testProjects) {
        // Arrange & Act
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(body: ProjectCard(project: project)),
        ));

        // Assert
        expect(find.text(project.status.displayName), findsOneWidget);
        
        final statusContainer = tester.widget<Container>(
          find.byWidgetPredicate(
            (widget) => widget is Container && 
                        widget.decoration is BoxDecoration &&
                        (widget.decoration as BoxDecoration).color == 
                        Color(project.status.colorValue).withOpacity(0.2),
          ),
        );
        expect(statusContainer, isNotNull);
      }
    });

    testWidgets('should format amount correctly', (WidgetTester tester) async {
      // Test different amounts
      final testCases = [
        {'amount': 1000.0, 'expected': '1000 €'},
        {'amount': 1500.99, 'expected': '1501 €'}, // Should round
        {'amount': 0.0, 'expected': '0 €'},
        {'amount': 999999.0, 'expected': '999999 €'},
      ];

      for (final testCase in testCases) {
        final project = testProject.copyWith(amount: testCase['amount'] as double);
        
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(body: ProjectCard(project: project)),
        ));

        expect(find.text(testCase['expected'] as String), findsOneWidget);
      }
    });

    testWidgets('should format date correctly', (WidgetTester tester) async {
      // Test different dates
      final testCases = [
        {'date': DateTime(2024, 1, 1), 'expected': '01/01/2024'},
        {'date': DateTime(2024, 12, 31), 'expected': '31/12/2024'},
        {'date': DateTime(2023, 5, 15), 'expected': '15/05/2023'},
      ];

      for (final testCase in testCases) {
        final project = testProject.copyWith(createdAt: testCase['date'] as DateTime);
        
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(body: ProjectCard(project: project)),
        ));

        expect(find.text(testCase['expected'] as String), findsOneWidget);
      }
    });

    testWidgets('should handle tap callback', (WidgetTester tester) async {
      // Arrange
      bool wasPressed = false;

      await PumpApp.pumpWidget(
        tester,
        ProjectCard(
          project: testProject,
          onTap: () => wasPressed = true,
        ),
      );

      // Act - Utiliser un finder plus spécifique pour éviter les conflits
      final mainInkWell = find.descendant(
        of: find.byType(ProjectCard),
        matching: find.byType(InkWell),
      ).first;
      
      await tester.tap(mainInkWell);
      await tester.pumpAndSettle();

      // Assert
      expect(wasPressed, isTrue);
    });

    testWidgets('should show popup menu when menu button is tapped', (WidgetTester tester) async {
      // Arrange
      await PumpApp.pumpWidget(
        tester,
        ProjectCard(project: testProject),
      );

      // Act
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Modifier'), findsOneWidget);
      expect(find.text('Supprimer'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('should handle edit callback from menu', (WidgetTester tester) async {
      // Arrange
      bool editCalled = false;

      await PumpApp.pumpWidget(
        tester,
        ProjectCard(
          project: testProject,
          onEdit: () => editCalled = true,
        ),
      );

      // Act
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Modifier'));
      await tester.pumpAndSettle();

      // Assert
      expect(editCalled, isTrue);
    });

    testWidgets('should handle delete callback from menu', (WidgetTester tester) async {
      // Arrange
      bool deleteCalled = false;

      await PumpApp.pumpWidget(
        tester,
        ProjectCard(
          project: testProject,
          onDelete: () => deleteCalled = true,
        ),
      );

      // Act
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Supprimer'));
      await tester.pumpAndSettle();

      // Assert
      expect(deleteCalled, isTrue);
    });

    testWidgets('should display delete menu item in red', (WidgetTester tester) async {
      // Arrange
      await PumpApp.pumpWidget(
        tester,
        ProjectCard(project: testProject),
      );

      // Act
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Assert
      final deleteIcon = tester.widget<Icon>(
        find.descendant(
          of: find.byWidgetPredicate(
            (widget) => widget is PopupMenuItem<String> && 
                        widget.value == 'delete',
          ),
          matching: find.byIcon(Icons.delete),
        ),
      );
      expect(deleteIcon.color, equals(Colors.red));

      final deleteText = tester.widget<Text>(
        find.descendant(
          of: find.byWidgetPredicate(
            (widget) => widget is PopupMenuItem<String> && 
                        widget.value == 'delete',
          ),
          matching: find.text('Supprimer'),
        ),
      );
      expect(deleteText.style?.color, equals(Colors.red));
    });

    testWidgets('should handle null callbacks gracefully', (WidgetTester tester) async {
      // Arrange & Act
      await PumpApp.pumpWidget(
        tester,
        ProjectCard(
          project: testProject,
          // All callbacks are null
        ),
      );

      // Assert - Should not crash
      expect(find.byType(ProjectCard), findsOneWidget);

      // Tap main card - utiliser le premier InkWell trouvé
      final mainInkWell = find.descendant(
        of: find.byType(ProjectCard),
        matching: find.byType(InkWell),
      ).first;
      
      await tester.tap(mainInkWell);
      await tester.pumpAndSettle();

      // Open menu and try actions
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Modifier'));
      await tester.pumpAndSettle();
      
      // Should not crash
      expect(find.byType(ProjectCard), findsOneWidget);
    });

    testWidgets('should display all required labels', (WidgetTester tester) async {
      // Arrange & Act
      await PumpApp.pumpWidget(
        tester,
        ProjectCard(project: testProject),
      );

      // Assert
      expect(find.text('Montant'), findsOneWidget);
      expect(find.text('Créé le'), findsOneWidget);
    });

    testWidgets('should have correct card styling', (WidgetTester tester) async {
      // Arrange & Act
      await PumpApp.pumpWidget(
        tester,
        ProjectCard(project: testProject),
      );

      // Assert - Tester seulement le Card, pas les InkWell
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, equals(2));
      expect(card.margin, equals(const EdgeInsets.symmetric(horizontal: 16, vertical: 8)));

      // Vérifier qu'il y a au moins un InkWell (pour l'interaction)
      expect(find.descendant(
        of: find.byType(ProjectCard),
        matching: find.byType(InkWell),
      ), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle very long project names', (WidgetTester tester) async {
      // Arrange
      final longNameProject = testProject.copyWith(
        name: 'This is a very long project name that should be handled properly by the widget without breaking the layout or causing overflow issues',
      );

      // Act
      await PumpApp.pumpWidget(
        tester,
        ProjectCard(project: longNameProject),
      );

      // Assert - Should not throw overflow errors
      expect(find.text(longNameProject.name), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should display green color for amount', (WidgetTester tester) async {
      // Arrange & Act
      await PumpApp.pumpWidget(
        tester,
        ProjectCard(project: testProject),
      );

      // Assert
      final amountText = tester.widget<Text>(
        find.text('${testProject.amount.toStringAsFixed(0)} €'),
      );
      expect(amountText.style?.color, equals(Colors.green[700]));
      expect(amountText.style?.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('should maintain accessibility', (WidgetTester tester) async {
      // Arrange & Act
      await PumpApp.pumpWidget(
        tester,
        ProjectCard(project: testProject),
      );

      // Assert - Vérifier qu'il y a des éléments interactifs
      final interactiveElements = find.descendant(
        of: find.byType(ProjectCard),
        matching: find.byType(InkWell),
      );
      expect(interactiveElements, findsAtLeastNWidgets(1));
      
      // Vérifier que le premier InkWell peut recevoir le focus
      final firstInkWell = tester.widget<InkWell>(interactiveElements.first);
      expect(firstInkWell.canRequestFocus, isTrue);
    });
  });
}