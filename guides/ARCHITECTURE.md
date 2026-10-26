# Architecture Technique - Jumeau Numérique 🏗️

Ce document décrit en détail l'organisation logicielle et l'architecture système du backend orchestrateur du projet de Jumeau Numérique.

---

## 1. Vue d'Ensemble

Le backend est une application **FastAPI** (Python 3.11) conçue pour agir comme le **cerveau centralisé** d'une maison intelligente. Il remplit 4 missions fondamentales :

1. **Ingestion IoT temps réel** : Réception des télémétries environnementales émises par les microcontrôleurs (ESP32 sous Wokwi ou matériel physique) via le protocole MQTT.
2. **Prise de décision & régulation autonome** : Arbitrage des sources d'énergie (Solaire vs Réseau) et régulation thermique multizone par hystérésis.
3. **Persistance chronologique** : Enregistrement continu des métriques dans une base de données temporelle **InfluxDB 2.0** pour l'analyse historique et les graphiques.
4. **Diffusion bidirectionnelle** : Synchronisation temps réel de l'état du jumeau numérique vers les interfaces clientes (Application Mobile Flutter et Visualiseur 3D React Three Fiber) via **WebSockets**.

```
    ┌──────────────────────────┐
    │     Simulation ESP32     │ (Wokwi / Matériel réel)
    └─────────────┬────────────┘
                  │  MQTT (Topics franck504/home/...)
                  ▼
    ┌──────────────────────────┐
    │    Mosquitto Broker      │
    └─────────────┬────────────┘
                  │  TCP:1883
                  ▼
┌────────────────────────────────────────────────────────┐
│               Backend Orchestrateur (FastAPI)          │
│                                                        │
│  ┌──────────────┐   ┌────────────────┐   ┌──────────┐  │
│  │ Core (State) │◄──┤ Services Logic ├──►│ Database │  │
│  └──────┬───────┘   └────────────────┘   └────┬─────┘  │
│         │                                     │        │
│         │ WebSockets (:8000/ws)               │ Influx │
│         │ REST API (:8000/docs)               │ Line   │
└─────────┼─────────────────────────────────────┼────────┘
          │                                     │
          ├─────────────────────┐               ▼
          ▼                     ▼      ┌────────────────┐
┌──────────────────┐  ┌────────────────┐│  InfluxDB 2.0  │
│ Application Mob. │  │ Visualiseur 3D │└────────────────┘
│     (Flutter)    │  │  (Three.js/R3F)│
└──────────────────┘  └────────────────┘
```

---

## 2. Structure des Fichiers du Backend

Le backend suit une organisation modulaire inspirée des principes de Clean Architecture :

```
backend/
├── app/
│   ├── api/
│   │   ├── __init__.py
│   │   └── endpoints.py        # Définition des routes REST (contrôles, sim, météo)
│   ├── core/
│   │   ├── __init__.py
│   │   ├── mqtt.py             # Client Paho-MQTT, souscriptions et handlers thread-safe
│   │   ├── state.py            # Instance singleton HouseState et gestion des clients WS
│   │   └── ws.py               # Diffusion push WebSocket et publication MQTT
│   ├── db/
│   │   ├── __init__.py
│   │   └── database.py         # Connecteur InfluxDB (Point & WriteAPI)
│   ├── models/
│   │   ├── __init__.py         # Re-export unique du contrat de données
│   │   └── house.py            # Modèles Pydantic v2 (HouseState, RoomState, Energy, Weather)
│   ├── services/
│   │   ├── __init__.py
│   │   └── logic.py            # Intelligence métier (Régulation HVAC, stratégie énergie, météo)
│   └── main.py                 # Point d'entrée ASGI, gestion du cycle de vie lifespan
├── tests/
│   ├── __init__.py
│   └── test_logic.py           # Suite complète de tests unitaires (pytest-asyncio)
└── requirements.txt            # Dépendances Python épinglées
```

---

## 3. Flux de Données et Concurrence Thread-Safe

### Le défi de la concurrence :
Le client MQTT de Paho exécute ses écoutes sur un thread système dédié (`loop_start()`), tandis que FastAPI et Uvicorn fonctionnent sur une boucle asynchrone coopérative (`asyncio event loop`).

### La solution mise en œuvre :
Pour prévenir tout conflit d'accès mémoire concurrent (*race condition*), aucun thread secondaire ne modifie directement `current_state` :
1. Le message MQTT reçu sur `on_message` est sérialisé en dictionnaire Python.
2. Le traitement est immédiatement délégué à la boucle principale FastAPI via `asyncio.run_coroutine_threadsafe(apply_sensor_update(...), main_loop)`.
3. Les mutations, les sauvegardes en base et les diffusions WebSockets se produisent alors exclusivement dans la boucle principale.

---

## 4. Points Clés de l'Architecture

* **Découplage strict** : Les microcontrôleurs ignorent tout de l'interface mobile ou 3D. Le backend fait office de passerelle universelle (*BFF - Backend For Frontend*).
* **Réactivité sans polling** : L'utilisation de WebSockets élimine les requêtes répétitives (polling) des applications mobiles.
* **Résilience hors-ligne (Graceful Fallback)** : Si les services externes (API météo, InfluxDB) deviennent inaccessibles, le jumeau bascule en mode dégradé/simulé sans jamais faire planter la boucle d'automatisation.
