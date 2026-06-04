import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/router.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/app_colors.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {

  late AnimationController _drapeauController;
  late Animation<double> _ondulation;

  @override
  void initState() {
    super.initState();
    _drapeauController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _ondulation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _drapeauController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _drapeauController.dispose();
    super.dispose();
  }

  void _ouvrirMenu(BuildContext context) {
    final mode = ref.read(themeProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.carte(mode),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _MenuHamburger(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(themeProvider);
    final fondCouleur = AppColors.fond(mode);
    final texteCouleur = AppColors.texte(mode);

    return Scaffold(
      backgroundColor: fondCouleur,
      bottomNavigationBar: _BarreNavigation(mode: mode),
      body: SafeArea(
        child: Column(
          children: [

            // ── Barre supérieure ───────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  // Menu hamburger
                  IconButton(
                    onPressed: () => _ouvrirMenu(context),
                    icon: Icon(Icons.menu, color: texteCouleur, size: 28),
                  ),

                  // Titre
                  Text(
                    'Comptaria',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: texteCouleur,
                      letterSpacing: 1,
                    ),
                  ),

                  // ❌ Icône profil supprimée (redondant avec barre navigation)
                  // Espace vide pour garder le titre centré
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // ── Zone centrale — Drapeau animé ──────────
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _ondulation,
                  builder: (context, child) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Text(
                          'Choisissez un plan comptable',
                          style: TextStyle(
                            fontSize: 14,
                            color: texteCouleur.withOpacity(0.5),
                            letterSpacing: 0.3,
                          ),
                        ),

                        const SizedBox(height: 48),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            // PCE — Vert
                            Transform.translate(
                              offset: Offset(_ondulation.value - 4, 0),
                              child: _CartePlan(
                                sigle: 'PCE',
                                nom: 'Plan Comptable\nde l\'État',
                                couleur: const Color(0xFF2E7D32),
                                onTap: () => context.go(
                                    '${AppRoutes.plan}/etatBenin'),
                              ),
                            ),

                            const SizedBox(width: 16),

                            // PCC — Jaune
                            Transform.translate(
                              offset: Offset(0, _ondulation.value - 4),
                              child: _CartePlan(
                                sigle: 'PCC',
                                nom: 'Plan Comptable\nCommunal',
                                couleur: const Color(0xFFF9A825),
                                onTap: () => context.go(
                                    '${AppRoutes.plan}/communalBenin'),
                              ),
                            ),

                            const SizedBox(width: 16),

                            // PCS — Rouge
                            Transform.translate(
                              offset: Offset(0, -(_ondulation.value - 4)),
                              child: _CartePlan(
                                sigle: 'PCS',
                                nom: 'SYSCOHADA\nRévisé',
                                couleur: const Color(0xFFD32F2F),
                                onTap: () => context.go(
                                    '${AppRoutes.plan}/syscohada'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 48),

                        Text(
                          'Appuyez sur une carte pour consulter',
                          style: TextStyle(
                            fontSize: 12,
                            color: texteCouleur.withOpacity(0.4),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Carte plan comptable ───────────────────────────────
class _CartePlan extends StatelessWidget {
  final String sigle;
  final String nom;
  final Color couleur;
  final VoidCallback onTap;

  const _CartePlan({
    required this.sigle,
    required this.nom,
    required this.couleur,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 140,
        decoration: BoxDecoration(
          color: couleur,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: couleur.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              sigle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                nom,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Menu hamburger ─────────────────────────────────────
class _MenuHamburger extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeProvider);
    final texteCouleur = AppColors.texte(mode);
    final texteSecondaire = AppColors.texteSecondaire(mode);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // Poignée
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),

          // ── Sélecteur de thème ─────────────────────
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'THÈME',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: texteSecondaire,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              _BoutonTheme(
                label: '☀️ Clair',
                actif: mode == ModeTheme.clair,
                onTap: () => ref
                    .read(themeProvider.notifier)
                    .changerTheme(ModeTheme.clair),
              ),
              const SizedBox(width: 8),
              _BoutonTheme(
                label: '🌙 Sombre',
                actif: mode == ModeTheme.sombre,
                onTap: () => ref
                    .read(themeProvider.notifier)
                    .changerTheme(ModeTheme.sombre),
              ),
              const SizedBox(width: 8),
              _BoutonTheme(
                label: '🇧🇯 Couleur',
                actif: mode == ModeTheme.couleur,
                onTap: () => ref
                    .read(themeProvider.notifier)
                    .changerTheme(ModeTheme.couleur),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Divider(color: AppColors.diviseur(mode)),
          const SizedBox(height: 8),

          // ── Actions ────────────────────────────────
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'ACTIONS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: texteSecondaire,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 8),

          _ItemMenu(
            icone: Icons.rate_review_outlined,
            titre: 'Donner un avis',
            sousTitre: 'Partagez votre expérience',
            texteCouleur: texteCouleur,
            texteSecondaire: texteSecondaire,
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.avis);
            },
          ),

          _ItemMenu(
            icone: Icons.share_outlined,
            titre: 'Partager l\'application',
            sousTitre: 'Recommander Comptaria',
            texteCouleur: texteCouleur,
            texteSecondaire: texteSecondaire,
            onTap: () {
              Navigator.pop(context);
              Share.share(
                'Découvrez Comptaria — l\'app des plans comptables béninois !',
              );
            },
          ),

          _ItemMenu(
            icone: Icons.info_outline,
            titre: 'À propos',
            sousTitre: 'Version, crédits, licences',
            texteCouleur: texteCouleur,
            texteSecondaire: texteSecondaire,
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.apropos);
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Bouton thème ───────────────────────────────────────
class _BoutonTheme extends StatelessWidget {
  final String label;
  final bool actif;
  final VoidCallback onTap;

  const _BoutonTheme({
    required this.label,
    required this.actif,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: actif
                ? const Color(0xFF2E7D32)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: actif
                  ? const Color(0xFF2E7D32)
                  : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: actif ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Item menu ──────────────────────────────────────────
class _ItemMenu extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String sousTitre;
  final Color texteCouleur;
  final Color texteSecondaire;
  final VoidCallback onTap;

  const _ItemMenu({
    required this.icone,
    required this.titre,
    required this.sousTitre,
    required this.texteCouleur,
    required this.texteSecondaire,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icone, color: const Color(0xFF2E7D32)),
      title: Text(
        titre,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: texteCouleur,
        ),
      ),
      subtitle: Text(
        sousTitre,
        style: TextStyle(
          fontSize: 12,
          color: texteSecondaire,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

// ── Barre de navigation ────────────────────────────────
class _BarreNavigation extends StatelessWidget {
  final ModeTheme mode;

  const _BarreNavigation({required this.mode});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: AppColors.navBarSelected(mode),
      unselectedItemColor: AppColors.navBarNonSelectionne(mode),
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.navBar(mode),
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