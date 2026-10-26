# Guide d'Onboarding Collaborateurs 🤝🚀

Bienvenue dans le projet de **Jumeau Numérique Smart Home** ! Ce guide synthétise l'essentiel pour vous permettre d'intégrer rapidement votre composant (Mobile, 3D, ou IoT) avec le backend.

---

## 1. Modèle de Données Partagé (JSON)

Toutes les interfaces (REST, WebSocket, InfluxDB) se conforment à la structure `HouseState` suivante :

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

## 2. Pour les Développeurs Mobile (Flutter) et 3D (React Three Fiber)

### Connexion Temps Réel (WebSockets)
* **URL :** `ws://localhost:8000/ws`
* **Comportement :**
  1. À la connexion, le serveur envoie immédiatement le JSON complet de l'état.
  2. Chaque mise à jour (capteur, basculement d'énergie, commande) est diffusée en direct (*push*).

### Commandes Interactives (REST API)
* `POST /control/{room}/light?state=true|false` : Contrôle des lumières par pièce.
* `POST /control/{room}/climatisation/mode?mode=AUTO|MANUAL` : Mode de régulation thermique.
* `POST /control/{room}/climatisation/set?value=OFF|HEAT|COOL` : Forcer l'état HVAC.
* `POST /control/{room}/climatisation/target_temp?temp=22.5` : Définir la consigne thermostat.
* `POST /config/weather/location?city=NomDeVille` : Changer la localisation météo.

---

## 3. Pour les Développeurs Matériel & Simulation (ESP32 / Wokwi)

* **Protocole :** MQTT (Port `1883`)
* **Topic de Publication (Capteurs) :** `franck504/home/sensors`
* **Topic de Souscription (Actionneurs) :** `franck504/home/actuators`
* Pour plus de détails sur le format des payloads capteurs/actionneurs, consultez [`guides/IOT_INTEGRATION.md`](file:///home/franck/Documents/github_projects/smart_home_digital_twin_backend/guides/IOT_INTEGRATION.md).

---

## 4. Pour les Analystes de Données (InfluxDB & Dashboards)

* **Interface Web :** `http://localhost:8086`
* **Bucket :** `jumeau_bucket`
* **Organisation :** `my-org`
* **Mesures disponibles :**
  * `room_sensors` : Tags = `room`, Champs = `temperature`, `humidity`, `luminosity`, `presence`.
  * `energy_state` : Champs = `source`, `battery_level`.
