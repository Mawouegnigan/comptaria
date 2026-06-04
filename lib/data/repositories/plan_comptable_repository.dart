import '../../domain/entities/compte_entity.dart';
import '../../domain/entities/plan_comptable_entity.dart';
import '../datasources/syscohada_datasource.dart';
import '../datasources/plan_comptable_datasource.dart';
import '../datasources/communal_benin_datasource.dart';

// PlanComptableRepository est le point central
// qui donne accès aux 3 plans comptables
class PlanComptableRepository {

  // Les 3 datasources
  final _syscohada = SysohadaDatasource();
  final _etatBenin = EtatBeninDatasource();
  final _communalBenin = CommunalBeninDatasource();

  // Charge un plan selon le type demandé
  Future<PlanComptableEntity> chargerPlan(PlanComptable plan) async {
    switch (plan) {
      case PlanComptable.syscohada:
        return _syscohada.chargerPlan();
      case PlanComptable.etatBenin:
        return _etatBenin.chargerPlan();
      case PlanComptable.communalBenin:
        return _communalBenin.chargerPlan();
    }
  }

  // Charge les 3 plans d'un coup
  Future<List<PlanComptableEntity>> chargerTousLesPlans() async {
    final resultats = await Future.wait([
      _syscohada.chargerPlan(),
      _etatBenin.chargerPlan(),
      _communalBenin.chargerPlan(),
    ]);
    return resultats;
  }
}