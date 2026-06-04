import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/services/emailjs_service.dart';

class AvisScreen extends ConsumerStatefulWidget {
  const AvisScreen({super.key});

  @override
  ConsumerState<AvisScreen> createState() => _AvisScreenState();
}

class _AvisScreenState extends ConsumerState<AvisScreen> {
  final _nomController     = TextEditingController();
  final _messageController = TextEditingController();
  int _note       = 0;
  bool _envoi     = false;
  bool _envoye    = false;
  String? _erreur;

  @override
  void dispose() {
    _nomController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _envoyer() async {
    // Validation note
    if (_note == 0) {
      setState(() => _erreur = 'Veuillez choisir une note.');
      return;
    }

    // Validation message
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      setState(() => _erreur = 'Veuillez écrire un message.');
      return;
    }
    if (message.length < 10) {
      setState(() => _erreur = 'Message trop court (minimum 10 caractères).');
      return;
    }
    if (message.length > 500) {
      setState(() => _erreur = 'Message trop long (maximum 500 caractères).');
      return;
    }

    setState(() {
      _envoi  = true;
      _erreur = null;
    });

    final succes = await EmailJSService.envoyerAvis(
      nom:     _nomController.text.trim(),
      note:    _note,
      message: message,
    );

    setState(() {
      _envoi  = false;
      _envoye = succes;
      if (!succes) {
        _erreur = 'Erreur d\'envoi. Vérifiez votre connexion.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mode               = ref.watch(themeProvider);
    final couleurFond        = AppColors.fond(mode);
    final couleurCarte       = AppColors.carte(mode);
    final couleurTexte       = AppColors.texte(mode);
    final couleurAppBar      = AppColors.appBar(mode);
    final couleurTexteAppBar = AppColors.texteAppBar(mode);

    return Scaffold(
      backgroundColor: couleurFond,
      appBar: AppBar(
        backgroundColor: couleurAppBar,
        foregroundColor: couleurTexteAppBar,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Donner un avis',
          style: TextStyle(
            color: couleurTexteAppBar,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _envoye
            ? _EcranSucces(couleurTexte: couleurTexte)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Introduction ───────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
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
                        const Text('💬', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 12),
                        Text(
                          'Votre avis compte !',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: couleurTexte,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Aidez-nous à améliorer Comptaria pour tous les comptables du Bénin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.texteSecondaire(mode),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Nom (optionnel) ────────────────
                  Text(
                    'Votre nom (optionnel)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: couleurTexte,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nomController,
                    style: TextStyle(color: couleurTexte, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Ex: Jean Koffi',
                      hintStyle: TextStyle(
                        color: AppColors.texteSecondaire(mode),
                      ),
                      filled: true,
                      fillColor: couleurCarte,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Note ───────────────────────────
                  Text(
                    'Votre note',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: couleurTexte,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final etoile = index + 1;
                      return GestureDetector(
                        onTap: () => setState(() => _note = etoile),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            etoile <= _note
                                ? Icons.star
                                : Icons.star_border,
                            color: const Color(0xFFFDD835),
                            size: 44,
                          ),
                        ),
                      );
                    }),
                  ),
                  if (_note > 0) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        _labelNote(_note),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // ── Message ────────────────────────
                  Text(
                    'Votre message',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: couleurTexte,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _messageController,
                    maxLines: 5,
                    maxLength: 500,
                    style: TextStyle(color: couleurTexte, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Dites-nous ce que vous pensez de Comptaria...',
                      hintStyle: TextStyle(
                        color: AppColors.texteSecondaire(mode),
                      ),
                      filled: true,
                      fillColor: couleurCarte,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),

                  // ── Erreur ─────────────────────────
                  if (_erreur != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _erreur!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // ── Bouton envoyer ─────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _envoi ? null : _envoyer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _envoi
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Envoyer mon avis',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
      ),
    );
  }

  String _labelNote(int note) {
    switch (note) {
      case 1: return 'Très mauvais 😞';
      case 2: return 'Mauvais 😕';
      case 3: return 'Moyen 😐';
      case 4: return 'Bien 😊';
      case 5: return 'Excellent ! 🎉';
      default: return '';
    }
  }
}

// ── Écran succès ───────────────────────────────────────
class _EcranSucces extends StatelessWidget {
  final Color couleurTexte;

  const _EcranSucces({required this.couleurTexte});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 24),
          Text(
            'Merci pour votre avis !',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: couleurTexte,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Votre message a bien été envoyé.\nNous en tiendrons compte pour améliorer Comptaria.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: couleurTexte.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Retour à l\'accueil',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}