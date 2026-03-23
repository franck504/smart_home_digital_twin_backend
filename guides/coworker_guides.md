# Guide d'Intégration Jumeau Numérique (Backend)

Ce document explique comment envoyer et recevoir des données du "Cerveau" (FastAPI).

## 1. Modèle de données global (JSON)
Le backend maintient l'état suivant :
```json
{
  "sensors": {
    "temperature": 22.5,
    "presence_salon": true,
    "presence_cuisine": false,
    "luminosity": 500
  },
  "energy": {
    "source": "solar", // "solar" ou "grid"
    "battery_level": 85,
    "switch_coefficient": 0.75
  },
  "controls": {
    "climatisation_mode": "AUTO", // "AUTO" ou "MANUAL"
    "climatisation": "OFF", // "OFF", "HEAT", "COOL"
    "climatisation_intensity": 0.0, // 0.0 à 100.0
    "lights_salon": "ON",
    "lights_cuisine": "OFF"
  },
  "config": {
    "temp_threshold_high": 26.0,
    "temp_threshold_low": 18.0,
    "battery_critical_threshold": 20.0
  }
}
```

## 2. Pour l'équipe IoT (Wokwi / ESP32)
* **Protocole :** MQTT
* **Broker :** `localhost` (ou IP du PC) port 1883
* **Topics :**
  - Mesures : `home/sensors` (Publier le JSON des capteurs)
  - Commandes : `home/actuators` (Souscrire pour recevoir le JSON suivant) :
    ```json
    {
      "climatisation": "OFF",
      "energy_source": "solar",
      "lights_salon": true,
      "lights_cuisine": false
    }
    ```

## 3. Pour l'équipe 3D (Three.js) et Mobile
* **Protocole :** WebSockets
* **URL :** `ws://localhost:8000/ws`
* **Fonctionnement :** Dès qu'une donnée change, le backend envoie le JSON global à tous les clients connectés.
* **Commandes (Mobile) :** 
  - `POST /control/light/{room}?state=true/false`
  - `POST /control/climatisation/mode?mode=AUTO/MANUAL`
  - `POST /control/climatisation/set?value=OFF/HEAT/COOL` (Bascule en MANUAL auto)
  - `POST /control/climatisation/intensity?intensity=75` (Règle la puissance 0-100%)
  - `POST /config/thresholds?high=26&low=18` (Règle les seuils automatiques)
  - `POST /control/energy/battery?level=15` (Simule un niveau de batterie pour test)
  - Consulter Swagger à `/docs` pour le détail des paramètres.

## 4. Intelligence Métier
Le Backend effectue les calculs suivants :
- Si `prevision_meteo` < seuil ET `batterie` < 20% -> `source = "grid"`.
- Si `presence` == false -> `lights = "OFF"`.
