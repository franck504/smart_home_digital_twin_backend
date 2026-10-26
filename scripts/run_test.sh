#!/bin/bash
# ==============================================================================
# Script de Démonstration & Test Automatisé - Jumeau Numérique 🏠🚀
# ==============================================================================

set -e

# Se positionner automatiquement à la racine du projet
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$ROOT_DIR"

echo "========================================================"
echo "   Lancement du Jumeau Numérique (Smart Home Twin)      "
echo "========================================================"

# 1. Vérification du fichier .env
if [ ! -f .env ]; then
    echo "⚠️  Fichier .env absent. Création depuis .env.example..."
    cp .env.example .env
fi

# 2. Démarrage des conteneurs
echo "--- 1. Lancement des conteneurs Docker (Backend, Mosquitto, InfluxDB) ---"
docker compose up -d --build

# 3. Attendre la disponibilité de l'API
echo "--- 2. Attente de la disponibilité de l'API REST (max 30s) ---"
MAX_RETRIES=30
COUNT=0
until curl -s http://localhost:8000/state > /dev/null 2>&1; do
    sleep 1
    COUNT=$((COUNT + 1))
    if [ $COUNT -ge $MAX_RETRIES ]; then
        echo "❌ Erreur : L'API n'a pas répondu dans le délai imparti."
        docker compose logs backend
        exit 1
    fi
done
echo "✅ Backend opérationnel sur http://localhost:8000"

# 4. Exécuter les tests unitaires
echo "--- 3. Exécution de la suite de tests unitaires (pytest) ---"
docker cp backend/tests/test_logic.py jumeau_backend:/app/test_logic.py
docker exec jumeau_backend python3 -m pytest /app/test_logic.py -q

# 5. Démarrage de la simulation MQTT multi-zones
echo "--- 4. Lancement de la simulation MQTT des 4 pièces ---"
docker cp scripts/test_mqtt_sim.py jumeau_backend:/app/test_mqtt_sim.py

# Lancement en arrière-plan dans le conteneur backend
docker exec -d -e MQTT_BROKER=jumeau_mqtt jumeau_backend python3 /app/test_mqtt_sim.py

echo "--------------------------------------------------------"
echo "🎉 Système entièrement opérationnel !"
echo ""
echo "👉 Documentation Swagger : http://localhost:8000/docs"
echo "👉 Flux WebSocket        : ws://localhost:8000/ws"
echo "👉 Base InfluxDB         : http://localhost:8086"
echo "👉 État en temps réel    : curl -s http://localhost:8000/state | jq ."
echo "--------------------------------------------------------"
echo "Affichage des logs backend en direct (CTRL+C pour quitter sans arrêter les conteneurs) :"
docker compose logs -f backend
