import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/favoris_provider.dart';
import '../../core/providers/plan_provider.dart';
import '../../data/models/noeud_comptable_model.dart';
import '../../domain/entities/compte_entity.dart';

class PlanScreen extends ConsumerStatefulWidget {
  final PlanComptable plan;

  const PlanScreen({super.key, required this.plan});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  final TextEditingController _recherche = TextEditingController();
  String _texteRecherche = '';
  final Set<String> _noeudsOuverts = {};

  // ── Debounce : attend 300ms après la dernière frappe ──
  Timer? _debounce;

  Color get _couleurPlan {
    switch (widget.plan) {
      case PlanComptable.etatBenin:
        return const Color(0xFF2E7D32);
      case PlanComptable.communalBenin:
        return const Color(0xFFF9A825);
      case PlanComptable.syscohada:
        return const Color(0xFFD32F2F);
    }
  }

  String get _titrePlan {
    switch (widget.plan) {
      case PlanComptable.etatBenin:
        return 'Plan Comptable de l\'État';
      case PlanComptable.communalBenin:
        return 'Plan Comptable Communal';
      case PlanComptable.syscohada:
        return 'SYSCOHADA Révisé';
    }
  }

  List<Map<String, String>> get _notifications {
    switch (widget.plan) {
      case PlanComptable.etatBenin:
        return [
          {'date': 'Jan 2024', 'message': 'Ajout compte 106 — Réserves de l\'État'},
          {'date': 'Mar 2024', 'message': 'Mise à jour intitulé compte 411 — Redevables'},
          {'date': 'Juin 2024', 'message': 'Nouveau compte 721 — Recettes non fiscales'},
        ];
      case PlanComptable.communalBenin:
        return [
          {'date': 'Fév 2024', 'message': 'Ajout compte 131 — Subventions d\'équipement'},
          {'date': 'Avr 2024', 'message': 'Révision compte 441 — Contribuables'},
        ];
      case PlanComptable.syscohada:
        return [
          {'date': 'Jan 2024', 'message': 'Révision SYSCOHADA — Mise à jour classe 5'},
          {'date': 'Mai 2024', 'message': 'Ajout sous-compte 5211 — Banques locales'},
          {'date': 'Juil 2024', 'message': 'Modification intitulé compte 101'},
        ];
    }
  }

