# Guide de Déploiement - Jumeau Numérique 🐳🚀

Ce document explique comment mettre en production votre backend de jumeau numérique sur n'importe quel ordinateur disposant de Docker.

## 1. Pré-requis
- **Docker Desktop** (ou Docker Engine) installé.
- **Docker Compose** (V2 recommandé).
- **Python 3.11+** (Optionnel, uniquement pour les tests de simulation).

## 2. Installation Rapide
Clonez le dépôt et lancez la commande suivante à la racine du projet :
```bash
# Forcer le socket Docker (Parrot OS / Linux)
export DOCKER_HOST=unix:///var/run/docker.sock

# Lancer tous les services
docker compose up -d --build
```

### Services déployés :
- **Backend (Port 8000) :** L'intelligence et l'API.
- **MQTT (Port 1883) :** Le broker de communication IoT Mosquitto.
- **InfluxDB (Port 8086) :** La base de données temporelle.

## 3. Configuration (Variables d'Environnement)
Toutes les variables sont centralisées dans le fichier `.env` (créé à partir de `.env.example`) :
- `MQTT_BROKER` : `mosquitto` (Lien interne réseau Docker).
- `INFLUXDB_URL` : `http://influxdb:8086`.
- `INFLUXDB_TOKEN` : Jeton d'authentification pour la base InfluxDB.
- `INFLUXDB_ORG` : Organisation InfluxDB (`my-org`).
- `INFLUXDB_BUCKET` : Bucket de stockage (`jumeau_bucket`).
- `OPENWEATHER_API_KEY` : Clé API personnelle OpenWeatherMap (optionnelle, mode simulé automatique si absente).

## 4. Maintenance et Diagnostics
- **Voir les logs du cerveau :**
  ```bash
  docker logs -f jumeau_backend
  ```
- **Redémarrer un service :**
  ```bash
  docker compose restart backend
  ```
- **Arrêter le projet :**
  ```bash
  docker compose down
  ```

---
> **Persistance :** Les données d'InfluxDB sont sauvegardées dans un volume nommé `influx_data` afin qu'elles ne soient pas perdues lors d'un redémarrage.
