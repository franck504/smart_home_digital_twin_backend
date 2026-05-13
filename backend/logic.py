from .models import HouseState, RoomState
import httpx
import os
from datetime import datetime

OPENWEATHER_API_KEY = os.getenv("OPENWEATHER_API_KEY", "")
CITY = os.getenv("CITY", "Fianarantsoa")

def update_weather_city(new_city: str):
    global CITY
    CITY = new_city

async def get_weather_forecast():
    url = f"http://api.openweathermap.org/data/2.5/weather?q={CITY}&appid={OPENWEATHER_API_KEY}&units=metric&lang=fr"
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(url, timeout=10)
            if response.status_code == 200:
                data = response.json()
                clouds = data.get("clouds", {}).get("all", 50)
                solar_prediction = (100 - clouds) / 100
                from datetime import timedelta
                return {
                    "outside_temp": data.get("main", {}).get("temp", 20.0),
                    "description": data.get("weather", [{}])[0].get("description", "Inconnu"),
                    "icon": data.get("weather", [{}])[0].get("icon", "01d"),
                    "solar_prediction": solar_prediction,
                    "location": data.get("name", CITY),
                    "last_updated": (datetime.now() + timedelta(days=1)).strftime("%d %b %Y")
                }
    except Exception as e:
        print(f"Erreur API Météo : {e}")
    from datetime import timedelta
    return {
        "outside_temp": 20.0, 
        "description": "Erreur", 
        "icon": "01d", 
        "solar_prediction": 0.5,
        "location": CITY,
        "last_updated": (datetime.now() + timedelta(days=1)).strftime("%d %b %Y")
    }

def calculate_energy_strategy(state: HouseState, weather_data: dict):
    state.weather.outside_temp = weather_data["outside_temp"]
    state.weather.description = weather_data["description"].capitalize()
    state.weather.icon = weather_data["icon"]
    state.weather.solar_prediction = weather_data["solar_prediction"]
    state.weather.location = weather_data.get("location", state.weather.location)
    state.weather.last_updated = weather_data.get("last_updated", state.weather.last_updated)
    
    # Basculement GRID/SOLAR (Logique OR)
    solar_low = weather_data["solar_prediction"] < 0.3
    battery_low = state.energy.battery_level < state.config.battery_critical_threshold
    
    if battery_low or solar_low:
        state.energy.source = "grid"
    elif state.energy.battery_level > (state.config.battery_critical_threshold + 10):
        state.energy.source = "solar"
    
    # --- AUTOMATISATION DES PIÈCES ---
    for room in state.rooms.values():
        # 1. Règle d'économie : Extinction automatique par pièce (si activé)
        if state.config.auto_light_off and not room.presence:
            room.lights = False
            
        # 2. NOUVEAU : Allumage automatique si présence + obscurité
        elif room.presence and room.luminosity < state.config.lux_threshold:
            room.lights = True
            
        # 3. NOUVEAU : Automatisation Clim
        if state.config.auto_clim_off:
            if not room.presence:
                # Force l'extinction
                room.climatisation = "OFF"
                room.climatisation_mode = "MANUAL"
            elif room.climatisation_mode == "MANUAL" and room.climatisation == "OFF":
                # Si la personne revient, on repasse en AUTO pour laisser le thermostat travailler
                room.climatisation_mode = "AUTO"
        
    return state
                
def update_room_climatisation(room: RoomState):
    """
    Régulation par thermostat avec hystérésis de 0.5°C.
    """
    if room.climatisation_mode == "MANUAL":
        return room
        
    temp = room.temperature
    target = room.temperature_de_regulation
    tolerance = 0.5
    
    if temp > target + tolerance:
        room.climatisation = "COOL"
    elif temp < target - tolerance:
        room.climatisation = "HEAT"
    elif abs(temp - target) < 0.1: # Proximité immédiate
        room.climatisation = "OFF"
    
    # Note: On laisse le mode actuel si on est dans la zone d'ombre de l'hystérésis
    # sauf si on est très proche de la cible.
    
    return room

def process_all_climatisation(state: HouseState):
    """
    Met à jour la climatisation pour TOUTES les pièces de la maison.
    """
    for room_id in state.rooms:
        state.rooms[room_id] = update_room_climatisation(state.rooms[room_id])
    return state
