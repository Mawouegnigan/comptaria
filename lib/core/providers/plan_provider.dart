import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/plan_comptable_datasource.dart';
import '../../data/models/plan_comptable_model.dart';
import '../../data/models/noeud_comptable_model.dart';
import '../../domain/entities/compte_entity.dart';

// Provider qui charge un plan comptable depuis les assets
// Utilisation : ref.watch(planComptableProvider(PlanComptable.etatBenin))
final planComptableProvider = FutureProvider.family<PlanComptableModel, PlanComptable>(
  (ref, plan) async {
    final datasource = PlanComptableDatasource();
    return datasource.chargerPlan(plan);
  },
);

// Provider qui retourne les noeuds prêts pour l'affichage dans PlanScreen
final noeudsClassesProvider = FutureProvider.family<List<NoeudCompte>, PlanComptable>(
  (ref, plan) async {
    final planModel = await ref.watch(planComptableProvider(plan).future);
    return planModel.toNoeudsClasses();
  },
);
