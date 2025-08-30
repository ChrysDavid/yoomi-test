// lib/providers/projects_provider.dart - Version modifiée pour l'injection de dépendances

import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ProjectsProvider with ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;
  
  // État des données
  List<Project> _projects = [];
  List<Project> _filteredProjects = [];
  bool _isLoading = false;
  String? _error;
  
  // Paramètres de filtrage
  ProjectStatus? _statusFilter;
  String _searchQuery = '';
  
  // Pagination
  int _currentPage = 1;
  int _pageSize = 10;
  int _totalProjects = 0;
  bool _hasMorePages = false;

  // Constructeur avec injection de dépendances
  ProjectsProvider({
    ApiService? apiService,
    StorageService? storageService,
  }) : _apiService = apiService ?? ApiService(),
       _storageService = storageService ?? StorageService();

  // Getters
  List<Project> get projects => _filteredProjects;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ProjectStatus? get statusFilter => _statusFilter;
  String get searchQuery => _searchQuery;
  int get currentPage => _currentPage;
  int get totalProjects => _totalProjects;
  bool get hasMorePages => _hasMorePages;

  // Initialiser le provider
  Future<void> init() async {
    await _storageService.init();
    await loadProjects();
  }

  // Charger les projets depuis l'API ou le cache
  Future<void> loadProjects({bool fromCache = false}) async {
    _setLoading(true);
    _setError(null);

    try {
      if (fromCache || _shouldUseCache()) {
        // Charger depuis le cache
        _projects = _storageService.getCachedProjects();
        _applyFilters();
        print('Loaded ${_projects.length} projects from cache');
      } else {
        // Charger depuis l'API
        final response = await _apiService.getProjects(
          status: _statusFilter,
          search: _searchQuery.isEmpty ? null : _searchQuery,
          page: _currentPage,
          pageSize: _pageSize,
        );
        
        _projects = response.data;
        _totalProjects = response.total;
        _hasMorePages = (_currentPage * _pageSize) < _totalProjects;
        
        // Sauvegarder en cache
        await _storageService.cacheProjects(_projects);
        
        _applyFilters();
        print('Loaded ${_projects.length} projects from API');
      }
    } catch (e) {
      _setError('Erreur lors du chargement: $e');
      
      // En cas d'erreur API, essayer le cache
      if (!fromCache) {
        _projects = _storageService.getCachedProjects();
        _applyFilters();
      }
    }

    _setLoading(false);
  }

  // Créer un nouveau projet
  Future<bool> createProject({
    required String name,
    required ProjectStatus status,
    required double amount,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final newProject = await _apiService.createProject(
        name: name,
        status: status,
        amount: amount,
      );
      
      _projects.insert(0, newProject); // Ajouter au début
      await _storageService.addProjectToCache(newProject);
      _applyFilters();
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erreur lors de la création: $e');
      _setLoading(false);
      return false;
    }
  }

  // Mettre à jour un projet
  Future<bool> updateProject(
    String id, {
    String? name,
    ProjectStatus? status,
    double? amount,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final updatedProject = await _apiService.updateProject(
        id,
        name: name,
        status: status,
        amount: amount,
      );
      
      final index = _projects.indexWhere((p) => p.id == id);
      if (index != -1) {
        _projects[index] = updatedProject;
        await _storageService.updateProjectInCache(updatedProject);
        _applyFilters();
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erreur lors de la modification: $e');
      _setLoading(false);
      return false;
    }
  }

  // Supprimer un projet
  Future<bool> deleteProject(String id) async {
    _setLoading(true);
    _setError(null);

    try {
      await _apiService.deleteProject(id);
      
      _projects.removeWhere((p) => p.id == id);
      await _storageService.removeProjectFromCache(id);
      _applyFilters();
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erreur lors de la suppression: $e');
      _setLoading(false);
      return false;
    }
  }

  // Filtrer par statut
  void filterByStatus(ProjectStatus? status) {
    _statusFilter = status;
    _currentPage = 1;
    _applyFilters();
    loadProjects(); // Recharger avec le nouveau filtre
  }

  // Rechercher par nom
  void search(String query) {
    _searchQuery = query;
    _currentPage = 1;
    _applyFilters();
    if (query.length >= 2 || query.isEmpty) {
      loadProjects(); // Recharger avec la nouvelle recherche
    }
  }

  // Appliquer les filtres localement (pour la recherche rapide)
  void _applyFilters() {
    _filteredProjects = _projects.where((project) {
      bool matchesStatus = _statusFilter == null || project.status == _statusFilter;
      bool matchesSearch = _searchQuery.isEmpty || 
          project.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();
    
    notifyListeners();
  }

  // Vérifier si on doit utiliser le cache
  bool _shouldUseCache() {
    // Utiliser le cache si pas de connexion ou en cas de problème
    return false; // Pour ce test, on privilégie l'API
  }

  // Setters privés
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  @override
  void dispose() {
    _apiService.dispose();
    _storageService.close();
    super.dispose();
  }
}



