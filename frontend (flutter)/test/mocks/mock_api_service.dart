import 'dart:io';
import 'package:mockito/mockito.dart';
import 'package:yoomi_projects/models/project.dart';
import 'package:yoomi_projects/services/api_service.dart';
import 'test_data.dart';

class MockApiService extends Mock implements ApiService {
  bool shouldFail = false;
  String? errorMessage;
  
  void setErrorMode(bool fail, [String? message]) {
    shouldFail = fail;
    errorMessage = message ?? 'Test error';
  }

  @override
  Future<PaginatedResponse<Project>> getProjects({
    ProjectStatus? status,
    String? search,
    int page = 1,
    int pageSize = 10,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (shouldFail) {
      throw HttpException(errorMessage!);
    }

    var filteredProjects = TestData.projects;

    // Appliquer les filtres
    if (status != null) {
      filteredProjects = filteredProjects
          .where((p) => p.status == status)
          .toList();
    }

    if (search != null && search.isNotEmpty) {
      filteredProjects = filteredProjects
          .where((p) => p.name.toLowerCase().contains(search.toLowerCase()))
          .toList();
    }

    // Simuler la pagination
    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize;
    final paginatedData = filteredProjects.sublist(
      startIndex,
      endIndex > filteredProjects.length ? filteredProjects.length : endIndex,
    );

    return PaginatedResponse(
      data: paginatedData,
      total: filteredProjects.length,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<Project> createProject({
    required String name,
    required ProjectStatus status,
    required double amount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (shouldFail) {
      throw HttpException(errorMessage!);
    }

    return Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      status: status,
      amount: amount,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<Project> updateProject(
    String id, {
    String? name,
    ProjectStatus? status,
    double? amount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (shouldFail) {
      throw HttpException(errorMessage!);
    }

    final existingProject = TestData.projects
        .firstWhere((p) => p.id == id, orElse: () => throw HttpException('Project not found'));

    return existingProject.copyWith(
      name: name ?? existingProject.name,
      status: status ?? existingProject.status,
      amount: amount ?? existingProject.amount,
    );
  }

  @override
  Future<void> deleteProject(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (shouldFail) {
      throw HttpException(errorMessage!);
    }

    final exists = TestData.projects.any((p) => p.id == id);
    if (!exists) {
      throw HttpException('Project not found');
    }
  }

  @override
  void dispose() {
    // Mock implementation
  }
}