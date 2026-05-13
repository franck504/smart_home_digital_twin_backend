# Smart House 3D

Smart House 3D est une interface de visualisation interactive permettant de superviser le jumeau numérique en trois dimensions. Ce projet utilise React et Three.js (via React Three Fiber) pour un rendu fluide et une intégration native avec le web.

## Prérequis
- Node.js (version 18 ou supérieure)
- npm ou yarn

## Installation et démarrage

1. Installer les dépendances :
   ```bash
   npm install
   ```

2. Démarrez le serveur de développement :
   ```bash
   npm run dev
   ```

3. Ouvrez votre navigateur à l'adresse [http://localhost:5173](http://localhost:5173).

## Fonctionnalités
- Visualisation 3D temps réel de la structure de la maison.
- Retours visuels sur l'état des capteurs (ex: brouillard si climatisation active, changements de couleurs pour les lumières).
- Synchronisation bidirectionnelle avec le backend via WebSockets.

## Technologies utilisées
- **React** : Framework UI principal.
- **Three.js / React Three Fiber** : Moteur de rendu 3D.
- **Vite** : Outil de build rapide.

---
*Projet réalisé pour le jumeau numérique 2026.*