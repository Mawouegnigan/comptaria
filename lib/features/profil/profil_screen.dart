import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../core/providers/favoris_provider.dart';
import '../../core/providers/theme_provider.dart';

class ProfilScreen extends ConsumerWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeProvider);
    final favoris = ref.watch(favorisProvider);

    final couleurFond = AppColors.fond(mode);
    final couleurCarte = AppColors.carte(mode);
    final couleurTexte = AppColors.texte(mode);
    final couleurAppBar = AppColors.appBar(mode);
    final couleurTexteAppBar = AppColors.texteAppBar(mode);

    return Scaffold(
      backgroundColor: couleurFond,
      appBar: AppBar(
        backgroundColor: couleurAppBar,
        foregroundColor: couleurTexteAppBar,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Mon Profil',
          style: TextStyle(
            color: couleurTexteAppBar,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // ── Avatar et nom ──────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: couleurCarte,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [

                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF2E7D32).withOpacity(0.1),
                          border: Border.all(
                            color: const Color(0xFF2E7D32).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF2E7D32),
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Nom
                  Text(
                    'Utilisateur Comptaria',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: couleurTexte,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Rôle
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Comptable',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Statistiques ───────────────────────
            Row(
              children: [
                Expanded(
                  child: _CarteStatistique(
                    valeur: '${favoris.length}',
                    label: 'Favoris',
                    icone: Icons.star,
                    couleur: const Color(0xFFFDD835),
                    couleurCarte: couleurCarte,
                    couleurTexte: couleurTexte,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CarteStatistique(
                    valeur: '3',
                    label: 'Plans',
                    icone: Icons.menu_book,
                    couleur: const Color(0xFF2E7D32),
                    couleurCarte: couleurCarte,
                    couleurTexte: couleurTexte,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CarteStatistique(
                    valeur: 'v1.0',
                    label: 'Version',
                    icone: Icons.info_outline,
                    couleur: const Color(0xFF1565C0),
                    couleurCarte: couleurCarte,
                    couleurTexte: couleurTexte,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Paramètres ─────────────────────────
            Container(
              decoration: BoxDecoration(
                color: couleurCarte,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [

                  _TitreSection(
                    titre: 'Compte',
                    couleurTexte: couleurTexte,
                  ),

                  _ItemParametre(
                    icone: Icons.person_outline,
                    titre: 'Modifier le profil',
                    sousTitre: 'Nom, rôle, photo',
                    couleurTexte: couleurTexte,
                    onTap: () {},
                  ),

                  Divider(
                    height: 1,
                    indent: 56,
                    color: AppColors.diviseur(mode),
                  ),

                  _ItemParametre(
                    icone: Icons.notifications_outlined,
                    titre: 'Notifications',
                    sousTitre: 'Mises à jour des plans',
                    couleurTexte: couleurTexte,
                    onTap: () {},
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Signature ──────────────────────────
            Text(
              'Comptaria © 2026 — Bénin',
              style: TextStyle(
                fontSize: 12,
                color: couleurTexte.withOpacity(0.3),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── Carte statistique ──────────────────────────────────
class _CarteStatistique extends StatelessWidget {
  final String valeur;
  final String label;
  final IconData icone;
  final Color couleur;
  final Color couleurCarte;
  final Color couleurTexte;

  const _CarteStatistique({
    required this.valeur,
    required this.label,
    required this.icone,
    required this.couleur,
    required this.couleurCarte,
    required this.couleurTexte,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
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
      child: Column(
        children: [
          Icon(icone, color: couleur, size: 28),
          const SizedBox(height: 8),
          Text(
            valeur,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: couleurTexte,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: couleurTexte.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Titre section ──────────────────────────────────────
class _TitreSection extends StatelessWidget {
  final String titre;
  final Color couleurTexte;

  const _TitreSection({
    required this.titre,
    required this.couleurTexte,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          titre.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: couleurTexte.withOpacity(0.4),
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

// ── Item paramètre ─────────────────────────────────────
class _ItemParametre extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String sousTitre;
  final Color couleurTexte;
  final VoidCallback onTap;

  const _ItemParametre({
    required this.icone,
    required this.titre,
    required this.sousTitre,
    required this.couleurTexte,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icone, color: const Color(0xFF2E7D32), size: 22),
      title: Text(
        titre,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: couleurTexte,
        ),
      ),
      subtitle: Text(
        sousTitre,
        style: TextStyle(
          fontSize: 12,
          color: couleurTexte.withOpacity(0.4),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: couleurTexte.withOpacity(0.3),
      ),
      onTap: onTap,
    );
  }
}