  // ── Appelé à chaque frappe — attend 300ms avant d'appliquer ──
  void _onRechercheChange(String val) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _texteRecherche = val;
        });
      }
    });
  }

  bool _noeudMatchRecherche(NoeudCompte noeud) {
    if (_texteRecherche.isEmpty) return true;
    final r = _texteRecherche.toLowerCase();
    if (noeud.numero.contains(r) ||
        noeud.intitule.toLowerCase().contains(r)) return true;
    return noeud.enfants.any(_noeudMatchRecherche);
  }

  void _ouvrirTout(List<NoeudCompte> noeuds) {
    for (final n in noeuds) {
      _noeudsOuverts.add(n.numero);
      if (n.enfants.isNotEmpty) _ouvrirTout(n.enfants);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel(); // Important : annuler le timer à la fermeture
    _recherche.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favorisNotifier = ref.read(favorisProvider.notifier);
    final favoris = ref.watch(favorisProvider);
    final noeudsAsync = ref.watch(noeudsClassesProvider(widget.plan));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: _couleurPlan,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          _titrePlan,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () => _afficherNotifications(context),
          ),
        ],
      ),

      body: Column(
        children: [

          // ── Barre de recherche ───────────────────────
          Container(
            color: _couleurPlan,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _recherche,
              onChanged: _onRechercheChange, // ← debounce ici
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher un numéro ou un intitulé...',
                hintStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: _texteRecherche.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white70),
                        onPressed: () {
                          _debounce?.cancel();
                          _recherche.clear();
                          setState(() {
                            _texteRecherche = '';
                            _noeudsOuverts.clear();
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── Contenu principal ────────────────────────
          Expanded(
            child: noeudsAsync.when(
              loading: () => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: _couleurPlan),
                    const SizedBox(height: 16),
                    Text(
                      'Chargement du plan comptable...',
                      style: TextStyle(color: _couleurPlan),
                    ),
                  ],
                ),
              ),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Erreur de chargement',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              data: (structure) {
                if (_texteRecherche.isNotEmpty) {
                  _ouvrirTout(structure);
                }

                final structureFiltree = structure
                    .where(_noeudMatchRecherche)
                    .toList();

                if (structureFiltree.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'Aucun résultat pour "$_texteRecherche"',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: structureFiltree.length,
                  itemBuilder: (context, index) {
                    final noeud = structureFiltree[index];
                    return _NoeudWidget(
                      noeud: noeud,
                      couleur: _couleurPlan,
                      noeudsOuverts: _noeudsOuverts,
                      plan: widget.plan,
                      favoris: favoris,
                      onToggle: (numero) {
                        setState(() {
                          if (_noeudsOuverts.contains(numero)) {
                            _noeudsOuverts.remove(numero);
                          } else {
                            _noeudsOuverts.add(numero);
                          }
                        });
                      },
                      onFavori: (noeud) {
                        final item = FavoriItem(
                          numero: noeud.numero,
                          intitule: noeud.intitule,
                          description: noeud.description,
                          plan: widget.plan,
                        );
                        favorisNotifier.toggle(item);
                      },
                      texteRecherche: _texteRecherche,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _afficherNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.notifications, color: _couleurPlan),
            const SizedBox(width: 8),
            const Text('Mises à jour', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: _notifications
                .map((n) => _ItemNotification(
                      date: n['date']!,
                      message: n['message']!,
                      couleur: _couleurPlan,
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer', style: TextStyle(color: _couleurPlan)),
          ),
        ],
      ),
    );
  }
}

// ── Widget récursif pour les noeuds ───────────────────
class _NoeudWidget extends StatelessWidget {
  final NoeudCompte noeud;
  final Color couleur;
  final Set<String> noeudsOuverts;
  final PlanComptable plan;
  final List<FavoriItem> favoris;
  final Function(String) onToggle;
  final Function(NoeudCompte) onFavori;
  final String texteRecherche;

  const _NoeudWidget({
    required this.noeud,
    required this.couleur,
    required this.noeudsOuverts,
    required this.plan,
    required this.favoris,
    required this.onToggle,
    required this.onFavori,
    required this.texteRecherche,
  });

  bool get _estOuvert => noeudsOuverts.contains(noeud.numero);
  bool get _aEnfants => noeud.enfants.isNotEmpty;
  bool get _estFavori =>
      favoris.any((f) => f.numero == noeud.numero && f.plan == plan);

  double get _indentation => (noeud.niveau - 1) * 16.0;

  Color get _fondCouleur {
    switch (noeud.niveau) {
      case 1: return Colors.white;
      case 2: return const Color(0xFFF5F5F5);
      case 3: return const Color(0xFFFAFAFA);
      case 4: return const Color(0xFFFFFDE7);
      default: return Colors.white;
    }
  }

  double get _taillePoliceTitre {
    switch (noeud.niveau) {
      case 1: return 15;
      case 2: return 14;
      case 3: return 13;
      case 4: return 12;
      default: return 13;
    }
  }

  FontWeight get _graisse {
    switch (noeud.niveau) {
      case 1: return FontWeight.bold;
      case 2: return FontWeight.w600;
      default: return FontWeight.normal;
    }
  }

  Widget _buildTexteSurligne(String texte, String recherche, TextStyle style) {
    if (recherche.isEmpty) return Text(texte, style: style);
    final r = recherche.toLowerCase();
    final lower = texte.toLowerCase();
    final index = lower.indexOf(r);
    if (index < 0) return Text(texte, style: style);
    return RichText(
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: texte.substring(0, index)),
          TextSpan(
            text: texte.substring(index, index + r.length),
            style: style.copyWith(
              backgroundColor: Colors.yellow.shade300,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: texte.substring(index + r.length)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: _indentation, bottom: 4),
      child: Container(
        decoration: BoxDecoration(
          color: _fondCouleur,
          borderRadius: BorderRadius.circular(12),
          border: noeud.niveau == 1
              ? Border.all(color: couleur.withOpacity(0.2))
              : null,
          boxShadow: noeud.niveau == 1
              ? [BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )]
              : null,
        ),
        child: Column(
          children: [
            InkWell(
              onTap: _aEnfants ? () => onToggle(noeud.numero) : null,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: noeud.niveau == 1 ? 14 : 10,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: couleur.withOpacity(
                            noeud.niveau == 1 ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        noeud.numero,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: couleur,
                          fontSize: _taillePoliceTitre - 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTexteSurligne(
                        noeud.intitule,
                        texteRecherche,
                        TextStyle(
                          fontWeight: _graisse,
                          fontSize: _taillePoliceTitre,
                          color: const Color(0xFF1B3A2D),
                        ),
                      ),
                    ),
                    if (noeud.niveau >= 3)
                      IconButton(
                        icon: Icon(
                          _estFavori ? Icons.star : Icons.star_outline,
                          size: 20,
                          color: _estFavori
                              ? const Color(0xFFFDD835)
                              : Colors.grey.shade400,
                        ),
                        onPressed: () => onFavori(noeud),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    if (_aEnfants)
                      Icon(
                        _estOuvert
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: couleur,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
            if (noeud.niveau >= 3 && noeud.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    noeud.description,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
              ),
            if (_estOuvert && _aEnfants)
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                child: Column(
                  children: noeud.enfants.map((enfant) => _NoeudWidget(
                    noeud: enfant,
                    couleur: couleur,
                    noeudsOuverts: noeudsOuverts,
                    plan: plan,
                    favoris: favoris,
                    onToggle: onToggle,
                    onFavori: onFavori,
                    texteRecherche: texteRecherche,
                  )).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Item notification ──────────────────────────────────
class _ItemNotification extends StatelessWidget {
  final String date;
  final String message;
  final Color couleur;

  const _ItemNotification({
    required this.date,
    required this.message,
    required this.couleur,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 8, color: couleur),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(message, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
