import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _lancerAnimations();
  }

  Future<void> _lancerAnimations() async {
    await _logoController.forward();
    await _textController.forward();
    _progressController.forward();
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [

          // ── Zone centrale ──────────────────────────────
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // Logo
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: child,
                        ),
                      );
                    },
                    child: _LogoComptaria(),
                  ),

                  const SizedBox(height: 28),

                  // Texte
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textOpacity.value,
                        child: child,
                      );
                    },
                    child: const Column(
                      children: [
                        Text(
                          'Comptaria',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1B3A2D),
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Vos plans comptables, partout avec vous',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF7A8C85),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Barre de progression en bas ────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: 60),
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return SizedBox(
                      width: 160,
                      child: LinearProgressIndicator(
                        value: _progressController.value,
                        backgroundColor: const Color(0xFFE0E0E0),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF2E7D32),
                        ),
                        borderRadius: BorderRadius.circular(10),
                        minHeight: 3,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFBDBDBD),
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}

// ── Logo Comptaria ─────────────────────────────────────
class _LogoComptaria extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Trois barres colorées stylisées
            _Barre(couleur: const Color(0xFF2E7D32), largeur: 52),
            const SizedBox(height: 6),
            _Barre(couleur: const Color(0xFFFDD835), largeur: 38),
            const SizedBox(height: 6),
            _Barre(couleur: const Color(0xFFD32F2F), largeur: 28),
          ],
        ),
      ),
    );
  }
}

class _Barre extends StatelessWidget {
  final Color couleur;
  final double largeur;

  const _Barre({required this.couleur, required this.largeur});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: largeur,
      height: 7,
      decoration: BoxDecoration(
        color: couleur,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}