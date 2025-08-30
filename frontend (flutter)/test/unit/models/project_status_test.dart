import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yoomi_projects/models/project.dart';


void main() {
  group('ProjectStatus Tests', () {
    group('enum values', () {
      test('should have correct values', () {
        expect(ProjectStatus.draft.value, equals('DRAFT'));
        expect(ProjectStatus.published.value, equals('PUBLISHED'));
        expect(ProjectStatus.archived.value, equals('ARCHIVED'));
      });

      test('should have all expected status values', () {
        final allStatuses = ProjectStatus.values;
        expect(allStatuses.length, equals(3));
        expect(allStatuses.contains(ProjectStatus.draft), isTrue);
        expect(allStatuses.contains(ProjectStatus.published), isTrue);
        expect(allStatuses.contains(ProjectStatus.archived), isTrue);
      });
    });

    group('fromString', () {
      test('should create correct status from uppercase string', () {
        expect(ProjectStatus.fromString('DRAFT'), equals(ProjectStatus.draft));
        expect(ProjectStatus.fromString('PUBLISHED'), equals(ProjectStatus.published));
        expect(ProjectStatus.fromString('ARCHIVED'), equals(ProjectStatus.archived));
      });

      test('should handle lowercase strings', () {
        expect(ProjectStatus.fromString('draft'), equals(ProjectStatus.draft));
        expect(ProjectStatus.fromString('published'), equals(ProjectStatus.published));
        expect(ProjectStatus.fromString('archived'), equals(ProjectStatus.archived));
      });

      test('should handle mixed case strings', () {
        expect(ProjectStatus.fromString('Draft'), equals(ProjectStatus.draft));
        expect(ProjectStatus.fromString('Published'), equals(ProjectStatus.published));
        expect(ProjectStatus.fromString('Archived'), equals(ProjectStatus.archived));
        expect(ProjectStatus.fromString('dRaFt'), equals(ProjectStatus.draft));
      });

      test('should throw ArgumentError for invalid status', () {
        expect(
          () => ProjectStatus.fromString('INVALID'),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          () => ProjectStatus.fromString(''),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          () => ProjectStatus.fromString('DRAFT_OLD'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should provide helpful error message', () {
        try {
          ProjectStatus.fromString('INVALID');
          fail('Expected ArgumentError');
        } catch (e) {
          expect(e, isA<ArgumentError>());
          expect(e.toString(), contains('INVALID'));
          expect(e.toString(), contains('DRAFT, PUBLISHED, ARCHIVED'));
        }
      });
    });

    group('displayName', () {
      test('should return correct French display names', () {
        expect(ProjectStatus.draft.displayName, equals('Brouillon'));
        expect(ProjectStatus.published.displayName, equals('Publié'));
        expect(ProjectStatus.archived.displayName, equals('Archivé'));
      });

      test('should return non-empty display names for all statuses', () {
        for (final status in ProjectStatus.values) {
          expect(status.displayName, isNotEmpty);
          expect(status.displayName.trim(), equals(status.displayName));
        }
      });
    });

    group('colorValue', () {
      test('should return correct color values', () {
        expect(ProjectStatus.draft.colorValue, equals(0xFFFFA726)); // Orange
        expect(ProjectStatus.published.colorValue, equals(0xFF4CAF50)); // Green
        expect(ProjectStatus.archived.colorValue, equals(0xFF757575)); // Grey
      });

      test('should return valid color values', () {
        for (final status in ProjectStatus.values) {
          final colorValue = status.colorValue;
          expect(colorValue, greaterThanOrEqualTo(0x00000000));
          expect(colorValue, lessThanOrEqualTo(0xFFFFFFFF));
          
          // Vérifier que c'est une couleur valide en créant un Color
          final color = Color(colorValue);
          expect(color.value, equals(colorValue));
        }
      });

      test('should have different colors for each status', () {
        final colors = ProjectStatus.values.map((s) => s.colorValue).toSet();
        expect(colors.length, equals(ProjectStatus.values.length));
      });
    });

    group('status consistency', () {
      test('should maintain consistency between value and enum name', () {
        expect(ProjectStatus.draft.value, equals('DRAFT'));
        expect(ProjectStatus.published.value, equals('PUBLISHED'));
        expect(ProjectStatus.archived.value, equals('ARCHIVED'));
      });

      test('should support roundtrip conversion', () {
        for (final status in ProjectStatus.values) {
          final stringValue = status.value;
          final recreatedStatus = ProjectStatus.fromString(stringValue);
          expect(recreatedStatus, equals(status));
        }
      });
    });

    group('edge cases', () {
      test('should handle null safety correctly', () {
        // Ces tests vérifient que l'enum gère correctement les types non-nullable
        expect(ProjectStatus.draft, isNotNull);
        expect(ProjectStatus.draft.value, isNotNull);
        expect(ProjectStatus.draft.displayName, isNotNull);
        expect(ProjectStatus.draft.colorValue, isNotNull);
      });

      test('should be usable in collections', () {
        final statusList = <ProjectStatus>[
          ProjectStatus.draft,
          ProjectStatus.published,
          ProjectStatus.archived,
        ];

        expect(statusList.length, equals(3));
        expect(statusList.contains(ProjectStatus.draft), isTrue);

        final statusSet = statusList.toSet();
        expect(statusSet.length, equals(3));

        final statusMap = <ProjectStatus, String>{
          ProjectStatus.draft: 'Draft project',
          ProjectStatus.published: 'Published project',
          ProjectStatus.archived: 'Archived project',
        };
        expect(statusMap.length, equals(3));
        expect(statusMap[ProjectStatus.draft], equals('Draft project'));
      });
    });
  });
}