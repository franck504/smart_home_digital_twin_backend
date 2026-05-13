# Smart Home Mobile

Application mobile développée avec Flutter pour le contrôle et la surveillance en temps réel du jumeau numérique de la maison intelligente.

## Fonctionnalités
- Visualisation de l'état des capteurs par pièce (température, humidité, présence, luminosité).
- Contrôle des actuateurs (lumières, climatisation).
- Configuration des seuils et des modes de régulation automatique.
- Synchronisation en temps réel via WebSockets avec le backend.

## Installation

### Pré-requis
- Flutter SDK (version compatible avec le `pubspec.yaml`).
- Android Studio / VS Code avec extensions Flutter.

### Démarrage
1. Installer les dépendances :
   ```bash
   flutter pub get
   ```
2. Configurer l'adresse IP du backend dans l'application (via la page de configuration dédiée).
3. Lancer l'application :
   ```bash
   flutter run
   ```

## Architecture
Le projet suit une architecture modulaire pour séparer la logique de présentation (widgets) de la logique de communication (services API/WS).
