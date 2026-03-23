#!/bin/bash

# Script de Test Automatisé - Jumeau Numérique 🏠🚀

# 1. Lancement des services avec reconstruction du backend
echo "--- Lancement des services Docker ---"
docker compose up -d --build

# 2. Attendre que le backend soit prêt
echo "--- Attente du démarrage de l'API (10s) ---"
sleep 10

# 3. Lancer le simulateur MQTT en arrière-plan
echo "--- Lancement du simulateur MQTT capteurs ---"
source backend/venv/bin/activate
python3 test_mqtt_sim.py &
SIM_PID=$!

echo "--------------------------------------------------------"
echo "✅ Système Opérationnel !"
echo "👉 API Swagger : http://localhost:8000/docs"
echo "👉 InfluxDB    : http://localhost:8086"
echo "--------------------------------------------------------"
echo "Appuyez sur CTRL+C pour TOUT arrêter proprement."

# 4. Fonction d'arrêt propre
trap "echo 'Arrêt en cours...'; kill $SIM_PID; docker compose down; exit" INT

# Garder le script actif pour voir les logs
docker compose logs -f backend
