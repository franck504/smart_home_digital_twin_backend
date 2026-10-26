# Guide d'Intégration IoT (MQTT) - Jumeau Numérique 📡🔌

Ce document détaille le protocole de communication MQTT permettant de connecter des microcontrôleurs (ESP32 physique, Arduino, ou simulateur Wokwi) au backend du jumeau numérique.

---

## 1. Paramètres de Connexion au Broker

* **Broker :** IP de l'hôte (ou `jumeau_mqtt` en réseau interne Docker)
* **Port :** `1883` (TCP standard, non chiffré pour le prototypage)
* **Protocole :** MQTT v3.1.1 ou v5.0
* **Préfixe des Topics :** `franck504/home/`

---

## 2. Envoi des Mesures (Capteurs $\rightarrow$ Backend)

Le microcontrôleur publie périodiquement (toutes les 2 à 5 secondes) l'état mesuré des pièces de la maison.

### Topic : `franck504/home/sensors`

```json
{
  "salon": {
    "temperature": 23.5,
    "humidity": 45.0,
    "presence": true,
    "luminosity": 500.0
  },
  "cuisine": {
    "temperature": 24.0,
    "humidity": 60.0,
    "presence": false,
    "luminosity": 200.0
  },
  "chambre": {
    "temperature": 20.2,
    "humidity": 50.0,
    "presence": true,
    "luminosity": 120.0
  },
  "douche": {
    "temperature": 26.8,
    "humidity": 82.0,
    "presence": false,
    "luminosity": 40.0
  }
}
```

#### Champs acceptés par pièce :
| Champ | Type | Unité / Format | Description |
|---|---|---|---|
| `temperature` | `float` | °Celsius | Température ambiante de la pièce |
| `humidity` | `float` | % HR | Humidité relative |
| `presence` | `bool` | `true` / `false` | Détection PIR de présence humaine |
| `luminosity` | `float` | Lux | Luminosité ambiante |

---

## 3. Réception des Ordres (Backend $\rightarrow$ Actionneurs)

Le microcontrôleur s'abonne à ce topic pour recevoir en temps réel les décisions prises par le jumeau numérique (relais lumières, commandes de climatisation, basculement de source d'énergie).

### Topic : `franck504/home/actuators`

```json
{
  "energy_source": "solar",
  "rooms": {
    "salon": {
      "lights": true,
      "climatisation": "OFF",
      "temperature_de_regulation": 22.0
    },
    "cuisine": {
      "lights": false,
      "climatisation": "OFF",
      "temperature_de_regulation": 22.0
    },
    "chambre": {
      "lights": false,
      "climatisation": "HEAT",
      "temperature_de_regulation": 22.0
    },
    "douche": {
      "lights": false,
      "climatisation": "COOL",
      "temperature_de_regulation": 22.0
    }
  }
}
```

---

## 4. Rétroaction Matérielle (Bouton Physique $\rightarrow$ Backend)

Si un occupant appuie sur un **interrupteur physique** connecté à l'ESP32 :
1. L'ESP32 publie le nouvel état sur `franck504/home/actuators` :
   ```json
   {
     "rooms": {
       "salon": {
         "lights": true
       }
     }
   }
   ```
2. Le backend intercepte ce changement, met à jour le jumeau numérique et le diffuse instantanément aux applications mobiles via WebSocket **sans renvoyer de message MQTT** (pour éviter les boucles infinies de feedback).
