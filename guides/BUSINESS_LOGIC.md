# Logique Métier - Jumeau Numérique 🧠💡

Ce document explique comment le backend prend ses décisions automatiques pour gérer le confort et l'énergie.

## 1. Stratégie de Basculement Énergétique
Le backend optimise l'utilisation de l'énergie en fonction de l'ensoleillement et de la batterie.

- **Source Solaire :** Utilisée par défaut tant que la batterie est au-dessus de 30%.
- **Source Réseau (Grid) :** Le backend bascule sur le réseau public si :
  - La batterie descend en dessous du seuil critique (20% par défaut).
  - ET l'ensoleillement prévu (via OpenWeatherMap) est faible (< 30%).
- **Économie d'Énergie :** Si la source est solaire et qu'aucune présence n'est détectée dans une pièce (Salon/Cuisine), le backend éteint automatiquement les lumières pour préserver la batterie.

## 2. Régulation Climatique Proportionnelle
Contrairement à un simple thermostat (On/Off), ce système adapte sa puissance pour un meilleur confort.

### Algorithme de Puissance
Le calcul de l'intensité (0-100%) se fait selon l'écart thermique :
- **Seuil Haut (Froid) :** Si `température > seuil_haut`, alors `intensité = (température - seuil_haut) * 20%`.
  - Exemple : Si seuil = 24.0°C et température = 26.0°C, l'intensité sera de 40%.
- **Seuil Bas (Chaud) :** Si `température < seuil_bas`, alors `intensité = (seuil_bas - température) * 20%`.
- **Note :** La puissance est plafonnée à 100%.

## 3. Priorité de Contrôle (Modes AUTO/MANUAL)
- **Mode AUTO :** Le backend applique ses calculs toutes les 10 secondes.
- **Mode MANUAL :** Dès qu'un utilisateur change la clim via l'application mobile, le backend passe en mode `MANUAL` et arrête d'envoyer ses ordres automatiques pour ne pas écraser le choix de l'utilisateur.

---
> **Paramétrage :** Les seuils de température et de batterie critique sont modifiables via l'API REST (`POST /config/thresholds`).
