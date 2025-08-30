import 'package:mockito/mockito.dart';
import 'package:yoomi_projects/models/project.dart';
import 'package:yoomi_projects/services/storage_service.dart';


class MockStorageService extends Mock implements StorageService {
  final List<Project> _cachedProjects = [];
  bool shouldFail = false;

  void setErrorMode(bool fail) {
    shouldFail = fail;
  }

  @override
  Future<void> init() async {
    if (shouldFail) {
      throw Exception('Storage initialization failed');
    }
  }

  @override
  Future<void> cacheProjects(List<Project> projects) async {
    if (shouldFail) {
      throw Exception('Cache save failed');
    }
    _cachedProjects.clear();
    _cachedProjects.addAll(projects);
  }

  @override
  List<Project> getCachedProjects() {
    if (shouldFail) {
      throw Exception('Cache read failed');
    }
    return List.from(_cachedProjects);
  }

  @override
  Future<void> addProjectToCache(Project project) async {
    if (shouldFail) {
      throw Exception('Cache add failed');
    }
    _cachedProjects.removeWhere((p) => p.id == project.id);
    _cachedProjects.insert(0, project);
  }

  @override
  Future<void> updateProjectInCache(Project project) async {
    if (shouldFail) {
      throw Exception('Cache update failed');
    }
    final index = _cachedProjects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _cachedProjects[index] = project;
    }
  }

  @override
  Future<void> removeProjectFromCache(String id) async {
    if (shouldFail) {
      throw Exception('Cache remove failed');
    }
    _cachedProjects.removeWhere((p) => p.id == id);
  }

  @override
  bool get isCacheEmpty => _cachedProjects.isEmpty;

  @override
  Future<void> close() async {
  }

  void clearCache() {
    _cachedProjects.clear();
  }
}