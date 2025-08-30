import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart'; // Fichier généré automatiquement

@HiveType(typeId: 0) // ID unique pour Hive
@JsonSerializable()
class Project extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final ProjectStatus status;
  
  @HiveField(3)
  final double amount;
  
  @HiveField(4)
  final DateTime createdAt;

  Project({
    required this.id,
    required this.name,
    required this.status,
    required this.amount,
    required this.createdAt,
  });

  /// Factory pour créer un `Project` depuis JSON
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      name: json['name'] as String,
      status: ProjectStatus.fromString(json['status'] as String),
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Conversion en JSON (NestJS attend les valeurs en MAJUSCULES)
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'status': status.value, // "DRAFT" | "PUBLISHED" | "ARCHIVED"
        'amount': amount,
        'createdAt': createdAt.toIso8601String(),
      };

  /// Copier avec modifications
  Project copyWith({
    String? id,
    String? name,
    ProjectStatus? status,
    double? amount,
    DateTime? createdAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

@HiveType(typeId: 1) // Enum pour les statuts
enum ProjectStatus {
  @HiveField(0)
  draft('DRAFT'),
  
  @HiveField(1)
  published('PUBLISHED'),
  
  @HiveField(2)
  archived('ARCHIVED');

  const ProjectStatus(this.value);
  final String value;

  /// Conversion depuis string (tolérant aux majuscules/minuscules)
  static ProjectStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'DRAFT':
        return ProjectStatus.draft;
      case 'PUBLISHED':
        return ProjectStatus.published;
      case 'ARCHIVED':
        return ProjectStatus.archived;
      default:
        throw ArgumentError(
          '`$value` is not a valid ProjectStatus. '
          'Expected: DRAFT, PUBLISHED, ARCHIVED',
        );
    }
  }

  /// Nom d’affichage lisible
  String get displayName {
    switch (this) {
      case ProjectStatus.draft:
        return 'Brouillon';
      case ProjectStatus.published:
        return 'Publié';
      case ProjectStatus.archived:
        return 'Archivé';
    }
  }

  /// Couleur associée au statut
  int get colorValue {
    switch (this) {
      case ProjectStatus.draft:
        return 0xFFFFA726; // Orange
      case ProjectStatus.published:
        return 0xFF4CAF50; // Vert
      case ProjectStatus.archived:
        return 0xFF757575; // Gris
    }
  }
}
