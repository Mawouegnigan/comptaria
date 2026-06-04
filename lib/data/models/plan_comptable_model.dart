import '../../domain/entities/compte_entity.dart';
import '../../domain/entities/plan_comptable_entity.dart';
import 'classe_model.dart';
import 'compte_model.dart';
import 'noeud_comptable_model.dart';

// PlanComptableModel sait lire un plan comptable complet depuis JSON
class PlanComptableModel extends PlanComptableEntity {

  // Liste des classes avec leur hiérarchie complète
  final List<ClasseModel> classesCompletes;

  const PlanComptableModel({
    required super.type,
    required super.nom,
    required super.description,
    required super.classes,
    required super.comptes,
    required this.classesCompletes,
  });

  factory PlanComptableModel.fromJson(
      Map<String, dynamic> json, PlanComptable type) {

    // Lire les classes avec toute la hiérarchie
    final classesCompletes = (json['classes'] as List<dynamic>)
        .map((c) => ClasseModel.fromJson(c as Map<String, dynamic>, type))
        .toList();

    // Aplatir tous les comptes pour la compatibilité avec l'ancien code
    final List<CompteModel> tousLesComptes = [];
    for (final classe in classesCompletes) {
      _aplatirComptes(classe.comptes, classe.numero, type, tousLesComptes);
    }

    return PlanComptableModel(
      type: type,
      nom: json['nom'] as String,
      description: json['description'] as String? ?? '',
      classes: classesCompletes,
      comptes: tousLesComptes,
      classesCompletes: classesCompletes,
    );
  }

  // Aplatit récursivement tous les comptes de la hiérarchie
  static void _aplatirComptes(
    List<NoeudComptableModel> noeuds,
    String classeNumero,
    PlanComptable type,
    List<CompteModel> result,
  ) {
    for (final noeud in noeuds) {
      result.add(CompteModel(
        numero: noeud.numero,
        intitule: noeud.intitule,
        classe: classeNumero,
        description: '',
        plan: type,
      ));
      if (noeud.enfants.isNotEmpty) {
        _aplatirComptes(noeud.enfants, classeNumero, type, result);
      }
    }
  }

  // Convertit les classes en NoeudCompte pour PlanScreen
  List<NoeudCompte> toNoeudsClasses() {
    return classesCompletes.map((classe) {
      return NoeudCompte(
        numero: classe.numero,
        intitule: classe.intitule,
        description: '',
        niveau: 1,
        enfants: classe.comptes
            .map((c) => c.toNoeudCompte())
            .toList(),
      );
    }).toList();
  }
}
