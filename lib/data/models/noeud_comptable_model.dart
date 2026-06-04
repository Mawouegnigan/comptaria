import '../../domain/entities/compte_entity.dart';

// NoeudComptableModel représente un compte à n'importe quel niveau
// de la hiérarchie (niveau 2, 3 ou 4)
class NoeudComptableModel {
  final String numero;
  final String intitule;
  final int niveau;
  final PlanComptable plan;
  final List<NoeudComptableModel> enfants;

  const NoeudComptableModel({
    required this.numero,
    required this.intitule,
    required this.niveau,
    required this.plan,
    required this.enfants,
  });

  factory NoeudComptableModel.fromJson(
      Map<String, dynamic> json, PlanComptable plan, int niveau) {

    // Niveau 2 → ses enfants sont dans "sousComptes"
    // Niveau 3 → ses enfants sont dans "comptes"
    // Niveau 4 → pas d'enfants
    List<dynamic> enfantsJson = [];
    if (niveau == 2) {
      enfantsJson = json['sousComptes'] as List<dynamic>? ?? [];
    } else if (niveau == 3) {
      enfantsJson = json['comptes'] as List<dynamic>? ?? [];
    }

    return NoeudComptableModel(
      numero: json['numero'] as String,
      intitule: json['intitule'] as String,
      niveau: niveau,
      plan: plan,
      enfants: enfantsJson
          .map((e) => NoeudComptableModel.fromJson(
              e as Map<String, dynamic>, plan, niveau + 1))
          .toList(),
    );
  }

  // Convertit en NoeudCompte pour l'affichage dans PlanScreen
  NoeudCompte toNoeudCompte() {
    return NoeudCompte(
      numero: numero,
      intitule: intitule,
      description: '',
      niveau: niveau,
      enfants: enfants.map((e) => e.toNoeudCompte()).toList(),
    );
  }
}

// NoeudCompte — utilisé uniquement pour l'affichage dans PlanScreen
class NoeudCompte {
  final String numero;
  final String intitule;
  final String description;
  final int niveau;
  final List<NoeudCompte> enfants;

  const NoeudCompte({
    required this.numero,
    required this.intitule,
    required this.description,
    required this.niveau,
    this.enfants = const [],
  });
}
