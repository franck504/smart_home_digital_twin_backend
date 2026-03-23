import json
import asyncio
from typing import List, Literal
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, Query
from fastapi.middleware.cors import CORSMiddleware
import paho.mqtt.client as mqtt

from .models import HouseState, Sensors
from .logic import get_weather_forecast, calculate_energy_strategy, update_climatisation
from .database import save_sensor_data, save_energy_state

app = FastAPI(title="Smart Home Digital Twin Backend")

# Configuration CORS pour permettre aux clients Three.js et Mobile de se connecter
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# État global de la maison (en mémoire pour ce POC)
current_state = HouseState()
clients: List[WebSocket] = []
main_loop = None

import os

# --- CONFIGURATION MQTT ---
MQTT_BROKER = os.getenv("MQTT_BROKER", "localhost") # "mosquitto" en docker, "localhost" en local
MQTT_PORT = 1883
MQTT_TOPIC_SENSORS = "home/sensors"
MQTT_TOPIC_ACTUATORS = "home/actuators"

mqtt_client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)

def on_connect(client, userdata, flags, rc, properties):
    print(f"Connecté au Broker MQTT avec le code {rc}", flush=True)
    client.subscribe(MQTT_TOPIC_SENSORS)

def on_message(client, userdata, msg):
    global current_state
    try:
        payload = json.loads(msg.payload.decode())
        print(f"MQTT : Données reçues sur {msg.topic}", flush=True)
        
        # Mise à jour des capteurs
        sensors_data = Sensors(**payload)
        current_state.sensors = sensors_data
        
        # Traitement logique (Calculs) - On utilise la boucle principale
        if main_loop:
            asyncio.run_coroutine_threadsafe(process_state_update(), main_loop)
        else:
            print("Erreur : Boucle d'événements non disponible pour MQTT")
            
    except Exception as e:
        print(f"Erreur lors de la réception MQTT : {e}")

mqtt_client.on_connect = on_connect
mqtt_client.on_message = on_message

async def sync_and_broadcast():
    """
    Diffuse l'état actuel à TOUS les clients :
    1. WebSockets (3D / Mobile)
    2. MQTT (ESP32 / Wokwi)
    """
    # 1. Envoi WebSockets
    message = current_state.model_dump_json()
    for client in clients:
        try:
            await client.send_text(message)
        except:
            clients.remove(client)
    
    # 2. Envoi MQTT (Commandes pour les actuateurs)
    commands = {
        "climatisation": current_state.controls.climatisation,
        "climatisation_intensity": current_state.controls.climatisation_intensity,
        "energy_source": current_state.energy.source,
        "lights_salon": current_state.controls.lights_salon,
        "lights_cuisine": current_state.controls.lights_cuisine
    }
    mqtt_client.publish(MQTT_TOPIC_ACTUATORS, json.dumps(commands))

async def process_state_update():
    """
    Lance les calculs (Automatiques), enregistre en base de données et synchronise.
    """
    global current_state
    
    # 1. Enregistrer les données brutes dans InfluxDB
    save_sensor_data(
        current_state.sensors.temperature, 
        current_state.sensors.luminosity, 
        current_state.sensors.presence_salon
    )

    # 2. Récupérer la météo réelle
    solar_pred = await get_weather_forecast()
    
    # 3. Appliquer la stratégie énergétique (Logique Automatique)
    current_state = calculate_energy_strategy(current_state, solar_pred)
    
    # 4. Enregistrer le résultat énergétique
    save_energy_state(current_state.energy.source, current_state.energy.battery_level)
    
    # 5. Contrôler la clim automatique
    current_state = update_climatisation(current_state)
    
    # 6. Synchronisation globale
    await sync_and_broadcast()

# --- WEBHOOKS / API REST ---

@app.get("/state", summary="Récupérer l'état complet", description="Retourne l'intégralité des données de la maison (capteurs, actuateurs, énergie, config).")
async def get_state():
    return current_state

@app.post("/control/light/{room}", summary="Contrôler les lumières", description="Allume ou éteint la lumière dans une pièce spécifique.")
async def toggle_light(room: str, state: bool = Query(..., description="True pour ON, False pour OFF")):
    if room == "salon":
        current_state.controls.lights_salon = state
    elif room == "cuisine":
        current_state.controls.lights_cuisine = state
    
    # Envoi de l'ordre à la 3D ET à l'ESP32
    await sync_and_broadcast()
    return {"status": "ok", "room": room, "state": state}

