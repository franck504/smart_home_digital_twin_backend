# Simulation IoT (Wokwi)

Ce dossier contient le code source et les schémas nécessaires pour simuler la couche matérielle (hardware) du jumeau numérique à l'aide de Wokwi.

## Contenu
- **`main.py`** : Script MicroPython pour l'ESP32 gérant la lecture des capteurs et la réception des commandes MQTT.
- **`diagram.json`** : Schéma du circuit électronique (Leds, DHT22, LDR, Boutons).
- **`wokwi.md`** : Guide détaillé de mise en place de la simulation.

## Fonctionnement
La simulation communique avec le broker MQTT (Mosquitto) défini dans le fichier `main.py`. Elle envoie les données environnementales toutes les quelques secondes et réagit instantanément aux changements d'états demandés par le backend ou l'application mobile.

## Liens Utiles
- [Wokwi Simulator](https://wokwi.com)
