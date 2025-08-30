import 'package:hive_flutter/hive_flutter.dart';
import '../models/project.dart';

class StorageService {
  static const String projectsBoxName = 'projects';
  
  late Box<Project> _projectsBox;

  // Initialiser Hive
  Future<void> init() async {
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
  }

  // Sauvegarder les projets en cache
  Future<void> cacheProjects(List<Project> projects) async {
    await _projectsBox.clear(); // Vider le cache
    for (final project in projects) {
      await _projectsBox.put(project.id, project);
    }
  }

  // Récupérer les projets depuis le cache
  List<Project> getCachedProjects() {
    return _projectsBox.values.toList();
  }

  // Ajouter un projet au cache
  Future<void> addProjectToCache(Project project) async {
    await _projectsBox.put(project.id, project);
  }

  // Mettre à jour un projet dans le cache
  Future<void> updateProjectInCache(Project project) async {
    await _projectsBox.put(project.id, project);
  }

  // Supprimer un projet du cache
  Future<void> removeProjectFromCache(String id) async {
    await _projectsBox.delete(id);
  }

  // Vérifier si le cache est vide
  bool get isCacheEmpty => _projectsBox.isEmpty;

  // Fermer les connexions
  Future<void> close() async {
    await _projectsBox.close();
  }
}
