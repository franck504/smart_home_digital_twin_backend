# Guide de Test via Terminal (CURL) 💻

Ce fichier regroupe toutes les commandes `curl` pour tester manuellement chaque fonctionnalité de l'API de votre jumeau numérique.

> **Note :** Assurez-vous que le backend est lancé (`./run_test.sh`) avant d'exécuter ces commandes.

## 1. Consulter l'état global
Récupère l'intégralité des données (Capteurs, Actuateurs, Énergie, Config).
```bash
curl -X GET "http://localhost:8000/state" | jq .
```

## 2. Contrôle des Lumières
Allumer ou éteindre les lumières par pièce.
- **Salon ON :**
  ```bash
  curl -X POST "http://localhost:8000/control/light/salon?state=true"
  ```
- **Cuisine OFF :**
  ```bash
  curl -X POST "http://localhost:8000/control/light/cuisine?state=false"
  ```

## 3. Gestion de la Climatisation
- **Passer en mode MANUEL :**
  ```bash
  curl -X POST "http://localhost:8000/control/climatisation/mode?mode=MANUAL"
  ```
- **Forcer le mode CHAUD (HEAT) :**
  ```bash
  curl -X POST "http://localhost:8000/control/climatisation/set?value=HEAT"
  ```
- **Régler la puissance à 75% :**
  ```bash
  curl -X POST "http://localhost:8000/control/climatisation/intensity?intensity=75.0"
  ```
- **Repasser en mode AUTOMATIQUE :**
  ```bash
  curl -X POST "http://localhost:8000/control/climatisation/mode?mode=AUTO"
  ```

## 4. Configuration des Seuils (Intelligence)
Changer les températures limites pour l'automatisme.
```bash
# Seuil haut à 24°C, seuil bas à 20°C
curl -X POST "http://localhost:8000/config/thresholds?high=24.0&low=20.0"
```

## 5. Simulation de Batterie (Test Énergétique)
Simuler une chute de batterie pour tester le basculement sur le réseau public.
```bash
# Simuler 15% de batterie (déclenche le mode 'grid')
curl -X POST "http://localhost:8000/control/energy/battery?level=15.0"
```

## 6. Test des WebSockets (Temps Réel)
Si vous avez `websocat` installé :
```bash
websocat ws://localhost:8000/ws
```
*Vous verrez le JSON défiler en temps réel à chaque modification.*

---
**Astuce :** Ajoutez `| jq .` à la fin des commandes GET pour un affichage coloré (nécessite l'outil `jq`).
