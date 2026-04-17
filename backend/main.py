import json
import asyncio
from typing import List, Literal
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, Query
from fastapi.middleware.cors import CORSMiddleware
import paho.mqtt.client as mqtt
import os

from .models import HouseState, RoomState
from .logic import get_weather_forecast, calculate_energy_strategy, process_all_climatisation
from .database import save_sensor_data, save_energy_state

app = FastAPI(title="Smart Home Digital Twin Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

current_state = HouseState()
clients: List[WebSocket] = []
main_loop = None

MQTT_BROKER = os.getenv("MQTT_BROKER", "localhost")
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
        
        # Mise à jour des capteurs par pièce
        for room_id, data in payload.items():
            if room_id in current_state.rooms:
                room = current_state.rooms[room_id]
                room.temperature = data.get("temperature", room.temperature)
                room.presence = data.get("presence", room.presence)
                room.luminosity = data.get("luminosity", room.luminosity)
        
        if main_loop:
            asyncio.run_coroutine_threadsafe(process_state_update(), main_loop)
    except Exception as e:
        print(f"Erreur MQTT : {e}")

mqtt_client.on_connect = on_connect
mqtt_client.on_message = on_message

async def sync_and_broadcast():
    message = current_state.model_dump_json()
    for client in clients:
        try:
            await client.send_text(message)
        except:
            clients.remove(client)
    
    # Envoi MQTT (Actuateurs pour chaque pièce)
    commands = {
        "energy_source": current_state.energy.source,
        "rooms": {
            room_id: {
                "lights": room.lights,
                "climatisation": room.climatisation,
                "temperature_de_regulation": room.temperature_de_regulation
            } for room_id, room in current_state.rooms.items()
        }
    }
    mqtt_client.publish(MQTT_TOPIC_ACTUATORS, json.dumps(commands))

async def process_state_update():
    global current_state
    
    for room_id, room in current_state.rooms.items():
        save_sensor_data(room_id, room.temperature, room.luminosity, room.presence)

    weather_data = await get_weather_forecast()
    current_state = calculate_energy_strategy(current_state, weather_data)
    save_energy_state(current_state.energy.source, current_state.energy.battery_level)
    
    # Climatisation décentralisée
    current_state = process_all_climatisation(current_state)
    
    await sync_and_broadcast()

@app.get("/state", tags=["Global"], summary="Récupérer l'état complet du jumeau numérique")
async def get_state():
    """
    Retourne la structure complète HouseState, comprenant les pièces, les configurations, et la matrice énergétique.
    """
    return current_state

@app.post("/control/{room}/light", tags=["Éclairage"], summary="Contrôler la lumière principale d'une pièce")
async def toggle_light(room: str, state: bool = Query(...)):
    """
    Allume (true) ou éteint (false) la lumière dans la pièce spécifiée. Rejette la requête si la pièce est introuvable.
    """
    if room in current_state.rooms:
        current_state.rooms[room].lights = state
        await sync_and_broadcast()
        return {"status": "ok", "room": room, "lights": state}
    return {"status": "error", "message": "Room not found"}

@app.post("/control/{room}/climatisation/mode", tags=["Climatisation"], summary="Définir le mode de régulation (AUTO/MANUAL)")
async def set_clim_mode(room: str, mode: Literal["AUTO", "MANUAL"] = Query(...)):
    """
    Permet de basculer la logique de thermostat d'une pièce spécifique entre automatique et manuel.
    """
    global current_state
    if room in current_state.rooms:
        current_state.rooms[room].climatisation_mode = mode
        if mode == "AUTO":
            current_state = process_all_climatisation(current_state)
        await sync_and_broadcast()
        return {"status": "ok", "room": room, "mode": mode}
    return {"status": "error", "message": "Room not found"}

@app.post("/control/{room}/climatisation/set", tags=["Climatisation"], summary="Forcer l'état de la climatisation (MANUAL mode)")
async def set_climatisation(room: str, value: Literal["OFF", "HEAT", "COOL"] = Query(...)):
    """
    Force l'allumage physique de la clim (Froid, Chaud ou Éteint). 
    Cette action bascule automatiquement la régulation de la pièce en mode 'MANUAL'.
    """
    if room in current_state.rooms:
        r = current_state.rooms[room]
        r.climatisation = value
        r.climatisation_mode = "MANUAL"
        await sync_and_broadcast()
        return {"status": "ok", "room": room, "value": value}
    return {"status": "error", "message": "Room not found"}

@app.post("/control/{room}/climatisation/target_temp", tags=["Climatisation"], summary="Configurer la température cible (Thermostat)")
async def set_target_temp(room: str, temp: float = Query(..., ge=10, le=35)):
    """
    Définit la température de consigne souhaitée pour la pièce spécifiée.
    Cette action replace automatiquement la régulation de la pièce en mode intelligent 'AUTO'.
    """
    global current_state
    if room in current_state.rooms:
        r = current_state.rooms[room]
        r.temperature_de_regulation = temp
        r.climatisation_mode = "AUTO" 
        
        # Forcer l'évaluation immédiate avant de diffuser l'état
        current_state = process_all_climatisation(current_state)
        
        await sync_and_broadcast()
        return {"status": "ok", "room": room, "target_temp": temp}
    return {"status": "error", "message": "Room not found"}

@app.post("/control/energy/battery", tags=["Énergie"], summary="Simuler un changement dans la réserve de batterie")
async def set_battery(level: float = Query(..., ge=0, le=100)):
    """
    API de simulation : Modifie artificiellement l'état de la batterie entre 0% et 100%.
    Déclenche le recalcul de la stratégie énergétique (bascule réseau si critique).
    """
    current_state.energy.battery_level = level
    await process_state_update()
    return {"status": "ok", "battery_level": level}

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    clients.append(websocket)
    await websocket.send_text(current_state.model_dump_json())
    try:
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        clients.remove(websocket)

@app.on_event("startup")
async def startup_event():
    global main_loop
    main_loop = asyncio.get_running_loop()
    try:
        mqtt_client.connect(MQTT_BROKER, MQTT_PORT, 60)
        mqtt_client.loop_start()
    except Exception as e:
        print(f"MQTT Error : {e}")

@app.on_event("shutdown")
def shutdown_event():
    mqtt_client.loop_stop()
    mqtt_client.disconnect()
