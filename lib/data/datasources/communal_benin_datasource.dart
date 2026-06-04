import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/plan_comptable_model.dart';
import '../../domain/entities/compte_entity.dart';

// CommunalBeninDatasource lit le plan comptable
// Communal du Bénin depuis les assets
class CommunalBeninDatasource {

  Future<PlanComptableModel> chargerPlan() async {
    
    final contenu = await rootBundle.loadString(
      'assets/data/communal_benin/communal_benin.json',
    );

    final json = jsonDecode(contenu) as Map<String, dynamic>;

    return PlanComptableModel.fromJson(json, PlanComptable.communalBenin);
  }
}