import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router.dart';
import '../../core/app_colors.dart';
import '../../core/providers/favoris_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/providers/plan_provider.dart';
import '../../data/models/noeud_comptable_model.dart';
import '../../domain/entities/compte_entity.dart';

class CompteComparaison {
  final String numero;
  final String intitule;
  final String description;
  final PlanComptable plan;
  final bool existe;

  const CompteComparaison({
    required this.numero,
    required this.intitule,
    required this.description,
    required this.plan,
    required this.existe,
  });

  String get nomPlanCourt {
    switch (plan) {
      case PlanComptable.etatBenin:
        return 'PCE';
      case PlanComptable.communalBenin:
        return 'PCC';
      case PlanComptable.syscohada:
        return 'PCS';
    }
  }

  String get nomPlanComplet {
    switch (plan) {
      case PlanComptable.etatBenin:
        return 'Plan Comptable\nÉtat Béninois';
      case PlanComptable.communalBenin:
        return 'Plan Comptable\nCommunal';
      case PlanComptable.syscohada:
        return 'SYSCOHADA\nRévisé';
    }
  }

  Color get couleur {
    switch (plan) {
      case PlanComptable.etatBenin:
        return const Color(0xFF2E7D32);
      case PlanComptable.communalBenin:
        return const Color(0xFFF9A825);
      case PlanComptable.syscohada:
        return const Color(0xFFD32F2F);
    }
  }
}

class CompareScreen extends ConsumerStatefulWidget {
  const CompareScreen({super.key});

