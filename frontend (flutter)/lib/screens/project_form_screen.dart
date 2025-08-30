import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../providers/projects_provider.dart';

class ProjectFormScreen extends StatefulWidget {
  final Project? project; // null pour création, Project pour modification

  const ProjectFormScreen({Key? key, this.project}) : super(key: key);

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  
  ProjectStatus _selectedStatus = ProjectStatus.draft;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Si c'est une modification, pré-remplir les champs
    if (widget.project != null) {
      _nameController.text = widget.project!.name;
      _amountController.text = widget.project!.amount.toString();
      _selectedStatus = widget.project!.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.project != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier le projet' : 'Nouveau projet'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Champ nom
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom du projet *',
                hintText: 'Entrez le nom du projet',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom est obligatoire';
                }
                if (value.trim().length < 2) {
                  return 'Le nom doit faire au moins 2 caractères';
                }
                if (value.trim().length > 255) {
                  return 'Le nom ne peut pas dépasser 255 caractères';
                }
                return null;
              },
              maxLength: 255,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 20),
            
            // Sélection du statut
            DropdownButtonFormField<ProjectStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Statut *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
              ),
              items: ProjectStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Color(status.colorValue),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(status.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedStatus = value;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            
            // Champ montant
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Montant *',
                hintText: '0',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.euro),
                suffixText: '€',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le montant est obligatoire';
                }
                final amount = double.tryParse(value);
                if (amount == null) {
                  return 'Veuillez entrer un montant valide';
                }
                if (amount < 0) {
                  return 'Le montant doit être positif';
                }
                if (amount > 999999999) {
                  return 'Le montant est trop élevé';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            
            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProject,
                    child: Text(isEditing ? 'Modifier' : 'Créer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<ProjectsProvider>(context, listen: false);
    final name = _nameController.text.trim();
    final amount = double.parse(_amountController.text);

    bool success;
    
    if (widget.project != null) {
      // Modification
      success = await provider.updateProject(
        widget.project!.id,
        name: name,
        status: _selectedStatus,
        amount: amount,
      );
    } else {
      // Création
      success = await provider.createProject(
        name: name,
        status: _selectedStatus,
        amount: amount,
      );
    }

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.project != null 
              ? 'Projet modifié avec succès' 
              : 'Projet créé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Une erreur est survenue'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}