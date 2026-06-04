// Une "enum" est une liste de choix fixes.
// Ici on définit les 3 plans comptables de l'app.
enum PlanComptable {
  etatBenin,      // Plan Comptable de l'État Béninois
  communalBenin,  // Plan Comptable Communal du Bénin
  syscohada,      // SYSCOHADA Révisé
}

// Une "class" est un modèle — comme un formulaire vide.
// CompteEntity décrit ce qu'est un compte comptable.
class CompteEntity {
  final String numero;        // Ex: "101", "5111"
  final String intitule;      // Ex: "Capital social"
  final String classe;        // Ex: "Classe 1"
  final String description;   // Explication du compte (peut être vide)
  final PlanComptable plan;   // À quel plan ce compte appartient

  // Le constructeur — obligatoire pour créer un compte
  const CompteEntity({
    required this.numero,
    required this.intitule,
    required this.classe,
    required this.description,
    required this.plan,
  });
}