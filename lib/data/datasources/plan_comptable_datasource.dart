import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/plan_comptable_model.dart';
import '../models/noeud_comptable_model.dart';
import '../../domain/entities/compte_entity.dart';

// PlanComptableDatasource charge n'importe quel plan
// depuis les assets JSON
class PlanComptableDatasource {

  // Charge un plan selon son type
  Future<PlanComptableModel> chargerPlan(PlanComptable plan) async {
    final chemin = _cheminAsset(plan);
    final contenu = await rootBundle.loadString(chemin);
    final json = jsonDecode(contenu) as Map<String, dynamic>;
    return PlanComptableModel.fromJson(json, plan);
  }

  // Retourne le chemin du fichier JSON selon le plan
  String _cheminAsset(PlanComptable plan) {
    switch (plan) {
      case PlanComptable.etatBenin:
        return 'assets/data/etat_benin/etat_benin.json';
      case PlanComptable.communalBenin:
        return 'assets/data/communal_benin/communal_benin.json';
      case PlanComptable.syscohada:
        return 'assets/data/syscohada/syscohada.json';
    }
  }
}

// Datasources spécifiques (gardées pour compatibilité)
class EtatBeninDatasource {
  final _source = PlanComptableDatasource();
  Future<PlanComptableModel> chargerPlan() =>
      _source.chargerPlan(PlanComptable.etatBenin);
}

class CommunalBeninDatasource {
  final _source = PlanComptableDatasource();
  Future<PlanComptableModel> chargerPlan() =>
      _source.chargerPlan(PlanComptable.communalBenin);
}

class SyscohadaDatasource {
  final _source = PlanComptableDatasource();
  Future<PlanComptableModel> chargerPlan() =>
      _source.chargerPlan(PlanComptable.syscohada);
}
