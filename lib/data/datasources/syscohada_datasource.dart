import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/plan_comptable_model.dart';
import '../../domain/entities/compte_entity.dart';

// SysohadaDatasource est responsable de lire
// le fichier JSON du SYSCOHADA et de le convertir
class SysohadaDatasource {

  // Cette fonction lit le fichier JSON et retourne
  // un PlanComptableModel prêt à utiliser
  Future<PlanComptableModel> chargerPlan() async {
    
    // On lit le fichier JSON depuis les assets
    final contenu = await rootBundle.loadString(
      'assets/data/syscohada/syscohada.json',
    );

    // On convertit le texte JSON en Map Dart
    final json = jsonDecode(contenu) as Map<String, dynamic>;

    // On retourne le modèle complet
    return PlanComptableModel.fromJson(json, PlanComptable.syscohada);
  }
}