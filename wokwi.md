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






















Viewed wokwi.md:1-39
Viewed main.py:1-263
Viewed .env:1-12

C'est le moment de donner vie à votre "objet physique" virtuel ! Nous allons transformer un **ESP32** dans Wokwi en un nœud IoT intelligent qui communique avec votre backend.

Voici le plan pour configurer votre simulation Wokwi de manière à ce qu'elle interagisse avec le Jumeau Numérique et l'application mobile.

# 📋 Plan d'implémentation Wokwi

## 1. Préparation du matériel (Wokwi Canvas)
Vous devrez ajouter les composants suivants sur votre interface Wokwi :
*   **ESP32** (Le cœur du système)
*   **DHT22** : Pour la température ambiante (broche `15`)
*   **Photo-résistance (LDR)** : Pour la luminosité (broche `34`)
*   **Capteur PIR** : Pour simuler la présence (broche `13`)
*   **LED Jaune** : Pour l'éclairage de la pièce (broche `2`)
*   **LED RGB** : Pour l'état de la clim (R:`4`, G:`16`, B:`17`)

## 2. Développement du Code C++ (Arduino)
Je vais vous fournir un code complet qui :
*   Se connecte au **WiFi simulé** de Wokwi.
*   Se connecte à votre **Broker MQTT** (en utilisant l'IP de votre machine).
*   **Publie** les données des capteurs vers `home/sensors` toutes les 5 secondes.
*   **S'abonne** à `home/actuators` pour allumer la LED (lumière) et changer la couleur de la LED RGB selon l'état de la clim (Froid=Bleu, Chaud=Rouge).

## 3. Configuration Réseau (Lien Browser <-> Local)
> [!IMPORTANT]
> Pour que Wokwi (dans votre navigateur) puisse parler à votre Mosquitto (dans Docker), vous devez utiliser la **passerelle Wokwi** ou l'adresse IP locale de votre machine (ex: `192.168.1.XX`).

### Questions pour finaliser :
1.  **Quelle est l'adresse IP locale** de votre ordinateur (celle que vous avez tapée dans les paramètres de l'application mobile) ? Je l'intégrerai directement dans le code pour vous.
2.  Voulez-vous que je génère le code pour une pièce spécifique (ex: **"salon"**) ou un code générique facile à copier ?

**Une fois ces détails confirmés, je vous fournis le bloc de code complet à copier-coller dans Wokwi !**