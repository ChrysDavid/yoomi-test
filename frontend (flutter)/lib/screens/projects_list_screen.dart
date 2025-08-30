import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../providers/projects_provider.dart';
import '../widgets/project_card.dart';
import 'project_form_screen.dart';

class ProjectsListScreen extends StatefulWidget {
  const ProjectsListScreen({Key? key}) : super(key: key);

  @override
  State<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends State<ProjectsListScreen> {
  final _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    
    // Initialiser les données au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProjectsProvider>(context, listen: false).init();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Projets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshProjects(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche et filtres
          _buildSearchAndFilters(),
          
          // Liste des projets
          Expanded(
            child: Consumer<ProjectsProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.projects.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Chargement des projets...'),
                      ],
                    ),
                  );
                }

                if (provider.error != null && provider.projects.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Erreur de chargement',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshProjects,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.projects.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.work_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun projet trouvé',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Commencez par créer votre premier projet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _createProject,
                          icon: const Icon(Icons.add),
                          label: const Text('Créer un projet'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refreshProjects,
                  child: ListView.builder(
                    itemCount: provider.projects.length + 
                               (provider.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Indicateur de chargement en bas
                      if (index == provider.projects.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final project = provider.projects[index];
                      return ProjectCard(
                        project: project,
                        onTap: () => _showProjectDetails(project),
                        onEdit: () => _editProject(project),
                        onDelete: () => _deleteProject(project),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createProject,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Consumer<ProjectsProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              // Barre de recherche
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher un projet...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            provider.search('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.background,
                ),
                onChanged: (value) {
                  provider.search(value);
                },
              ),
              const SizedBox(height: 12),
              
              // Filtres par statut
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      'Tous',
                      provider.statusFilter == null,
                      () => provider.filterByStatus(null),
                    ),
                    const SizedBox(width: 8),
                    ...ProjectStatus.values.map((status) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildFilterChip(
                          status.displayName,
                          provider.statusFilter == status,
                          () => provider.filterByStatus(status),
                          color: Color(status.colorValue),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              
              // Indicateur d'erreur
              if (provider.error != null && provider.projects.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, 
                                 color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          provider.error!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap, {
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? (color ?? Theme.of(context).primaryColor)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? (color ?? Theme.of(context).primaryColor)
                : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected 
                ? Colors.white 
                : (color ?? Colors.grey[700]),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Future<void> _refreshProjects() async {
    await Provider.of<ProjectsProvider>(context, listen: false).loadProjects();
  }

  void _createProject() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProjectFormScreen(),
      ),
    );
  }

  void _editProject(Project project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectFormScreen(project: project),
      ),
    );
  }

  Future<void> _deleteProject(Project project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le projet'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le projet "${project.name}" ?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final provider = Provider.of<ProjectsProvider>(context, listen: false);
      final success = await provider.deleteProject(project.id);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Projet supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Erreur lors de la suppression'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showProjectDetails(Project project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Poignée
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      // Titre
                      Text(
                        project.name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Statut
                      _buildDetailRow(
                        'Statut',
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(project.status.colorValue).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Color(project.status.colorValue),
                            ),
                          ),
                          child: Text(
                            project.status.displayName,
                            style: TextStyle(
                              color: Color(project.status.colorValue),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      
                      // Montant
                      _buildDetailRow(
                        'Montant',
                        Text(
                          '${project.amount.toStringAsFixed(0)} €',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                      
                      // Date de création
                      _buildDetailRow(
                        'Date de création',
                        Text(
                          '${project.createdAt.day.toString().padLeft(2, '0')}/'
                          '${project.createdAt.month.toString().padLeft(2, '0')}/'
                          '${project.createdAt.year} à '
                          '${project.createdAt.hour.toString().padLeft(2, '0')}:'
                          '${project.createdAt.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      
                      // ID (pour debug)
                      _buildDetailRow(
                        'Identifiant',
                        Text(
                          project.id,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _editProject(project);
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Modifier'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteProject(project);
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text(
                                'Supprimer',
                                style: TextStyle(color: Colors.red),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(child: value),
        ],
      ),
    );
  }
}