  @override
  ConsumerState<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends ConsumerState<CompareScreen> {
  final TextEditingController _controller = TextEditingController();
  String _numeroRecherche = '';
  List<CompteComparaison>? _resultats;
  bool _chargement = false;
  Timer? _debounce;

  // Cherche un compte par numéro dans une liste de noeuds (récursif)
  NoeudCompte? _chercherDansNoeuds(List<NoeudCompte> noeuds, String numero) {
    for (final n in noeuds) {
      if (n.numero == numero) return n;
      if (n.enfants.isNotEmpty) {
        final trouve = _chercherDansNoeuds(n.enfants, numero);
        if (trouve != null) return trouve;
      }
    }
    return null;
  }

  // Compare le compte dans les 3 plans depuis les vraies données
  Future<void> _comparer(String numero) async {
    final n = numero.trim();
    if (n.isEmpty) return;

    setState(() {
      _numeroRecherche = n;
      _chargement = true;
      _resultats = null;
    });

    try {
      // Charger les 3 plans en parallèle
      final resultats = await Future.wait([
        ref.read(noeudsClassesProvider(PlanComptable.etatBenin).future),
        ref.read(noeudsClassesProvider(PlanComptable.communalBenin).future),
        ref.read(noeudsClassesProvider(PlanComptable.syscohada).future),
      ]);

      final plans = [
        PlanComptable.etatBenin,
        PlanComptable.communalBenin,
        PlanComptable.syscohada,
      ];

      final comparaisons = <CompteComparaison>[];

      for (int i = 0; i < 3; i++) {
        final noeud = _chercherDansNoeuds(resultats[i], n);
        comparaisons.add(CompteComparaison(
          numero: n,
          intitule: noeud?.intitule ?? '',
          description: noeud?.description ?? '',
          plan: plans[i],
          existe: noeud != null,
        ));
      }

      if (mounted) {
        setState(() {
          _resultats = comparaisons;
          _chargement = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _chargement = false;
          _resultats = [];
        });
      }
    }
  }

  // Suggestions dynamiques depuis le PCE (les 5 premiers comptes niveau 2)
  List<String> _suggestions(List<NoeudCompte> noeuds) {
    final suggestions = <String>[];
    for (final classe in noeuds) {
      for (final compte in classe.enfants) {
        suggestions.add(compte.numero);
        if (suggestions.length >= 6) break;
      }
      if (suggestions.length >= 6) break;
    }
    return suggestions;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(themeProvider);
    final favorisNotifier = ref.read(favorisProvider.notifier);
    final favoris = ref.watch(favorisProvider);

    final couleurFond = AppColors.fond(mode);
    final couleurCarte = AppColors.carte(mode);
    final couleurTexte = AppColors.texte(mode);
    final couleurAppBar = AppColors.appBar(mode);
    final couleurTexteAppBar = AppColors.texteAppBar(mode);
    final couleurChamp = AppColors.champRecherche(mode);
    final estSombre = mode == ModeTheme.sombre;

    // On charge les noeuds PCE pour les suggestions
    final noeudsAsync = ref.watch(noeudsClassesProvider(PlanComptable.etatBenin));

    return Scaffold(
      backgroundColor: couleurFond,
      bottomNavigationBar: _BarreNavigation(estSombre: estSombre),
      appBar: AppBar(
        backgroundColor: couleurAppBar,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Comparatif',
          style: TextStyle(
            color: couleurTexteAppBar,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [

          // ── Barre de recherche ───────────────────
          Container(
            color: couleurCarte,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: couleurTexte),
                    onSubmitted: _comparer,
                    onChanged: (val) {
                      if (val.isEmpty) {
                        setState(() {
                          _numeroRecherche = '';
                          _resultats = null;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Entrez un numéro de compte (ex: 101)',
                      hintStyle: TextStyle(
                          color: couleurTexte.withOpacity(0.4),
                          fontSize: 13),
                      prefixIcon: Icon(Icons.compare_arrows,
                          color: couleurTexte.withOpacity(0.6)),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear,
                                  color: couleurTexte.withOpacity(0.6)),
                              onPressed: () {
                                setState(() {
                                  _controller.clear();
                                  _numeroRecherche = '';
                                  _resultats = null;
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: couleurChamp,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _chargement
                      ? null
                      : () => _comparer(_controller.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    elevation: 0,
                  ),
                  child: _chargement
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Comparer'),
                ),
              ],
            ),
          ),

          // ── Suggestions dynamiques ───────────────
          if (_resultats == null && !_chargement)
            Container(
              color: couleurCarte,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Comptes fréquents :',
                    style: TextStyle(
                        fontSize: 12,
                        color: couleurTexte.withOpacity(0.5)),
                  ),
                  const SizedBox(height: 8),
                  noeudsAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (noeuds) => Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _suggestions(noeuds).map((s) {
                        return GestureDetector(
                          onTap: () {
                            _controller.text = s;
                            _comparer(s);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32)
                                  .withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF2E7D32)
                                    .withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              s,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

          Divider(height: 1, color: AppColors.diviseur(mode)),

          // ── Contenu principal ────────────────────
          Expanded(
            child: _chargement
                ? const Center(child: CircularProgressIndicator(
                    color: Color(0xFF2E7D32)))
                : _resultats == null
                    ? _EcranVide(couleurTexte: couleurTexte)
                    : _resultats!.every((r) => !r.existe)
                        ? _AucunResultat(
                            numero: _numeroRecherche,
                            couleurTexte: couleurTexte)
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [

                                // En-tête
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: couleurCarte,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Compte N° $_numeroRecherche',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: couleurTexte,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Comparaison dans les 3 plans',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: couleurTexte.withOpacity(0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                ..._resultats!.map((compte) {
                                  final estFavori = favoris.any((f) =>
                                      f.numero == compte.numero &&
                                      f.plan == compte.plan);
                                  return _CarteComparaison(
                                    compte: compte,
                                    estFavori: estFavori,
                                    couleurCarte: couleurCarte,
                                    couleurTexte: couleurTexte,
                                    onFavori: () {
                                      favorisNotifier.toggle(FavoriItem(
                                        numero: compte.numero,
                                        intitule: compte.intitule,
                                        description: compte.description,
                                        plan: compte.plan,
                                      ));
                                    },
                                  );
                                }),

                                const SizedBox(height: 16),

                                _ResumeDifferences(
                                  resultats: _resultats!,
                                  couleurTexte: couleurTexte,
                                  mode: mode,
                                ),
                              ],
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

// ── Carte comparaison ──────────────────────────────────
class _CarteComparaison extends StatelessWidget {
  final CompteComparaison compte;
  final bool estFavori;
  final VoidCallback onFavori;
  final Color couleurCarte;
  final Color couleurTexte;

  const _CarteComparaison({
    required this.compte,
    required this.estFavori,
    required this.onFavori,
    required this.couleurCarte,
    required this.couleurTexte,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: couleurCarte,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: compte.existe
              ? compte.couleur.withOpacity(0.3)
              : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge plan
            Container(
              width: 56,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: compte.existe
                    ? compte.couleur.withOpacity(0.1)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    compte.nomPlanCourt,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: compte.existe ? compte.couleur : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    compte.existe
                        ? Icons.check_circle
                        : Icons.cancel_outlined,
                    size: 16,
                    color: compte.existe
                        ? compte.couleur
                        : Colors.grey.shade400,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Contenu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    compte.nomPlanComplet,
                    style: TextStyle(
                      fontSize: 11,
                      color: couleurTexte.withOpacity(0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  compte.existe
                      ? Text(
                          compte.intitule,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: couleurTexte,
                          ),
                        )
                      : Text(
                          'Compte non défini dans ce plan',
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: couleurTexte.withOpacity(0.4),
                          ),
                        ),
                  if (compte.existe && compte.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        compte.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: couleurTexte.withOpacity(0.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Favori
            if (compte.existe)
              GestureDetector(
                onTap: onFavori,
                child: Icon(
                  estFavori ? Icons.star : Icons.star_outline,
                  color: estFavori
                      ? const Color(0xFFFDD835)
                      : Colors.grey.shade400,
                  size: 22,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Résumé différences ─────────────────────────────────
class _ResumeDifferences extends StatelessWidget {
  final List<CompteComparaison> resultats;
  final Color couleurTexte;
  final ModeTheme mode;

  const _ResumeDifferences({
    required this.resultats,
    required this.couleurTexte,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final existeDans = resultats.where((r) => r.existe).length;
    final total = resultats.length;
    final intitulesDifferents = resultats
            .where((r) => r.existe)
            .map((r) => r.intitule.toLowerCase().trim())
            .toSet()
            .length > 1;

    final fondAnalyse = mode == ModeTheme.sombre
        ? const Color(0xFF1A2E1A)
        : const Color(0xFFF0F7F0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fondAnalyse,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2E7D32).withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Color(0xFF2E7D32)),
              SizedBox(width: 6),
              Text(
                'Analyse',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '• Présent dans $existeDans plan${existeDans > 1 ? 's' : ''} sur $total',
            style: TextStyle(fontSize: 13, color: couleurTexte),
          ),
          const SizedBox(height: 4),
          Text(
            intitulesDifferents
                ? '• Les intitulés diffèrent selon les plans'
                : '• Les intitulés sont identiques dans tous les plans',
            style: TextStyle(fontSize: 13, color: couleurTexte),
          ),
          if (existeDans < total) ...[
            const SizedBox(height: 4),
            Text(
              '• Absent dans ${total - existeDans} plan${total - existeDans > 1 ? 's' : ''}',
              style: TextStyle(
                  fontSize: 13, color: Colors.orange.shade700),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Écran vide ─────────────────────────────────────────
class _EcranVide extends StatelessWidget {
  final Color couleurTexte;
  const _EcranVide({required this.couleurTexte});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.compare_arrows,
              size: 64, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 16),
          Text(
            'Comparez un compte dans les 3 plans',
            style: TextStyle(
              color: couleurTexte.withOpacity(0.5),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Entrez un numéro et appuyez sur Comparer',
            style: TextStyle(
                color: couleurTexte.withOpacity(0.4), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ── Aucun résultat ─────────────────────────────────────
class _AucunResultat extends StatelessWidget {
  final String numero;
  final Color couleurTexte;
  const _AucunResultat({required this.numero, required this.couleurTexte});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 16),
          Text(
            'Compte "$numero" introuvable',
            style: TextStyle(
              color: couleurTexte.withOpacity(0.5),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ce numéro n\'existe dans aucun des 3 plans',
            style: TextStyle(
                color: couleurTexte.withOpacity(0.4), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ── Barre de navigation ────────────────────────────────
class _BarreNavigation extends StatelessWidget {
  final bool estSombre;
  const _BarreNavigation({required this.estSombre});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 2,
      selectedItemColor: const Color(0xFF2E7D32),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      backgroundColor: estSombre ? const Color(0xFF1E1E1E) : Colors.white,
      onTap: (index) {
        switch (index) {
          case 0: context.go(AppRoutes.home); break;
          case 1: context.go(AppRoutes.search); break;
          case 2: context.go(AppRoutes.compare); break;
          case 3: context.go(AppRoutes.favoris); break;
          case 4: context.go(AppRoutes.profil); break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Recherche',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.compare_arrows),
          label: 'Comparatif',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.star_outline),
          activeIcon: Icon(Icons.star),
          label: 'Favoris',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}
