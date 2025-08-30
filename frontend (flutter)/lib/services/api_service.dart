import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/project.dart';

// Classe pour les réponses paginées
class PaginatedResponse<T> {
  final List<T> data;
  final int total;
  final int page;
  final int pageSize;

  PaginatedResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse(
      data: (json['data'] as List)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
    );
  }
}

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000'; // URL de votre API NestJS
  // Pour Android Emulator, utilisez: http://10.0.2.2:3000
  // Pour iOS Simulator, utilisez: http://localhost:3000
  
  final http.Client _client = http.Client();

  // Headers par défaut
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // GET /projects - Récupérer tous les projets avec filtres
  Future<PaginatedResponse<Project>> getProjects({
    ProjectStatus? status,
    String? search,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      // Construction des paramètres de requête
      final queryParams = <String, String>{
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };
      
      if (status != null) {
        queryParams['status'] = status.value;
      }
      
      if (search != null && search.isNotEmpty) {
        queryParams['q'] = search;
      }

      final uri = Uri.parse('$baseUrl/projects').replace(
        queryParameters: queryParams,
      );

      print('API Request: ${uri.toString()}');

      final response = await _client.get(uri, headers: _headers);
      
      print('API Response: ${response.statusCode}');
      print('API Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return PaginatedResponse.fromJson(
          jsonData,
          (json) => Project.fromJson(json),
        );
      } else {
        throw HttpException('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error in getProjects: $e');
      rethrow;
    }
  }

  // POST /projects - Créer un nouveau projet
  Future<Project> createProject({
    required String name,
    required ProjectStatus status,
    required double amount,
  }) async {
    try {
      final body = json.encode({
        'name': name,
        'status': status.value,
        'amount': amount,
      });

      print('Creating project: $body');

      final response = await _client.post(
        Uri.parse('$baseUrl/projects'),
        headers: _headers,
        body: body,
      );

      print('Create response: ${response.statusCode}');

      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return Project.fromJson(jsonData);
      } else {
        throw HttpException('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error in createProject: $e');
      rethrow;
    }
  }

  // PUT /projects/:id - Mettre à jour un projet
  Future<Project> updateProject(
    String id, {
    String? name,
    ProjectStatus? status,
    double? amount,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (status != null) body['status'] = status.value;
      if (amount != null) body['amount'] = amount;

      final response = await _client.put(
        Uri.parse('$baseUrl/projects/$id'),
        headers: _headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return Project.fromJson(jsonData);
      } else {
        throw HttpException('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error in updateProject: $e');
      rethrow;
    }
  }

  // DELETE /projects/:id - Supprimer un projet
  Future<void> deleteProject(String id) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl/projects/$id'),
        headers: _headers,
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw HttpException('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error in deleteProject: $e');
      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}