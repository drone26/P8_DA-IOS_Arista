# Arista - Suivi de Santé (qualité de sommeil, activité sportive)

Arista est une application iOS native permettant de suivre les activités physiques quotidiennes et de surveiller la qualité du sommeil. Construite avec SwiftUI et Core Data, elle offre une gestion fluide des données de santé avec une esthétique moderne LiquidGlass.

## Fonctionnalités
- **Profil Utilisateur** : Consultation des informations personnelles.
- **Suivi d'Exercices** : Enregistrement et visualisation d'activités sportives (Football, Natation, Running, Marche, Cyclisme et Libre).
- **Historique de Sommeil** : Journal chronologique inversé avec indicateurs de qualité du sommeil.

## Architecture Technique
- **Frameworks** : SwiftUI, CoreData.
- **Design Pattern** : Pattern Repository pour découpler la logique de données des ViewModels.
- **Concurrence** : Optimisé pour Swift 6 avec isolation @MainActor.
- **Tests** : Suite complète de XCTests pour les models et viewmodels couvrant les cas nominaux et d'erreurs.
