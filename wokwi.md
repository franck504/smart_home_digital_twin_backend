# Plan d'Architecture Wokwi - Jumeau Numérique (Nœud IoT)

Ce document décrit la configuration matérielle virtuelle recommandée pour simuler une pièce de la maison intelligente (ex: Salon, Cuisine) à l'aide du simulateur [Wokwi](https://wokwi.com/).

## 🧠 1. Le Microcontrôleur (Le Cerveau)
- **Carte :** `ESP32`
- **Rôle :** Se connecter au `Wokwi-GUEST` (réseau local simulé), traiter la logique C++/Arduino, et assurer la communication MQTT avec le broker local (`192.168.1.48:1883`).
- **Bibliothèques nécessaires :** `WiFi.h`, `PubSubClient.h`, `DHTSensor`, `ArduinoJson.h`.

## 📡 2. Les Capteurs (Inputs -> Publiés via MQTT)
Ces capteurs lisent l'environnement physique et envoient les données au serveur.

1. **Température & Humidité :** 
   - **Composant :** `DHT22`
   - **Rôle :** Simule la température ambiante (`temperature`). Modifiable via curseur dans Wokwi pendant l'exécution.
2. **Présence Sensorielle :** 
   - **Composant :** `PIR Motion Sensor`
   - **Rôle :** Détecte la présence humaine (`presence`). Dans Wokwi, au clic, il envoie un état HAUT (1).
3. **Luminosité :** 
   - **Composant :** `LDR (Photoresistor)` + Résistance 10kΩ
   - **Rôle :** Simule la clarté de la pièce (`luminosity`). Doit être lu via une entrée analogique (`analogRead`).

## ⚙️ 3. Les Actionneurs (Outputs <- Écoutent le MQTT)
Ces composants réagissent physiquement selon les ordres reçus du Backend.

1. **Lumière de Salle :**
   - **Composant :** `LED Standard` (Blanche ou Jaune) + Résistance 220Ω
   - **Rôle :** S'allume ou s'éteint en fonction de la variable `lights` décidée par le Jumeau numérique.
2. **Statut de Climatisation (Thermostat Actif) :**
   - **Composant :** `LED RGB` (4 broches)
   - **Rôle :** Indique l'état actuel de la régulation thermique (`climatisation`).
     - **Bleu :** Mode `COOL`
     - **Rouge :** Mode `HEAT`
     - **Éteint :** Mode `OFF`

## 🔋 4. (Optionnel) Simulation Énergétique de la Maison
Bien que l'énergie soit au niveau global de la maison, un espace Wokwi peut héberger des potentiomètres pour surcharger le système :
- **Potentiomètre Linéaire (Slide Pot) :** Permettant d'imposer un certain niveau de batterie (0% à 100%) afin de forcer le test du basculement automatique `Grid` / `Solar`.
