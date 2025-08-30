import 'package:flutter_test/flutter_test.dart';
import '../../mocks/mock_storage_service.dart';
import '../../mocks/test_data.dart';

void main() {
  group('StorageService Tests', () {
    late MockStorageService storageService;

    setUp(() {
      storageService = MockStorageService();
    });

    tearDown(() async {
      await storageService.close();
    });

    group('initialization', () {
      test('should initialize successfully', () async {
        // Act
        await storageService.init();

        // Assert - le mock ne lance pas d'exception par défaut
        expect(storageService.isCacheEmpty, isTrue);
      });

      test('should handle initialization errors', () async {
        // Arrange
        storageService.setErrorMode(true);

        // Act & Assert
        expect(() => storageService.init(), throwsA(isA<Exception>()));
      });
    });

    group('cache operations', () {
      setUp(() async {
        await storageService.init();
      });

      test('should cache projects successfully', () async {
        // Arrange
        final projects = TestData.projects;

        // Act
        await storageService.cacheProjects(projects);
        final cachedProjects = storageService.getCachedProjects();

        // Assert
        expect(cachedProjects.length, equals(projects.length));
        expect(storageService.isCacheEmpty, isFalse);
      });

      test('should return empty list when cache is empty', () {
        // Act
        final cachedProjects = storageService.getCachedProjects();

        // Assert
        expect(cachedProjects, isEmpty);
        expect(storageService.isCacheEmpty, isTrue);
      });

      test('should add project to cache', () async {
        // Arrange
        final project = TestData.sampleProject;

        // Act
        await storageService.addProjectToCache(project);
        final cachedProjects = storageService.getCachedProjects();

        // Assert
        expect(cachedProjects.length, equals(1));
        expect(cachedProjects.first.id, equals(project.id));
        expect(cachedProjects.first.name, equals(project.name));
      });

      test('should update project in cache', () async {
        // Arrange
        final originalProject = TestData.sampleProject;
        await storageService.addProjectToCache(originalProject);

        final updatedProject = originalProject.copyWith(name: 'Updated Name');

        // Act
        await storageService.updateProjectInCache(updatedProject);
        final cachedProjects = storageService.getCachedProjects();

        // Assert
        expect(cachedProjects.length, equals(1));
        expect(cachedProjects.first.name, equals('Updated Name'));
        expect(cachedProjects.first.id, equals(originalProject.id));
      });

      test('should remove project from cache', () async {
        // Arrange
        final projects = TestData.projects;
        await storageService.cacheProjects(projects);
        
        final projectIdToRemove = projects.first.id;

        // Act
        await storageService.removeProjectFromCache(projectIdToRemove);
        final cachedProjects = storageService.getCachedProjects();

        // Assert
        expect(cachedProjects.length, equals(projects.length - 1));
        expect(cachedProjects.any((p) => p.id == projectIdToRemove), isFalse);
      });

      test('should replace existing project when adding with same ID', () async {
        // Arrange
        final originalProject = TestData.sampleProject;
        await storageService.addProjectToCache(originalProject);

        final newProject = originalProject.copyWith(name: 'New Name');

        // Act
        await storageService.addProjectToCache(newProject);
        final cachedProjects = storageService.getCachedProjects();

        // Assert
        expect(cachedProjects.length, equals(1));
        expect(cachedProjects.first.name, equals('New Name'));
      });

      test('should clear cache when caching new projects', () async {
        // Arrange
        await storageService.addProjectToCache(TestData.sampleProject);
        expect(storageService.getCachedProjects().length, equals(1));

        final newProjects = TestData.projects.take(2).toList();

        // Act
        await storageService.cacheProjects(newProjects);
        final cachedProjects = storageService.getCachedProjects();

        // Assert
        expect(cachedProjects.length, equals(2));
        expect(cachedProjects.any((p) => p.id == TestData.sampleProject.id), isTrue);
      });
    });

    group('error handling', () {
      setUp(() async {
        await storageService.init();
      });

      test('should handle cache save errors', () async {
        // Arrange
        storageService.setErrorMode(true);

        // Act & Assert
        expect(() => storageService.cacheProjects(TestData.projects),
               throwsA(isA<Exception>()));
      });

      test('should handle cache read errors', () {
        // Arrange
        storageService.setErrorMode(true);

        // Act & Assert
        expect(() => storageService.getCachedProjects(),
               throwsA(isA<Exception>()));
      });

      test('should handle cache add errors', () async {
        // Arrange
        storageService.setErrorMode(true);

        // Act & Assert
        expect(() => storageService.addProjectToCache(TestData.sampleProject),
               throwsA(isA<Exception>()));
      });

      test('should handle cache update errors', () async {
        // Arrange
        storageService.setErrorMode(true);

        // Act & Assert
        expect(() => storageService.updateProjectInCache(TestData.sampleProject),
               throwsA(isA<Exception>()));
      });

      test('should handle cache remove errors', () async {
        // Arrange
        storageService.setErrorMode(true);

        // Act & Assert
        expect(() => storageService.removeProjectFromCache('1'),
               throwsA(isA<Exception>()));
      });
    });

    group('edge cases', () {
      setUp(() async {
        await storageService.init();
      });

      test('should handle empty projects list', () async {
        // Act
        await storageService.cacheProjects([]);
        final cachedProjects = storageService.getCachedProjects();

        // Assert
        expect(cachedProjects, isEmpty);
        expect(storageService.isCacheEmpty, isTrue);
      });

      test('should handle updating non-existent project', () async {
        // Arrange
        final project = TestData.sampleProject;

        // Act - Dans notre mock, cela ne fait rien si le projet n'existe pas
        await storageService.updateProjectInCache(project);
        final cachedProjects = storageService.getCachedProjects();

        // Assert
        expect(cachedProjects, isEmpty);
      });

      test('should handle removing non-existent project', () async {
        // Arrange
        await storageService.cacheProjects(TestData.projects);
        final initialCount = storageService.getCachedProjects().length;

        // Act
        await storageService.removeProjectFromCache('non-existent-id');
        final finalCount = storageService.getCachedProjects().length;

        // Assert
        expect(finalCount, equals(initialCount));
      });

      test('should handle large number of projects', () async {
        // Arrange
        final manyProjects = List.generate(1000, (index) => 
          TestData.sampleProject.copyWith(
            id: 'project-$index',
            name: 'Project $index',
          )
        );

        // Act
        await storageService.cacheProjects(manyProjects);
        final cachedProjects = storageService.getCachedProjects();

        // Assert
        expect(cachedProjects.length, equals(1000));
      });
    });

    group('cache state management', () {
      setUp(() async {
        await storageService.init();
      });

      test('should correctly report empty cache state', () {
        // Assert
        expect(storageService.isCacheEmpty, isTrue);
      });

      test('should correctly report non-empty cache state', () async {
        // Act
        await storageService.addProjectToCache(TestData.sampleProject);

        // Assert
        expect(storageService.isCacheEmpty, isFalse);
      });

      test('should maintain cache state after operations', () async {
        // Act & Assert
        expect(storageService.isCacheEmpty, isTrue);

        await storageService.cacheProjects(TestData.projects);
        expect(storageService.isCacheEmpty, isFalse);

        await storageService.removeProjectFromCache(TestData.projects.first.id);
        expect(storageService.isCacheEmpty, isFalse);

        // Clear all
        storageService.clearCache();
        expect(storageService.isCacheEmpty, isTrue);
      });
    });
  });
}