
# Comptaria — Référentiel comptable du Bénin

Comptaria est une application web développée en Flutter/Dart pour centraliser et simplifier l'accès aux trois principaux plans comptables du Bénin : le **Plan Comptable de l'État (PCE)**, le **Plan Comptable Communal (PCC)** et le **SYSCOHADA**. L'objectif est de rendre ces référentiels accessibles, consultables et comparables depuis une interface claire et intuitive.

---

## Le contexte

Les professionnels de la comptabilité publique et privée au Bénin jonglent quotidiennement entre trois référentiels distincts. Comptaria réunit tout en un seul endroit — sans connexion requise, sans compte, directement accessible depuis le navigateur.

---

## Ce que fait l'application

**Consultation des plans comptables**, chaque plan est structuré par classes, sous-classes et comptes. La navigation est fluide et hiérarchique, du général au détail.

**Recherche avancée**, l'utilisateur peut rechercher un compte par son numéro ou son intitulé dans les trois référentiels simultanément. Les résultats s'affichent instantanément.

**Comparaison entre référentiels**, en tapant un numéro de compte dans l'espace dédié, les trois intitulés correspondants s'affichent côte à côte — idéal pour identifier les différences entre les plans.

**Favoris**, chaque compte peut être mis en favori pour un accès rapide lors des prochaines consultations.

**Notifications**, les comptes nouvellement ajoutés sont signalés via le système de notifications de l'application.

---

## Architecture du projet

```
comptaria/
├── lib/
│   ├── main.dart               # Point d'entrée
│   ├── screens/                # Pages de l'application
│   │   ├── home.dart
│   │   ├── search.dart
│   │   ├── compare.dart
│   │   └── favorites.dart
│   ├── widgets/                # Composants réutilisables
│   ├── models/                 # Modèles de données
│   └── data/                   # Fichiers JSON des plans comptables
│       ├── pce.json
│       ├── pcc.json
│       └── syscohada.json
├── web/                        # Build web Flutter
├── pubspec.yaml                # Dépendances
└── README.md
```

---

## Les choix techniques

J'ai opté pour **Flutter/Dart** pour cibler le web dans un premier temps, avec une extension mobile prévue. Les données des trois plans comptables sont stockées en **JSON local** — ce qui garantit un accès instantané sans dépendance à un serveur distant. La gestion d'état repose sur **setState**, suffisant pour une application de consultation statique.

L'absence d'authentification est volontaire à ce stade : l'accès est libre, l'objectif étant de maximiser l'accessibilité de l'outil.

---

## Fonctionnalités à venir

- Authentification et profil utilisateur
- Version mobile (Android & iOS)
- Synchronisation des favoris entre appareils
- Mise à jour dynamique des plans comptables

---

## Accès

- 🌐 Application : [comptaria-benin.app](https://comptaria-benin.app)
- 💻 Code source : https://github.com/Mawouegnigan/comptaria

