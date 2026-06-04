import 'compte_entity.dart';
// ClasseEntity représente une classe comptable
// qui regroupe plusieurs comptes
class ClasseEntity {
  final String numero;       // Ex: "1", "2", "5"
  final String intitule;     // Ex: "Comptes de ressources durables"
  final PlanComptable plan;  // À quel plan cette classe appartient

  const ClasseEntity({
    required this.numero,
    required this.intitule,
    required this.plan,
  });
}