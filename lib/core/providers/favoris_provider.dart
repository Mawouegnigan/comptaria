import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/compte_entity.dart';

// Un favori contient le compte ET son plan d'origine
class FavoriItem {
  final String numero;
  final String intitule;
  final String description;
  final PlanComptable plan;

  const FavoriItem({
    required this.numero,
    required this.intitule,
    required this.description,
    required this.plan,
  });

  // Nom lisible du plan
  String get nomPlan {
    switch (plan) {
      case PlanComptable.etatBenin:
        return 'Plan Comptable État Béninois';
      case PlanComptable.communalBenin:
        return 'Plan Comptable Communal';
      case PlanComptable.syscohada:
        return 'SYSCOHADA Révisé';
    }
  }

  // Couleur du plan
  int get couleur {
    switch (plan) {
      case PlanComptable.etatBenin:
        return 0xFF2E7D32;
      case PlanComptable.communalBenin:
        return 0xFFF9A825;
      case PlanComptable.syscohada:
        return 0xFFD32F2F;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is FavoriItem &&
      other.numero == numero &&
      other.plan == plan;

  @override
  int get hashCode => Object.hash(numero, plan);
}

// Le provider qui gère la liste des favoris
class FavorisNotifier extends Notifier<List<FavoriItem>> {
  @override
  List<FavoriItem> build() => [];

  void toggle(FavoriItem item) {
    if (state.contains(item)) {
      state = state.where((f) => f != item).toList();
    } else {
      state = [...state, item];
    }
  }

  bool estFavori(String numero, PlanComptable plan) {
    return state.any((f) => f.numero == numero && f.plan == plan);
  }
}

// Provider global accessible partout dans l'app
final favorisProvider =
    NotifierProvider<FavorisNotifier, List<FavoriItem>>(
  FavorisNotifier.new,
);