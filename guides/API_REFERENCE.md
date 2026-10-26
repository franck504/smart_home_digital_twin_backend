# Référence API - Jumeau Numérique 📱💻

Ce document détaille les points d'entrée (endpoints HTTP REST et WebSockets) permettant d'interagir avec le backend orchestrateur.

Documentation Swagger interactive disponible sur : `http://localhost:8000/docs`.

---

## 1. Consultation de l'État Global

### `GET /state`
Récupère l'intégralité de l'état du jumeau numérique en temps réel.

- **Réponse :** `HouseState`
- **Exemple de réponse :**
  ```json
  {
    "rooms": {
      "salon": {
        "temperature": 22.0,
        "humidity": 50.0,
        "presence": false,
        "luminosity": 300.0,
        "lights": false,
        "climatisation": "OFF",
        "climatisation_mode": "AUTO",
        "temperature_de_regulation": 22.0
      },
      "cuisine": { ... },
      "chambre": { ... },
      "douche": { ... }
    },
    "config": {
      "temp_threshold_high": 26.0,
      "temp_threshold_low": 18.0,
      "battery_critical_threshold": 20.0,
      "auto_light_off": true,
      "auto_clim_off": true,
      "lux_threshold": 200.0
    },
    "energy": {
      "source": "solar",
      "battery_level": 100.0,
      "consumption": 0.0
    },
    "weather": {
      "outside_temp": 24.5,
      "description": "Ciel dégagé",
      "icon": "01d",
      "solar_prediction": 0.8,
      "location": "Fianarantsoa",
      "last_updated": "2026-10-26 10:00:00"
    }
  }
  ```

---

## 2. Contrôle des Actionneurs & Pièces

### `POST /control/{room}/light`
Allume ou éteint la lumière dans la pièce spécifiée.
- **Path Param :** `room` (ex: `salon`, `cuisine`, `chambre`, `douche`)
- **Query Param :** `state` (boolean: `true` / `false`)
- **Retour :** `{"status": "ok", "room": "salon", "lights": true}`

### `POST /control/{room}/climatisation/mode`
Bascule le mode de régulation du thermostat de la pièce.
- **Path Param :** `room`
- **Query Param :** `mode` (`"AUTO"` ou `"MANUAL"`)
- **Retour :** `{"status": "ok", "room": "salon", "mode": "AUTO"}`

### `POST /control/{room}/climatisation/set`
Force manuellement l'état du chauffage/climatisation (bascule automatiquement le mode en `MANUAL`).
- **Path Param :** `room`
- **Query Param :** `value` (`"OFF"`, `"HEAT"`, `"COOL"`)
- **Retour :** `{"status": "ok", "room": "salon", "value": "COOL"}`

### `POST /control/{room}/climatisation/target_temp`
Définit la température de consigne thermostat pour la pièce (bascule automatiquement le mode en `AUTO`).
- **Path Param :** `room`
- **Query Param :** `temp` (float entre `10.0` et `35.0` °C)
- **Retour :** `{"status": "ok", "room": "salon", "target_temp": 21.5}`

---

## 3. Configuration & Énergie

### `POST /control/config/auto_light`
Active ou désactive la règle d'économie d'énergie coupant les lumières en cas d'absence.
- **Query Param :** `state` (boolean: `true` / `false`)
- **Retour :** `{"status": "ok", "auto_light_off": true}`

### `POST /config/weather/location`
Met à jour la ville pour les prévisions météo et déclenche le recalcul de la stratégie énergétique.
- **Query Param :** `city` (string, ex: `Fianarantsoa`, `Antananarivo`)
- **Retour :** `{"status": "ok", "location": "Antananarivo", "weather": {...}}`

---

## 4. Endpoints de Simulation & Tests

Ces endpoints permettent de tester les scénarios réactifs depuis l'application mobile ou des scripts :

### `POST /control/{room}/presence`
Simule la présence humaine dans une pièce.
- **Path Param :** `room`
- **Query Param :** `state` (boolean: `true` / `false`)

### `POST /control/energy/battery`
Simule un niveau de charge de batterie pour tester les basculements Solaire $\leftrightarrow$ Réseau.
- **Query Param :** `level` (float entre `0.0` et `100.0` %)

### `POST /control/weather`
Surcharge manuellement les conditions météo.
- **Query Params optionnels :** `temp` (float), `desc` (string), `icon` (string), `solar` (float entre 0 et 1)

---

## 5. Flux Temps Réel (WebSockets)

### `WS /ws`
Canal bidirectionnel temps réel pour les interfaces (Mobile Flutter et Tableau de bord 3D).

- **Au raccordement :** Le serveur envoie immédiatement l'état complet (`HouseState` en JSON).
- **En continu :** Chaque modification (détection de présence, changement de température, basculement d'énergie, actionneur) est immédiatement diffusée en push à tous les clients connectés.
- **Format du message :** JSON identique à la réponse de `GET /state`.
