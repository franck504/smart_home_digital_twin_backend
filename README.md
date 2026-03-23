# Jumeau Numérique - Smart Home Backend 🏠🤖

Bienvenue dans le dépôt du "Cerveau" de notre Jumeau Numérique. Ce backend centralise les données capteurs, gère l'intelligence énergétique et pilote la maison en temps réel.

## 🚀 Démarrage Rapide (En 2 minutes)

### 1. Pré-requis
Avoir **Docker** et **Docker Compose** installés sur votre machine.

### 2. Clonage et Lancement
```bash
git clone https://github.com/franck504/smart_home_digital_twin_backend.git
cd smart_home_digital_twin_backend

# Lancer le projet
docker compose up -d --build
```

### 💡 Note pour Linux/Parrot OS
Si vous obtenez une erreur de connexion au socket Docker, lancez cette commande avant : `export DOCKER_HOST=unix:///var/run/docker.sock`

### 3. Accès aux interfaces
- **API Interactive (Swagger) :** [http://localhost:8000/docs](http://localhost:8000/docs)
- **Base de données (InfluxDB) :** [http://localhost:8086](http://localhost:8086) (Login: `admin` / Pass: `adminpassword`)
- **Flux Temps Réel :** `ws://localhost:8000/ws`

## 🧪 Tests Unitaires
Pour valider la logique du "Cerveau" sans matériel :
```bash
export PYTHONPATH=$PYTHONPATH:.
pytest backend/tests/test_logic.py
```

## 📖 Documentation détaillée
Tout ce dont vous avez besoin pour comprendre le projet se trouve dans le dossier [**`/guides`**](file:///guides/) :
- [Architecture du système](file:///guides/ARCHITECTURE.md)
- [Guide pour l'équipe Mobile/3D (API)](file:///guides/API_REFERENCE.md)
- [Guide pour l'équipe IoT (MQTT/Wokwi)](file:///guides/IOT_INTEGRATION.md)
- [Procédure de Test complète](file:///guides/TEST_PROCEDURE.md)

## 🛠️ Développement
Si vous souhaitez modifier le code :
1. Créez un environnement virtuel : `python -m venv venv`
2. Installez les dépendances : `pip install -r backend/requirements.txt`

---
*Projet réalisé dans le cadre du M2 OCC 2026.*