# --- WEBSOCKETS ---

# Ancienne fonction supprimée au profit de sync_and_broadcast

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    clients.append(websocket)
    # Envoyer l'état actuel à la connexion
    await websocket.send_text(current_state.model_dump_json())
    try:
        while True:
            # On attend un ping ou une commande du client
            data = await websocket.receive_text()
            # On peut imaginer des commandes venant de la 3D ici
    except WebSocketDisconnect:
        clients.remove(websocket)

@app.post("/control/climatisation/mode", summary="Changer le mode de la clim", description="Bascule entre le mode AUTO (géré par le backend) et MANUAL (géré par l'utilisateur).")
async def toggle_clim_mode(mode: Literal["AUTO", "MANUAL"] = Query(..., description="Mode de fonctionnement")):
    current_state.controls.climatisation_mode = mode
    await sync_and_broadcast()
    return {"status": "ok", "mode": mode}

@app.post("/control/climatisation/set", summary="Régler la clim manuellement", description="Force un état spécifique pour la climatisation. Bascule automatiquement en mode MANUAL.")
async def set_climatisation(value: Literal["OFF", "HEAT", "COOL"] = Query(..., description="État souhaité (Chauffage, Froid ou Off)")):
    current_state.controls.climatisation = value
    current_state.controls.climatisation_mode = "MANUAL"
    if value == "OFF":
        current_state.controls.climatisation_intensity = 0.0
    else:
        current_state.controls.climatisation_intensity = 100.0 # Par défaut à fond en manuel
    await sync_and_broadcast()
    return {"status": "ok", "value": value}

@app.post("/control/climatisation/intensity", summary="Régler la puissance de la clim", description="Règle l'intensité de la climatisation entre 0 et 100%. Bascule automatiquement en mode MANUAL.")
async def set_clim_intensity(intensity: float = Query(..., ge=0, le=100, description="Puissance en %")):
    current_state.controls.climatisation_intensity = intensity
    current_state.controls.climatisation_mode = "MANUAL"
    if intensity == 0:
        current_state.controls.climatisation = "OFF"
    await sync_and_broadcast()
    return {"status": "ok", "intensity": intensity}

@app.post("/config/thresholds", summary="Régler les seuils de température", description="Définit les limites de température pour le mode automatique.")
async def update_thresholds(
    high: float = Query(26.0, ge=20, le=40, description="Seuil haut (COOL)"), 
    low: float = Query(18.0, ge=10, le=25, description="Seuil bas (HEAT)")
):
    current_state.config.temp_threshold_high = high
    current_state.config.temp_threshold_low = low
    # Déclencher un cycle de calcul pour appliquer les nouveaux seuils immédiatement
    await process_state_update()
    return {"status": "ok", "thresholds": {"high": high, "low": low}}

@app.post("/control/energy/battery", summary="Simuler le niveau de batterie", description="Force le niveau de batterie pour tester les scénarios de basculement énergétique.")
async def set_battery(level: float = Query(..., ge=0, le=100, description="Niveau de batterie en %")):
    """Permet de simuler un niveau de batterie pour tester le basculement énergétique."""
    current_state.energy.battery_level = level
    # Déclencher un cycle de calcul pour voir l'effet immédiat
    await process_state_update()
    return {"status": "ok", "battery_level": level}

# --- LIFECYCLE ---

@app.on_event("startup")
async def startup_event():
    # Déclencher le client MQTT en arrière-plan
    global main_loop
    main_loop = asyncio.get_running_loop()
    
    print(f"Branchement MQTT sur {MQTT_BROKER}...", flush=True)
    try:
        # On ne précise pas d'ID client pour faciliter la reconnexion
        mqtt_client.connect(MQTT_BROKER, MQTT_PORT, 60)
        mqtt_client.loop_start()
    except Exception as e:
        print(f"Impossible de se connecter au broker MQTT : {e}")

@app.on_event("shutdown")
def shutdown_event():
    mqtt_client.loop_stop()
    mqtt_client.disconnect()
