import json
import asyncio
from typing import List, Literal
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, Query
from fastapi.middleware.cors import CORSMiddleware
import paho.mqtt.client as mqtt
import os

from .models import HouseState, RoomState
from .logic import get_weather_forecast, calculate_energy_strategy, process_all_climatisation, update_weather_city
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
MQTT_TOPIC_SENSORS = "franck504/home/sensors"
MQTT_TOPIC_ACTUATORS = "franck504/home/actuators"

mqtt_client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)

def on_connect(client, userdata, flags, rc, properties):
    print(f"Connecté au Broker MQTT avec le code {rc}", flush=True)
    client.subscribe(MQTT_TOPIC_SENSORS)
    client.subscribe(MQTT_TOPIC_ACTUATORS)

def on_message(client, userdata, msg):
    global current_state
    try:
        topic = msg.topic
        payload = json.loads(msg.payload.decode())
        
        if topic == MQTT_TOPIC_SENSORS:
            # Mise à jour des capteurs par pièce
            for room_id, data in payload.items():
                if room_id in current_state.rooms:
                    room = current_state.rooms[room_id]
                    room.temperature = data.get("temperature", room.temperature)
                    room.presence = data.get("presence", room.presence)
                    room.luminosity = data.get("luminosity", room.luminosity)
            
            if main_loop:
                asyncio.run_coroutine_threadsafe(process_state_update(), main_loop)

        elif topic == MQTT_TOPIC_ACTUATORS:
            # 👉 Synchro Bouton Physique : Si Wokwi nous dit que la lumière a changé
            if "rooms" in payload:
                changed = False
                for room_id, data in payload["rooms"].items():
                    if room_id in current_state.rooms:
                        # Si l'état physique est différent de l'état du jumeau
                        if "lights" in data and current_state.rooms[room_id].lights != data["lights"]:
                            current_state.rooms[room_id].lights = data["lights"]
                            changed = True
                
                # S'il y a eu un changement, on informe les applis mobiles (WebSockets)
                # Mais on n'envoie PAS de message MQTT en retour pour éviter la boucle
                if changed and main_loop:
                    asyncio.run_coroutine_threadsafe(sync_and_broadcast(send_mqtt=False), main_loop)
    except Exception as e:
        print(f"Erreur MQTT : {e}")

mqtt_client.on_connect = on_connect
mqtt_client.on_message = on_message

async def sync_and_broadcast(send_mqtt: bool = True):
    message = current_state.model_dump_json()
    for client in list(clients):
        try:
            await client.send_text(message)
        except:
            if client in clients:
                clients.remove(client)
    
    if not send_mqtt:
        return
    
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

@app.post("/control/{room}/presence", tags=["Capteurs (Simulation)"], summary="Forcer l'état de présence (Simulation)")
async def set_presence(room: str, state: bool = Query(...)):
    """
    API de simulation : Simule l'entrée ou la sortie d'une personne dans la salle.
    """
    global current_state
    if room in current_state.rooms:
        current_state.rooms[room].presence = state
        await process_state_update()
        return {"status": "ok", "room": room, "presence": state}
    return {"status": "error", "message": "Room not found"}

@app.post("/control/{room}/temperature", tags=["Capteurs (Simulation)"], summary="Forcer le thermomètre ambiant (Simulation)")
async def set_sensor_temperature(room: str, value: float = Query(...)):
    """
    API de simulation : Simule un changement physique de température dans la pièce.
    Déclenchera instantanément le thermostat si on dépasse la consigne.
    """
    global current_state
    if room in current_state.rooms:
        current_state.rooms[room].temperature = value
        await process_state_update()
        return {"status": "ok", "room": room, "temperature": value}
    return {"status": "error", "message": "Room not found"}

@app.post("/control/{room}/luminosity", tags=["Capteurs (Simulation)"], summary="Forcer le capteur de lumière (Simulation)")
async def set_sensor_luminosity(room: str, value: float = Query(..., ge=0)):
    """
    API de simulation : Simule le niveau de lux ambiant.
    """
    global current_state
    if room in current_state.rooms:
        current_state.rooms[room].luminosity = value
        await process_state_update()
        return {"status": "ok", "room": room, "luminosity": value}
    return {"status": "error", "message": "Room not found"}

@app.post("/control/weather", tags=["Capteurs (Simulation)"], summary="Forcer la météo globale (Simulation)")
async def set_weather(
    temp: float = Query(None, description="Température extérieure"),
    desc: str = Query(None, description="Description (ex: Neige)"),
    icon: str = Query(None, description="Code icône (ex: 13d)"),
    solar: float = Query(None, description="Prédiction solaire (0.0 à 1.0)")
):
    """
    API de simulation : Simule un changement météorologique radical sur le Jumeau.
    """
    global current_state
    if temp is not None: current_state.weather.outside_temp = temp
    if desc is not None: current_state.weather.description = desc
    if icon is not None: current_state.weather.icon = icon
    if solar is not None: current_state.weather.solar_prediction = solar
    
    await process_state_update()
    return {"status": "ok", "weather": current_state.weather.dict()}

@app.post("/config/weather/location", tags=["Configuration"], summary="Changer la ville de la météo")
async def set_weather_location(city: str = Query(..., description="Nom de la ville")):
    """
    Met à jour la ville pour les prévisions météo et rafraîchit les données.
    """
    update_weather_city(city)
    weather_data = await get_weather_forecast()
    global current_state
    current_state = calculate_energy_strategy(current_state, weather_data)
    await process_state_update()
    return {"status": "ok", "location": city, "weather": current_state.weather.dict()}

@app.post("/control/config/auto_light", tags=["Configuration"], summary="Activer/Désactiver l'auto-extinction")
async def set_auto_light_off(state: bool = Query(...)):
    """
    Active ou désactive la règle d'économie d'énergie qui éteint les lumières en cas d'absence.
    """
    current_state.config.auto_light_off = state
    await process_state_update()
    return {"status": "ok", "auto_light_off": state}

@app.post("/control/config/auto_clim", tags=["Configuration"], summary="Activer/Désactiver l'auto-extinction clim")
async def set_auto_clim_off(state: bool = Query(...)):
    """
    Active ou désactive l'extinction automatique de la clim en cas d'absence.
    """
    current_state.config.auto_clim_off = state
    await process_state_update()
    return {"status": "ok", "auto_clim_off": state}

@app.post("/control/config/lux_threshold", tags=["Configuration"], summary="Régler le seuil de luminosité")
async def set_lux_threshold(value: float = Query(..., ge=0, le=1000)):
    """
    Définit le seuil de lux en dessous duquel la lumière s'allume automatiquement (si présence).
    """
    current_state.config.lux_threshold = value
    await process_state_update()
    return {"status": "ok", "lux_threshold": value}

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
