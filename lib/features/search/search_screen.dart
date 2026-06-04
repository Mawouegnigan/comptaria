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

class ResultatRecherche {
  final String numero;
  final String intitule;
  final String description;
  final String classe;
  final PlanComptable plan;

  const ResultatRecherche({
    required this.numero,
    required this.intitule,
    required this.description,
    required this.classe,
    required this.plan,
  });

  String get nomPlan {
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
        return 'Plan Comptable État Béninois';
      case PlanComptable.communalBenin:
        return 'Plan Comptable Communal';
      case PlanComptable.syscohada:
        return 'SYSCOHADA Révisé';
    }
  }

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
}

// Provider qui aplatit tous les comptes des 3 plans en une seule liste
final tousLesComptesProvider = FutureProvider<List<ResultatRecherche>>((ref) async {
  final resultats = await Future.wait([
    ref.watch(noeudsClassesProvider(PlanComptable.etatBenin).future),
    ref.watch(noeudsClassesProvider(PlanComptable.communalBenin).future),
    ref.watch(noeudsClassesProvider(PlanComptable.syscohada).future),
  ]);

  final plans = [
    PlanComptable.etatBenin,
    PlanComptable.communalBenin,
    PlanComptable.syscohada,
  ];

  final liste = <ResultatRecherche>[];

  for (int i = 0; i < 3; i++) {
    _aplatirNoeuds(resultats[i], plans[i], '', liste);
  }

  return liste;
});

