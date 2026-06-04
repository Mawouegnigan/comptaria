import '../../domain/entities/compte_entity.dart';
import '../../domain/entities/classe_entity.dart';
import 'noeud_comptable_model.dart';

// ClasseModel sait lire une classe comptable depuis un fichier JSON
class ClasseModel extends ClasseEntity {

  // Les comptes de niveau 2 de cette classe
  final List<NoeudComptableModel> comptes;

  const ClasseModel({
    required super.numero,
    required super.intitule,
    required super.plan,
    required this.comptes,
  });

  // Convertit un JSON en ClasseModel avec toute la hiérarchie
  factory ClasseModel.fromJson(
      Map<String, dynamic> json, PlanComptable plan) {
    return ClasseModel(
      numero: json['numero'] as String,
      intitule: json['intitule'] as String,
      plan: plan,
      comptes: (json['comptes'] as List<dynamic>? ?? [])
          .map((c) => NoeudComptableModel.fromJson(
              c as Map<String, dynamic>, plan, 2))
          .toList(),
    );
  }
}
