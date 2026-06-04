import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import '../../core/router.dart';
import '../../core/providers/favoris_provider.dart';
import '../../core/providers/theme_provider.dart';

class FavorisScreen extends ConsumerWidget {
  const FavorisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeProvider);
    final favoris = ref.watch(favorisProvider);

    final couleurFond = AppColors.fond(mode);
    final couleurCarte = AppColors.carte(mode);
    final couleurTexte = AppColors.texte(mode);
    final couleurAppBar = AppColors.appBar(mode);
    final couleurTexteAppBar = AppColors.texteAppBar(mode);
    final estSombre = mode == ModeTheme.sombre;

    return Scaffold(
      backgroundColor: couleurFond,
      appBar: AppBar(
        backgroundColor: couleurAppBar,
        foregroundColor: couleurTexteAppBar,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Favoris',
          style: TextStyle(
            color: couleurTexteAppBar,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBar: _BarreNavigation(estSombre: estSombre),
      body: favoris.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_outline,
                      size: 64, color: couleurTexte.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun favori pour l\'instant',
                    style: TextStyle(
                        color: couleurTexte.withOpacity(0.5),
                        fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Marquez des comptes ⭐ dans les plans',
                    style: TextStyle(
                        color: couleurTexte.withOpacity(0.4),
                        fontSize: 13),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoris.length,
              itemBuilder: (context, index) {
                final favori = favoris[index];
                return _CarteFavori(
                  favori: favori,
                  couleurCarte: couleurCarte,
                  couleurTexte: couleurTexte,
                  onSupprimer: () {
                    ref.read(favorisProvider.notifier).toggle(favori);
                  },
                );
              },
            ),
    );
  }
}

// ── Carte favori ───────────────────────────────────────
class _CarteFavori extends StatelessWidget {
  final FavoriItem favori;
  final VoidCallback onSupprimer;
  final Color couleurCarte;
  final Color couleurTexte;

  const _CarteFavori({
    required this.favori,
    required this.onSupprimer,
    required this.couleurCarte,
    required this.couleurTexte,
  });

  @override
  Widget build(BuildContext context) {
    final couleur = Color(favori.couleur);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: couleurCarte,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
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
              child: Text(
                favori.numero,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: couleur,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Contenu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    favori.intitule,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: couleurTexte,
                    ),
                  ),
                  if (favori.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        favori.description,
                        style: TextStyle(
                            fontSize: 11,
                            color: couleurTexte.withOpacity(0.5)),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: couleur.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      favori.nomPlan,
                      style: TextStyle(
                        fontSize: 10,
                        color: couleur,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            GestureDetector(
              onTap: onSupprimer,
              child: const Icon(
                Icons.star,
                color: Color(0xFFFDD835),
                size: 22,
              ),
            ),
          ],
        ),
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
      currentIndex: 3,
      selectedItemColor: const Color(0xFF2E7D32),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      backgroundColor: estSombre
          ? const Color(0xFF1E1E1E)
          : Colors.white,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go(AppRoutes.home);
            break;
          case 1:
            context.go(AppRoutes.search);
            break;
          case 2:
            context.go(AppRoutes.compare);
            break;
          case 3:
            context.go(AppRoutes.favoris);
            break;
          case 4:
            context.go(AppRoutes.profil);
            break;
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