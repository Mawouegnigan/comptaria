import 'compte_entity.dart';
import 'classe_entity.dart';

// PlanComptableEntity représente un plan comptable complet
// avec toutes ses classes et tous ses comptes
class PlanComptableEntity {
  final PlanComptable type;        // Lequel des 3 plans
  final String nom;                // Nom complet du plan
  final String description;        // Courte description
  final List<ClasseEntity> classes; // La liste des classes
  final List<CompteEntity> comptes; // La liste des comptes

  const PlanComptableEntity({
    required this.type,
    required this.nom,
    required this.description,
    required this.classes,
    required this.comptes,
  });
}