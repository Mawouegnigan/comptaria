import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../enums/mode_theme.dart';  // ✅ providers/ → remonte à core/ → enums/
import '../app_colors.dart';        // ✅ providers/ → remonte à core/

export '../enums/mode_theme.dart';  // ✅ les autres fichiers importent theme_provider et obtiennent ModeTheme automatiquement

class ThemeNotifier extends Notifier<ModeTheme> {
  @override
  ModeTheme build() => ModeTheme.couleur;

  void changerTheme(ModeTheme mode) => state = mode;
}

final themeProvider = NotifierProvider<ThemeNotifier, ModeTheme>(
  ThemeNotifier.new,
);

// ── Thème Clair ────────────────────────────────────────────────
final themeClair = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.vert,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: AppColors.fond(ModeTheme.clair),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.appBar(ModeTheme.clair),
    foregroundColor: AppColors.texteAppBar(ModeTheme.clair),
    elevation: 0,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.navBar(ModeTheme.clair),
    selectedItemColor: AppColors.navBarSelected(ModeTheme.clair),
    unselectedItemColor: AppColors.navBarNonSelectionne(ModeTheme.clair),
  ),
  cardColor: AppColors.carte(ModeTheme.clair),
  dividerColor: AppColors.diviseur(ModeTheme.clair),
  textTheme: const TextTheme(
    bodyLarge:   TextStyle(fontSize: 16, color: Color(0xFF1A2E1A)),
    bodyMedium:  TextStyle(fontSize: 14, color: Color(0xFF1A2E1A)),
    bodySmall:   TextStyle(fontSize: 13, color: Color(0xFF1A2E1A)),
    titleLarge:  TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  ),
);

// ── Thème Sombre ───────────────────────────────────────────────
final themeSombre = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.vert,
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: AppColors.fond(ModeTheme.sombre),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.appBar(ModeTheme.sombre),
    foregroundColor: AppColors.texteAppBar(ModeTheme.sombre),
    elevation: 0,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.navBar(ModeTheme.sombre),
    selectedItemColor: AppColors.navBarSelected(ModeTheme.sombre),
    unselectedItemColor: AppColors.navBarNonSelectionne(ModeTheme.sombre),
  ),
  cardColor: AppColors.carte(ModeTheme.sombre),
  dividerColor: AppColors.diviseur(ModeTheme.sombre),
  textTheme: const TextTheme(
    bodyLarge:   TextStyle(fontSize: 16, color: Colors.white),
    bodyMedium:  TextStyle(fontSize: 14, color: Colors.white),
    bodySmall:   TextStyle(fontSize: 13, color: Colors.white),
    titleLarge:  TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  ),
);

// ── Thème Couleur (drapeau béninois) ───────────────────────────
final themeCouleur = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.vert,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: AppColors.fond(ModeTheme.couleur),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.appBar(ModeTheme.couleur),
    foregroundColor: AppColors.texteAppBar(ModeTheme.couleur),
    elevation: 0,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.navBar(ModeTheme.couleur),
    selectedItemColor: AppColors.navBarSelected(ModeTheme.couleur),
    unselectedItemColor: AppColors.navBarNonSelectionne(ModeTheme.couleur),
  ),
  cardColor: AppColors.carte(ModeTheme.couleur),
  dividerColor: AppColors.diviseur(ModeTheme.couleur),
  textTheme: const TextTheme(
    bodyLarge:   TextStyle(fontSize: 16, color: Color(0xFF1A2E1A)),
    bodyMedium:  TextStyle(fontSize: 14, color: Color(0xFF1A2E1A)),
    bodySmall:   TextStyle(fontSize: 13, color: Color(0xFF1A2E1A)),
    titleLarge:  TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  ),
);

// ── Fonction utilitaire ────────────────────────────────────────
ThemeData obtenirTheme(ModeTheme mode) {
  switch (mode) {
    case ModeTheme.clair:   return themeClair;
    case ModeTheme.sombre:  return themeSombre;
    case ModeTheme.couleur: return themeCouleur;
  }
}