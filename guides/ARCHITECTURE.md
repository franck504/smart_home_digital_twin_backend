# Architecture du Backend - Jumeau Numérique 🏗️

Ce document décrit l'organisation technique du "Cerveau" du projet de Jumeau Numérique.

## 1. Vue d'Ensemble
Le backend est une application **FastAPI** (Python 3.11) conçue pour centraliser les données d'une maison intelligente, prendre des décisions automatiques et synchroniser plusieurs interfaces en temps réel.

### Pile Technologique
- **Framework :** FastAPI (Performance et documentation automatique).
- **Communication IoT :** MQTT (Echanges légers avec l'ESP32/Wokwi).
- **Temps Réel :** WebSockets (Streaming de données vers l'application 3D et Mobile).
- **Base de Données :** InfluxDB (Stockage temporel pour l'historique et les graphiques).
- **Orchestration :** Docker Compose (Déploiement simplifié).

## 2. Flux de Données
Le système fonctionne selon une boucle de rétroaction continue :

1.  **Réception (IoT) :** L'ESP32 publie des mesures sur le topic MQTT `home/sensors`.
2.  **Traitement (IA) :** 
    - Le backend enregistre les données dans **InfluxDB**.
    - Il interroge l'API **OpenWeatherMap** pour obtenir l'ensoleillement réel.
    - Il calcule la source d'énergie optimale (Solaire vs Réseau).
    - Il calcule la puissance de climatisation (0-100%) selon les seuils configurés.
3.  **Synchronisation :**
    - L'état mis à jour est envoyé par **WebSockets** aux interfaces graphiques.
    - Les ordres (lumières, clim, source d'énergie) sont publiés sur le topic MQTT `home/actuators`.

## 3. Structure des Fichiers
- `backend/main.py` : Point d'entrée, gestion des serveurs MQTT/WS/API.
- `backend/models.py` : Définition des schémas de données (Pydantic).
- `backend/logic.py` : Algorithmes de décision (Énergie et Climatisation).
- `backend/database.py` : Connecteur InfluxDB.
- `docker-compose.yml` : Orchestration des conteneurs.

## 4. Points Forts de l'Architecture
- ** découplage total :** Les capteurs ne connaissent pas l'interface 3D. Le backend sert de traducteur universel.
- **Réactivité :** L'utilisation de WebSockets évite aux clients de rafraîchir la page toutes les secondes.
- **Intelligence Proportionnelle :** La climatisation ne s'allume pas seulement, elle ajuste sa puissance pour économiser l'énergie.
