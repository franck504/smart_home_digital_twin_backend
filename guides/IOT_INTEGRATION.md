# Guide d'Intégration IoT (MQTT) - Jumeau Numérique 📡🔌

Ce document explique comment connecter un matériel (ESP32, Arduino, Wokwi) au backend du jumeau numérique via le protocole MQTT.

## 1. Paramètres de Connexion
- **Broker MQTT :** L'adresse IP de votre PC (ou `jumeau_mqtt` dans Docker).
- **Port :** `1883` (Standard MQTT).
- **Protocole :** MQTT v3.11 ou v5.

## 2. Envoi des Mesures (Capteurs)
L'appareil doit publier ses données en JSON toutes les 2 à 10 secondes sur le topic suivant :
### Topic : `home/sensors`
- **Format JSON :**
  ```json
  {
    "temperature": 24.5,
    "presence_salon": true,
    "presence_cuisine": false,
    "luminosity": 650.0
  }
  ```
- **Règles :**
  - La température est en °Celsius.
  - La luminosité est en Lux.
  - La présence est un boolean (`true`/`false`).

## 3. Réception des Ordres (Actuateurs)
L'appareil doit s'abonner (subscribe) au topic suivant pour recevoir les commandes du "Cerveau" :
### Topic : `home/actuators`
- **Format JSON :**
  ```json
  {
    "climatisation": "COOL",
    "climatisation_intensity": 45.0,
    "energy_source": "solar",
    "lights_salon": true,
    "lights_cuisine": false
  }
  ```
- **Actions à effectuer :**
  - **climatisation :** `OFF`, `HEAT` ou `COOL`.
  - **climatisation_intensity :** Réglez la vitesse du ventilateur ou le variateur (0 à 100%).
  - **energy_source :** `solar` (Batterie) ou `grid` (Secteur).
  - **lights :** `true` (Relais ON) ou `false` (Relais OFF).

---
> **Conseil :** Si vous utilisez Wokwi, assurez-vous que votre PC a un broker MQTT accessible sur le réseau (Mosquitto).
