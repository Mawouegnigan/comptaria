import '../../domain/entities/compte_entity.dart';

// CompteModel sait lire un compte depuis un fichier JSON
class CompteModel extends CompteEntity {

  const CompteModel({
    required super.numero,
    required super.intitule,
    required super.classe,
    required super.description,
    required super.plan,
  });

  // Cette fonction convertit un JSON en CompteModel
  // Ex: {"numero": "101", "intitule": "Capital social", ...}
  factory CompteModel.fromJson(
      Map<String, dynamic> json, PlanComptable plan) {
    return CompteModel(
      numero: json['numero'] as String,
      intitule: json['intitule'] as String,
      classe: json['classe'] as String,
      description: json['description'] as String? ?? '',
      plan: plan,
    );
  }
}