// Aplatit récursivement les noeuds en ResultatRecherche
void _aplatirNoeuds(
  List<NoeudCompte> noeuds,
  PlanComptable plan,
  String classeParente,
  List<ResultatRecherche> liste,
) {
  for (final noeud in noeuds) {
    final classe = noeud.niveau == 1 ? noeud.numero : classeParente;
    liste.add(ResultatRecherche(
      numero: noeud.numero,
      intitule: noeud.intitule,
      description: noeud.description,
      classe: classe,
      plan: plan,
    ));
    if (noeud.enfants.isNotEmpty) {
      _aplatirNoeuds(noeud.enfants, plan, classe, liste);
    }
  }
}

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _texte = '';
  String _texteRecherche = ''; // version debounced
  Timer? _debounce;

  final Set<PlanComptable> _plansActifs = {
    PlanComptable.etatBenin,
    PlanComptable.communalBenin,
    PlanComptable.syscohada,
  };

  // Debounce : attend 300ms après la dernière frappe
  void _onTextChange(String val) {
    _debounce?.cancel();
    setState(() => _texte = val); // mise à jour immédiate du champ
    if (val.isEmpty) {
      setState(() => _texteRecherche = '');
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _texteRecherche = val);
    });
  }

  // Filtre les comptes selon le texte et les plans actifs
  List<ResultatRecherche> _filtrer(List<ResultatRecherche> tous) {
    if (_texteRecherche.isEmpty) return [];
    final r = _texteRecherche.toLowerCase();
    return tous.where((c) {
      final matchPlan = _plansActifs.contains(c.plan);
      final matchTexte = c.numero.contains(r) ||
          c.intitule.toLowerCase().contains(r) ||
          c.description.toLowerCase().contains(r);
      return matchPlan && matchTexte;
    }).toList();
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
    final tousAsync = ref.watch(tousLesComptesProvider);

    final couleurFond = AppColors.fond(mode);
    final couleurCarte = AppColors.carte(mode);
    final couleurTexte = AppColors.texte(mode);
    final couleurAppBar = AppColors.appBar(mode);
    final couleurTexteAppBar = AppColors.texteAppBar(mode);
    final couleurChamp = AppColors.champRecherche(mode);
    final estSombre = mode == ModeTheme.sombre;

    return Scaffold(
      backgroundColor: couleurFond,
      bottomNavigationBar: _BarreNavigation(estSombre: estSombre),
      appBar: AppBar(
        backgroundColor: couleurAppBar,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Recherche',
          style: TextStyle(
            color: couleurTexteAppBar,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: tousAsync.when(
        // Chargement initial des données
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF2E7D32)),
              const SizedBox(height: 16),
              Text(
                'Chargement des plans comptables...',
                style: TextStyle(color: couleurTexte.withOpacity(0.5)),
              ),
            ],
          ),
        ),

        // Erreur de chargement
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text('Erreur de chargement',
                  style: TextStyle(color: couleurTexte)),
            ],
          ),
        ),

        // Données chargées
        data: (tousLesComptes) {
          final resultats = _filtrer(tousLesComptes);

          return Column(
            children: [

              // ── Barre de recherche ───────────────────
              Container(
                color: couleurAppBar,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  style: TextStyle(color: couleurTexte),
                  onChanged: _onTextChange,
                  decoration: InputDecoration(
                    hintText: 'Numéro ou intitulé du compte...',
                    hintStyle: TextStyle(
                        color: couleurTexte.withOpacity(0.5)),
                    prefixIcon: Icon(Icons.search,
                        color: couleurTexte.withOpacity(0.7)),
                    suffixIcon: _texte.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear,
                                color: couleurTexte.withOpacity(0.7)),
                            onPressed: () {
                              _debounce?.cancel();
                              _controller.clear();
                              setState(() {
                                _texte = '';
                                _texteRecherche = '';
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

              // ── Filtres par plan ─────────────────────
              Container(
                color: couleurCarte,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    _FiltrePlan(
                      label: 'PCE',
                      couleur: const Color(0xFF2E7D32),
                      actif: _plansActifs.contains(PlanComptable.etatBenin),
                      onTap: () => setState(() {
                        _plansActifs.contains(PlanComptable.etatBenin)
                            ? _plansActifs.remove(PlanComptable.etatBenin)
                            : _plansActifs.add(PlanComptable.etatBenin);
                      }),
                    ),
                    const SizedBox(width: 8),
                    _FiltrePlan(
                      label: 'PCC',
                      couleur: const Color(0xFFF9A825),
                      actif: _plansActifs.contains(PlanComptable.communalBenin),
                      onTap: () => setState(() {
                        _plansActifs.contains(PlanComptable.communalBenin)
                            ? _plansActifs.remove(PlanComptable.communalBenin)
                            : _plansActifs.add(PlanComptable.communalBenin);
                      }),
                    ),
                    const SizedBox(width: 8),
                    _FiltrePlan(
                      label: 'PCS',
                      couleur: const Color(0xFFD32F2F),
                      actif: _plansActifs.contains(PlanComptable.syscohada),
                      onTap: () => setState(() {
                        _plansActifs.contains(PlanComptable.syscohada)
                            ? _plansActifs.remove(PlanComptable.syscohada)
                            : _plansActifs.add(PlanComptable.syscohada);
                      }),
                    ),
                    const Spacer(),
                    Text(
                      _texteRecherche.isEmpty
                          ? '${tousLesComptes.length} comptes'
                          : '${resultats.length} résultat${resultats.length > 1 ? 's' : ''}',
                      style: TextStyle(
                          fontSize: 12,
                          color: couleurTexte.withOpacity(0.5)),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: AppColors.diviseur(mode)),

              // ── Résultats ────────────────────────────
              Expanded(
                child: _texteRecherche.isEmpty
                    ? _EcranVide(couleurTexte: couleurTexte)
                    : resultats.isEmpty
                        ? _AucunResultat(
                            texte: _texteRecherche,
                            couleurTexte: couleurTexte)
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: resultats.length,
                            itemBuilder: (context, index) {
                              final r = resultats[index];
                              final estFavori = favoris.any(
                                (f) => f.numero == r.numero && f.plan == r.plan,
                              );
                              return _CarteResultat(
                                resultat: r,
                                estFavori: estFavori,
                                texteRecherche: _texteRecherche,
                                couleurCarte: couleurCarte,
                                couleurTexte: couleurTexte,
                                onFavori: () {
                                  favorisNotifier.toggle(FavoriItem(
                                    numero: r.numero,
                                    intitule: r.intitule,
                                    description: r.description,
                                    plan: r.plan,
                                  ));
                                },
                                onOuvrirPlan: () {
                                  context.go('${AppRoutes.plan}/${r.plan.name}');
                                },
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Filtre plan ────────────────────────────────────────
class _FiltrePlan extends StatelessWidget {
  final String label;
  final Color couleur;
  final bool actif;
  final VoidCallback onTap;

  const _FiltrePlan({
    required this.label,
    required this.couleur,
    required this.actif,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: actif ? couleur : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: actif ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// ── Carte résultat avec surlignage ─────────────────────
class _CarteResultat extends StatelessWidget {
  final ResultatRecherche resultat;
  final bool estFavori;
  final VoidCallback onFavori;
  final VoidCallback onOuvrirPlan;
  final String texteRecherche;
  final Color couleurCarte;
  final Color couleurTexte;

  const _CarteResultat({
    required this.resultat,
    required this.estFavori,
    required this.onFavori,
    required this.onOuvrirPlan,
    required this.texteRecherche,
    required this.couleurCarte,
    required this.couleurTexte,
  });

  Widget _highlight(String texte, String recherche, Color couleur,
      {double fontSize = 14, FontWeight fontWeight = FontWeight.w600}) {
    if (recherche.isEmpty) {
      return Text(texte,
          style: TextStyle(
              fontWeight: fontWeight,
              fontSize: fontSize,
              color: couleurTexte));
    }
    final lower = texte.toLowerCase();
    final lowerR = recherche.toLowerCase();
    final index = lower.indexOf(lowerR);
    if (index == -1) {
      return Text(texte,
          style: TextStyle(
              fontWeight: fontWeight,
              fontSize: fontSize,
              color: couleurTexte));
    }
    final longueur = lowerR.length;
    return RichText(
      text: TextSpan(
        style: TextStyle(
            fontWeight: fontWeight,
            fontSize: fontSize,
            color: couleurTexte),
        children: [
          TextSpan(text: texte.substring(0, index)),
          TextSpan(
            text: texte.substring(index, index + longueur),
            style: TextStyle(
              backgroundColor: couleur.withOpacity(0.3),
              color: couleur,
              fontWeight: FontWeight.bold,
              fontSize: fontSize + 0.5,
            ),
          ),
          TextSpan(text: texte.substring(index + longueur)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final couleur = Color(resultat.couleur);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: couleurCarte,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge numéro
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: couleur.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _highlight(
                resultat.numero,
                texteRecherche,
                couleur,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            // Contenu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _highlight(
                    resultat.intitule,
                    texteRecherche,
                    couleur,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 4),
                  if (resultat.description.isNotEmpty)
                    _highlight(
                      resultat.description,
                      texteRecherche,
                      couleur,
                      fontSize: 11,
                      fontWeight: FontWeight.normal,
                    ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: onOuvrirPlan,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: couleur.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        resultat.nomPlanComplet,
                        style: TextStyle(
                          fontSize: 10,
                          color: couleur,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Favori
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
          const Icon(Icons.search, size: 64, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 16),
          Text(
            'Recherchez dans les 3 plans',
            style: TextStyle(
              color: couleurTexte.withOpacity(0.5),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'PCE · PCC · PCS',
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
  final String texte;
  final Color couleurTexte;
  const _AucunResultat({required this.texte, required this.couleurTexte});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 16),
          Text(
            'Aucun résultat pour "$texte"',
            style: TextStyle(
              color: couleurTexte.withOpacity(0.5),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez un autre numéro ou intitulé',
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
      currentIndex: 1,
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
