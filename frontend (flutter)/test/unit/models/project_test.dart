import 'package:flutter_test/flutter_test.dart';
import 'package:yoomi_projects/models/project.dart';
import '../../mocks/test_data.dart';


void main() {
  group('Project Model Tests', () {
    late Project testProject;

    setUp(() {
      testProject = TestData.sampleProject;
    });

    group('fromJson', () {
      test('should create Project from valid JSON', () {
        // Arrange
        final json = TestData.sampleProjectJson;

        // Act
        final project = Project.fromJson(json);

        // Assert
        expect(project.id, equals('1'));
        expect(project.name, equals('Residence A'));
        expect(project.status, equals(ProjectStatus.published));
        expect(project.amount, equals(120000.0));
        expect(project.createdAt, equals(DateTime.parse('2024-01-10T10:00:00.000Z')));
      });

      test('should handle different status values', () {
        final testCases = [
          {'status': 'DRAFT', 'expected': ProjectStatus.draft},
          {'status': 'PUBLISHED', 'expected': ProjectStatus.published},
          {'status': 'ARCHIVED', 'expected': ProjectStatus.archived},
          {'status': 'draft', 'expected': ProjectStatus.draft}, // lowercase
          {'status': 'Published', 'expected': ProjectStatus.published}, // mixed case
        ];

        for (final testCase in testCases) {
          final json = {
            'id': '1',
            'name': 'Test',
            'status': testCase['status'],
            'amount': 1000.0,
            'createdAt': '2024-01-01T00:00:00.000Z',
          };

          final project = Project.fromJson(json);
          expect(project.status, equals(testCase['expected']));
        }
      });

      test('should throw error for invalid status', () {
        final json = {
          'id': '1',
          'name': 'Test',
          'status': 'INVALID_STATUS',
          'amount': 1000.0,
          'createdAt': '2024-01-01T00:00:00.000Z',
        };

        expect(() => Project.fromJson(json), throwsA(isA<ArgumentError>()));
      });

      test('should handle integer amount as double', () {
        final json = {
          'id': '1',
          'name': 'Test',
          'status': 'DRAFT',
          'amount': 1000, // integer
          'createdAt': '2024-01-01T00:00:00.000Z',
        };

        final project = Project.fromJson(json);
        expect(project.amount, equals(1000.0));
        expect(project.amount, isA<double>());
      });
    });

    group('toJson', () {
      test('should convert Project to JSON correctly', () {
        // Act
        final json = testProject.toJson();

        // Assert
        expect(json['id'], equals('1'));
        expect(json['name'], equals('Residence A'));
        expect(json['status'], equals('PUBLISHED'));
        expect(json['amount'], equals(120000.0));
        expect(json['createdAt'], equals('2024-01-10T10:00:00.000Z'));
      });

      test('should use uppercase status values', () {
        final projects = [
          Project(id: '1', name: 'Test', status: ProjectStatus.draft, amount: 1000, createdAt: DateTime.now()),
          Project(id: '2', name: 'Test', status: ProjectStatus.published, amount: 1000, createdAt: DateTime.now()),
          Project(id: '3', name: 'Test', status: ProjectStatus.archived, amount: 1000, createdAt: DateTime.now()),
        ];

        final expectedStatuses = ['DRAFT', 'PUBLISHED', 'ARCHIVED'];

        for (int i = 0; i < projects.length; i++) {
          final json = projects[i].toJson();
          expect(json['status'], equals(expectedStatuses[i]));
        }
      });
    });

    group('copyWith', () {
      test('should create copy with modified fields', () {
        // Act
        final modifiedProject = testProject.copyWith(
          name: 'Modified Name',
          amount: 99999.99,
        );

        // Assert
        expect(modifiedProject.id, equals(testProject.id));
        expect(modifiedProject.name, equals('Modified Name'));
        expect(modifiedProject.status, equals(testProject.status));
        expect(modifiedProject.amount, equals(99999.99));
        expect(modifiedProject.createdAt, equals(testProject.createdAt));
      });

      test('should create identical copy when no parameters provided', () {
        // Act
        final copiedProject = testProject.copyWith();

        // Assert
        expect(copiedProject.id, equals(testProject.id));
        expect(copiedProject.name, equals(testProject.name));
        expect(copiedProject.status, equals(testProject.status));
        expect(copiedProject.amount, equals(testProject.amount));
        expect(copiedProject.createdAt, equals(testProject.createdAt));
      });

      test('should modify only specified fields', () {
        // Act
        final modifiedProject = testProject.copyWith(status: ProjectStatus.archived);

        // Assert
        expect(modifiedProject.id, equals(testProject.id));
        expect(modifiedProject.name, equals(testProject.name));
        expect(modifiedProject.status, equals(ProjectStatus.archived));
        expect(modifiedProject.amount, equals(testProject.amount));
        expect(modifiedProject.createdAt, equals(testProject.createdAt));
      });
    });

    group('JSON roundtrip', () {
      test('should maintain data integrity through JSON roundtrip', () {
        // Act
        final json = testProject.toJson();
        final recreatedProject = Project.fromJson(json);

        // Assert
        expect(recreatedProject.id, equals(testProject.id));
        expect(recreatedProject.name, equals(testProject.name));
        expect(recreatedProject.status, equals(testProject.status));
        expect(recreatedProject.amount, equals(testProject.amount));
        expect(recreatedProject.createdAt, equals(testProject.createdAt));
      });
    });
  });
}