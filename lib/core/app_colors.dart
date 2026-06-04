import 'package:flutter/material.dart';
import 'enums/mode_theme.dart'; // ✅ app_colors.dart est dans lib/core/

class AppColors {

  // ── Couleurs fixes ────────────────────────────────────────────
  static const Color vert      = Color(0xFF2E7D32);
  static const Color vertClair = Color(0xFF4CAF50);
  static const Color jaune     = Color(0xFFFDD835);
  static const Color rouge     = Color(0xFFC62828);

  // ── Fond principal ────────────────────────────────────────────
  static Color fond(ModeTheme mode) {
    switch (mode) {
      case ModeTheme.clair:   return const Color(0xFFF4F6F4);
      case ModeTheme.sombre:  return const Color(0xFF121212);
      case ModeTheme.couleur: return const Color(0xFFF4F6F4);
    }
  }

  // ── Fond des cartes ───────────────────────────────────────────
  static Color carte(ModeTheme mode) {
    switch (mode) {
      case ModeTheme.clair:   return Colors.white;
      case ModeTheme.sombre:  return const Color(0xFF1E1E1E);
      case ModeTheme.couleur: return Colors.white;
    }
  }

  // ── Texte principal ───────────────────────────────────────────
  static Color texte(ModeTheme mode) {
    switch (mode) {
      case ModeTheme.clair:   return const Color(0xFF1A2E1A);
      case ModeTheme.sombre:  return Colors.white;
      case ModeTheme.couleur: return const Color(0xFF1A2E1A);
    }
  }

  // ── Texte secondaire (opacité 0.6 minimum) ────────────────────
  static Color texteSecondaire(ModeTheme mode) {
    switch (mode) {
      case ModeTheme.clair:   return const Color(0xFF1A2E1A).withOpacity(0.6);
      case ModeTheme.sombre:  return Colors.white.withOpacity(0.6);
      case ModeTheme.couleur: return const Color(0xFF1A2E1A).withOpacity(0.6);
    }
  }

  // ── Fond AppBar ───────────────────────────────────────────────
  static Color appBar(ModeTheme mode) {
    switch (mode) {
      case ModeTheme.clair:   return Colors.white;
      case ModeTheme.sombre:  return const Color(0xFF1E1E1E);
      case ModeTheme.couleur: return const Color(0xFF2E7D32);
    }
  }

  // ── Texte AppBar ──────────────────────────────────────────────
  static Color texteAppBar(ModeTheme mode) {
    switch (mode) {
      case ModeTheme.clair:   return const Color(0xFF1A2E1A);
      case ModeTheme.sombre:  return Colors.white;
      case ModeTheme.couleur: return Colors.white;
    }
  }

  // ── Fond barre de navigation ──────────────────────────────────
  static Color navBar(ModeTheme mode) {
    switch (mode) {
      case ModeTheme.clair:   return Colors.white;
      case ModeTheme.sombre:  return const Color(0xFF1E1E1E);
      case ModeTheme.couleur: return Colors.white;
    }
  }

  // ── Icône sélectionnée nav bar ────────────────────────────────
  static Color navBarSelected(ModeTheme mode) {
    switch (mode) {
      case ModeTheme.clair:   return const Color(0xFF2E7D32);
      case ModeTheme.sombre:  return const Color(0xFF4CAF50);
      case ModeTheme.couleur: return const Color(0xFF2E7D32);
    }
  }

  // ── Icône non sélectionnée nav bar ────────────────────────────
  static Color navBarNonSelectionne(ModeTheme mode) {
    switch (mode) {
      case ModeTheme.clair:   return const Color(0xFF1A2E1A).withOpacity(0.4);
      case ModeTheme.sombre:  return Colors.white.withOpacity(0.4);
      case ModeTheme.couleur: return const Color(0xFF1A2E1A).withOpacity(0.4);
    }
  }

  // ── Diviseur ──────────────────────────────────────────────────
  static Color diviseur(ModeTheme mode) {
    switch (mode) {
      case ModeTheme.clair:   return const Color(0xFFE0E0E0);
      case ModeTheme.sombre:  return Colors.grey.shade800;
      case ModeTheme.couleur: return const Color(0xFFE0E0E0);
    }
  }

  // ── Fond champ de recherche ───────────────────────────────────
  static Color champRecherche(ModeTheme mode) {
    switch (mode) {
      case ModeTheme.clair:   return const Color(0xFFEEF2EE);
      case ModeTheme.sombre:  return const Color(0xFF2A2A2A);
      case ModeTheme.couleur: return const Color(0xFFEEF2EE);
    }
  }
}