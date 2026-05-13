# Jumeau Numérique - Smart Home

Ce dépôt centralise l'écosystème logiciel du projet de Jumeau Numérique pour une maison intelligente. Il orchestre les flux de données entre la simulation physique (Wokwi), la visualisation 3D (React Three Fiber) et l'interface de contrôle mobile (Flutter).

## Structure du Projet

Le projet est organisé en domaines isolés pour faciliter le développement et le déploiement :

- **`backend/`** : API FastAPI gérant la logique métier, la persistance des données (InfluxDB) et l'orchestration MQTT/WebSockets.
- **`smart-home-mobile-main/`** : Application mobile développée avec Flutter.
- **`smart-house-3d-main/`** : Interface de visualisation 3D interactive (React Three Fiber).
- **`wokwi/`** : Code source et schémas de la simulation matérielle (ESP32).
- **`docs/`** : Documentation technique, plans et rédaction du mémoire de fin d'études.
- **`infra/`** : Fichiers de configuration de l'infrastructure (MQTT, Docker).

## Démarrage Rapide

### Pré-requis
- Docker et Docker Compose
- Python 3.11+ (pour le développement local)

### Lancement via Docker

```bash
git clone https://github.com/franck504/smart_home_digital_twin_backend.git
cd smart_home_digital_twin_backend

# Construction et lancement de l'infrastructure
docker-compose up -d --build
```

### Accès aux Services
- **API (Swagger)** : [http://localhost:8000/docs](http://localhost:8000/docs)
- **Base de données (InfluxDB)** : [http://localhost:8086](http://localhost:8086)
- **Flux temps réel** : `ws://localhost:8000/ws`

## Développement Backend

Pour travailler sur le backend sans Docker :

1. Créer un environnement virtuel : `python -m venv venv`
2. Installer les dépendances : `pip install -r backend/requirements.txt`
3. Lancer le serveur : `uvicorn backend.app.main:app --reload`

## Documentation

Des guides détaillés sont disponibles dans le dossier `/guides` pour faciliter l'onboarding sur les différentes parties du système :
- Architecture système
- Référence API (Mobile/3D)
- Intégration IoT (MQTT/Wokwi)

---
*Projet réalisé dans le cadre du Master 2 OCC 2026.*
