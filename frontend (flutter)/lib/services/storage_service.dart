import 'package:hive_flutter/hive_flutter.dart';
import '../models/project.dart';

class StorageService {
  static const String projectsBoxName = 'projects';
  
  Box<Project>? _projectsBox;
  bool _isInitialized = false;

  // Initialiser Hive
  Future<void> init() async {
    if (_isInitialized) return; // Éviter la double initialisation
    
    await Hive.initFlutter();
    
    // Enregistrer les adaptateurs
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProjectAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ProjectStatusAdapter());
    }
    
    // Ouvrir la box
    _projectsBox = await Hive.openBox<Project>(projectsBoxName);
    _isInitialized = true;
  }

  // Vérifier l'initialisation avant chaque opération
  void _checkInitialized() {
    if (!_isInitialized || _projectsBox == null) {
      throw StateError('StorageService must be initialized before use. Call init() first.');
    }
  }

  // Sauvegarder les projets en cache
  Future<void> cacheProjects(List<Project> projects) async {
    _checkInitialized();
    await _projectsBox!.clear(); // Vider le cache
    for (final project in projects) {
      await _projectsBox!.put(project.id, project);
    }
  }

  // Récupérer les projets depuis le cache
  List<Project> getCachedProjects() {
    _checkInitialized();
    return _projectsBox!.values.toList();
  }

  // Ajouter un projet au cache
  Future<void> addProjectToCache(Project project) async {
    _checkInitialized();
    await _projectsBox!.put(project.id, project);
  }

  // Mettre à jour un projet dans le cache
  Future<void> updateProjectInCache(Project project) async {
    _checkInitialized();
    await _projectsBox!.put(project.id, project);
  }

  // Supprimer un projet du cache
  Future<void> removeProjectFromCache(String id) async {
    _checkInitialized();
    await _projectsBox!.delete(id);
  }

  // Vérifier si le cache est vide
  bool get isCacheEmpty {
    if (!_isInitialized || _projectsBox == null) {
      return true;
    }
    return _projectsBox!.isEmpty;
  }

  // Fermer les connexions
  Future<void> close() async {
    if (_isInitialized && _projectsBox != null) {
      await _projectsBox!.close();
      _projectsBox = null;
      _isInitialized = false;
    }
  }
}