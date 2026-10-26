# Procédure de Test et de Validation - Jumeau Numérique 🏠🚀

Ce guide détaille la procédure standard pour démarrer, simuler et valider le bon fonctionnement de l'infrastructure logicielle (FastAPI, Mosquitto, InfluxDB).

---

## 1. Démarrage Rapide en Une Commande

Le projet fournit un script tout-en-un qui initialise l'environnement, démarre les conteneurs, exécute les tests unitaires et lance le simulateur IoT multi-zones :

```bash
./scripts/run_test.sh
```

---

## 2. Démarrage Manuel Pas-à-Pas

Si vous préférez contrôler chaque composant individuellement :

### Étape 1 : Initialisation de l'environnement
```bash
# Si le fichier .env n'existe pas encore :
cp .env.example .env
```

### Étape 2 : Lancement des conteneurs Docker
```bash
docker compose up -d --build
```
Vérifiez que les 3 conteneurs sont en état "Up" :
```bash
docker compose ps
```
Services attendus :
* `jumeau_backend` (Port `8000`)
* `jumeau_mqtt` (Port `1883`)
* `jumeau_influx` (Port `8086`)

### Étape 3 : Exécution de la suite de tests unitaires
Les tests peuvent être exécutés directement dans le conteneur backend sans installer Python ou pytest sur la machine hôte :
```bash
docker cp backend/tests/test_logic.py jumeau_backend:/app/test_logic.py
docker exec jumeau_backend python3 -m pytest /app/test_logic.py -v
```
*Résultat attendu : **27 passed**.*

### Étape 4 : Lancement du simulateur IoT (4 pièces)
Pour injecter des mesures dynamiques réalistes (température, humidité, présence, luminosité) dans le bus MQTT :
```bash
# Option A : Exécution dans le conteneur Docker (recommandé si paho-mqtt n'est pas installé sur l'hôte)
docker cp scripts/test_mqtt_sim.py jumeau_backend:/app/test_mqtt_sim.py
docker exec -e MQTT_BROKER=jumeau_mqtt jumeau_backend python3 /app/test_mqtt_sim.py

# Option B : Exécution directe sur la machine hôte (si paho-mqtt est installé)
python3 scripts/test_mqtt_sim.py
```

---

## 3. Points de Contrôle & Diagnostic

1. **Vérification de l'API REST :**
   Ouvrez la documentation interactive Swagger sur : [http://localhost:8000/docs](http://localhost:8000/docs).
2. **Consultation des logs du serveur :**
   ```bash
   docker logs -f jumeau_backend
   ```
3. **Vérification de la base InfluxDB :**
   Connectez-vous sur [http://localhost:8086](http://localhost:8086) avec :
   - Utilisateur : `admin`
   - Mot de passe : `adminpassword` (ou celui défini dans votre `.env`)
   - Bucket : `jumeau_bucket`
