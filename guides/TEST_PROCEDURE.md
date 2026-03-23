# Procédure de Test du Jumeau Numérique 🏠🚀

Ce guide explique comment lancer et tester l'ensemble du backend (FastAPI + MQTT + InfluxDB) sur votre machine.

## 1. Démarrage de l'Infrastructure Docker

Assurez-vous que le service Docker est lancé. Sur Parrot OS/Linux, executez :

```bash
# 1. Démarrer le service Docker
sudo systemctl start docker

# 2. Lancer les conteneurs (Backend, MQTT, InfluxDB)
# Note : Nous forçons le socket Docker pour éviter les conflits avec Podman
export DOCKER_HOST=unix:///var/run/docker.sock
docker compose up -d --build
```

## 2. Vérification des Services

Vérifiez que les 3 conteneurs sont bien "Up" :
```bash
docker ps
```
Vous devriez voir `jumeau_backend`, `jumeau_mqtt` et `jumeau_influx`.

## 3. Simulation de données (ESP32)

Pour tester si le backend réagit bien aux capteurs, lancez le simulateur Python :
```bash
# Dans un nouveau terminal :
cd "/home/franck/Documents/M2 OCC 2026/jumeaux_numeriques"
source backend/venv/bin/activate
python3 test_mqtt_sim.py
```
*Le simulateur enverra des températures et des détections de présence toutes les 5 secondes.*

## 4. Consultation des Logs

Pour voir le "cerveau" du jumeau numérique prendre des décisions en temps réel :
```bash
docker logs -f jumeau_backend
```
*Cherchez les lignes "MQTT : Données reçues" et "Météo réelle récupérée".*

## 5. Test des Commandes (Mobile/3D)

Ouvrez votre navigateur sur :
- **Swagger UI :** [http://localhost:8000/docs](http://localhost:8000/docs)
- **Action :** Allez sur `POST /control/light/salon`, cliquez sur "Try it out", mettez `state=true` et cliquez sur "Execute".
- **Résultat :** Vérifiez dans les logs du backend que l'ordre a été envoyé à l'ESP32.

## 6. Visualisation des Données Historiques

Connectez-vous à l'interface InfluxDB :
- **URL :** [http://localhost:8086](http://localhost:8086)
- **Login :** `admin`
- **Password :** `adminpassword`
- **Bucket :** `jumeau_bucket`

---
*Félicitations, votre environnement de Jumeau Numérique est prêt !*
