import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _pageCourante = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      couleur: const Color(0xFF2E7D32),
      icone: Icons.account_balance,
      titre: 'Trois plans en un',
      description:
          'Accédez au Plan Comptable de l\'État Béninois, au Plan Communal et au SYSCOHADA Révisé depuis une seule application.',
      sigle: 'PCE · PCC · PCS',
    ),
    _OnboardingData(
      couleur: const Color(0xFFF9A825),
      icone: Icons.search,
      titre: 'Recherche instantanée',
      description:
          'Trouvez n\'importe quel compte par son numéro ou son intitulé en quelques secondes, même sans connexion internet.',
      sigle: 'Recherche hors-ligne',
    ),
    _OnboardingData(
      couleur: const Color(0xFFD32F2F),
      icone: Icons.compare_arrows,
      titre: 'Comparez facilement',
      description:
          'Visualisez les différences entre les 3 plans comptables côte à côte et enregistrez vos comptes favoris.',
      sigle: 'Comparatif & Favoris',
    ),
  ];

  void _pageSuivante() {
    if (_pageCourante < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _passer() {
    context.go(AppRoutes.home);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [

            // ── Bouton Passer ──────────────────────────
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _passer,
                  child: const Text(
                    'Passer',
                    style: TextStyle(
                      color: Color(0xFF9E9E9E),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),

            // ── Pages ─────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _pageCourante = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _OnboardingPage(data: page);
                },
              ),
            ),

            // ── Indicateurs + Bouton ───────────────────
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [

                  // Points indicateurs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      final actif = index == _pageCourante;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: actif ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: actif
                              ? _pages[_pageCourante].couleur
                              : const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 32),

                  // Bouton suivant / commencer
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _pageSuivante,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_pageCourante].couleur,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _pageCourante < _pages.length - 1
                            ? 'Suivant'
                            : 'Commencer',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Données d'une page ─────────────────────────────────
class _OnboardingData {
  final Color couleur;
  final IconData icone;
  final String titre;
  final String description;
  final String sigle;

  _OnboardingData({
    required this.couleur,
    required this.icone,
    required this.titre,
    required this.description,
    required this.sigle,
  });
}

// ── Widget d'une page ──────────────────────────────────
class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          // Icône dans un cercle coloré
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: data.couleur.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              data.icone,
              size: 64,
              color: data.couleur,
            ),
          ),

          const SizedBox(height: 16),

          // Sigle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: data.couleur.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              data.sigle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: data.couleur,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Titre
          Text(
            data.titre,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B3A2D),
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF7A8C85),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}