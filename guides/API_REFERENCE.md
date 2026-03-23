# Référence API - Jumeau Numérique 📱💻

Ce document détaille les points d'entrée (endpoints) permettant d'interagir avec le backend.

## 1. Consultation de l'État
### `GET /state`
Récupère l'intégralité des données en temps réel.
- **Réponse :** Objet JSON contenant `sensors`, `energy`, `controls` et `config`.
- **Exemple :**
  ```json
  {
    "sensors": { "temperature": 24.5, "presence_salon": true },
    "controls": { "climatisation": "COOL", "intensity": 45.0 }
  }
  ```

## 2. Contrôle Interactif
### `POST /control/light/{room}`
Allume ou éteint la lumière.
- **Paramètres :** `room` (string: salon/cuisine), `state` (bool: true/false).

### `POST /control/climatisation/mode`
Bascule le mode de régulation.
- **Paramètres :** `mode` (string: AUTO/MANUAL).

### `POST /control/climatisation/set`
Force un état thermique (Chaleur, Froid ou Off).
- **Paramètres :** `value` (string: OFF/HEAT/COOL).

### `POST /control/climatisation/intensity`
Régle précisément la puissance de la clim.
- **Paramètres :** `intensity` (float: 0.0 à 100.0).

## 3. Configuration de l'IA (Seuils)
### `POST /config/thresholds`
Définit les limites de température pour l'IA.
- **Paramètres :** `high` (float: seuil froid), `low` (float: seuil chaud).

### `POST /control/energy/battery`
Simule un niveau de charge de batterie.
- **Paramètres :** `level` (float: 0.0 à 100.0).

## 4. Flux Temps Réel (WebSockets)
### `WS /ws`
Connectez votre application (3D ou Mobile) à cette URL pour recevoir l'état complet à chaque changement (push).
- **Format :** JSON (Même format que `GET /state`).

---
> **Documentation Interactive :** Toutes ces API sont testables en direct sur [http://localhost:8000/docs](http://localhost:8000/docs) une fois le projet lancé.
