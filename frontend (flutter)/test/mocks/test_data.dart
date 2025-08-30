import 'package:yoomi_projects/models/project.dart';


class TestData {
  static final List<Project> projects = [
    Project(
      id: '1',
      name: 'Residence A',
      status: ProjectStatus.published,
      amount: 120000,
      createdAt: DateTime.parse('2024-01-10T10:00:00Z'),
    ),
    Project(
      id: '2',
      name: 'Loft B',
      status: ProjectStatus.draft,
      amount: 85000,
      createdAt: DateTime.parse('2024-02-05T12:30:00Z'),
    ),
    Project(
      id: '3',
      name: 'Villa C',
      status: ProjectStatus.archived,
      amount: 240000,
      createdAt: DateTime.parse('2023-11-20T09:15:00Z'),
    ),
    Project(
      id: '4',
      name: 'Immeuble D',
      status: ProjectStatus.published,
      amount: 410000,
      createdAt: DateTime.parse('2024-03-01T08:00:00Z'),
    ),
    Project(
      id: '5',
      name: 'Studio E',
      status: ProjectStatus.draft,
      amount: 60000,
      createdAt: DateTime.parse('2024-04-18T14:45:00Z'),
    ),
  ];

  static Project get sampleProject => projects.first;

  static Map<String, dynamic> get sampleProjectJson => {
    'id': '1',
    'name': 'Residence A',
    'status': 'PUBLISHED',
    'amount': 120000,
    'createdAt': '2024-01-10T10:00:00.000Z',
  };

  static Map<String, dynamic> get paginatedResponseJson => {
    'data': projects.map((p) => {
      'id': p.id,
      'name': p.name,
      'status': p.status.value,
      'amount': p.amount,
      'createdAt': p.createdAt.toIso8601String(),
    }).toList(),
    'total': projects.length,
    'page': 1,
    'pageSize': 10,
  };

  static const String validProjectName = 'Test Project';
  static const double validAmount = 50000.0;
  static const ProjectStatus validStatus = ProjectStatus.draft;
}