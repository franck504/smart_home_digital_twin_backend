from .models import HouseState, RoomState
import httpx
import os

OPENWEATHER_API_KEY = os.getenv("OPENWEATHER_API_KEY", "")
CITY = os.getenv("CITY", "Paris")

async def get_weather_forecast():
    url = f"http://api.openweathermap.org/data/2.5/weather?q={CITY}&appid={OPENWEATHER_API_KEY}&units=metric&lang=fr"
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(url, timeout=10)
            if response.status_code == 200:
                data = response.json()
                clouds = data.get("clouds", {}).get("all", 50)
                solar_prediction = (100 - clouds) / 100
                return {
                    "outside_temp": data.get("main", {}).get("temp", 20.0),
                    "description": data.get("weather", [{}])[0].get("description", "Inconnu"),
                    "icon": data.get("weather", [{}])[0].get("icon", "01d"),
                    "solar_prediction": solar_prediction
                }
    except Exception as e:
        print(f"Erreur API Météo : {e}")
    return {"outside_temp": 20.0, "description": "Erreur", "icon": "01d", "solar_prediction": 0.5}

def calculate_energy_strategy(state: HouseState, weather_data: dict):
    state.weather.outside_temp = weather_data["outside_temp"]
    state.weather.description = weather_data["description"].capitalize()
    state.weather.icon = weather_data["icon"]
    state.weather.solar_prediction = weather_data["solar_prediction"]
    
    # Basculement GRID/SOLAR (Logique OR)
    solar_low = weather_data["solar_prediction"] < 0.3
    battery_low = state.energy.battery_level < state.config.battery_critical_threshold
    
    if battery_low or solar_low:
        state.energy.source = "grid"
    elif state.energy.battery_level > (state.config.battery_critical_threshold + 10):
        state.energy.source = "solar"
    
    # Règle d'économie : Extinction automatique par pièce
    if state.energy.source == "solar":
        for room in state.rooms.values():
            if not room.presence:
                room.lights = False
                
    return state

def update_room_climatisation(room: RoomState, threshold_high: float, threshold_low: float):
    """
    Régulation indépendante de la climatisation d'une pièce.
    """
    if room.climatisation_mode == "MANUAL":
        return room
        
    temp = room.temperature
    if temp > threshold_high:
        room.climatisation = "COOL"
        diff = temp - threshold_high
        room.climatisation_intensity = min(100.0, diff * 20.0)
    elif temp < threshold_low:
        room.climatisation = "HEAT"
        diff = threshold_low - temp
        room.climatisation_intensity = min(100.0, diff * 20.0)
    else:
        room.climatisation = "OFF"
        room.climatisation_intensity = 0.0
    return room

def process_all_climatisation(state: HouseState):
    """
    Met à jour la climatisation pour TOUTES les pièces de la maison.
    """
    for room_id in state.rooms:
        state.rooms[room_id] = update_room_climatisation(
            state.rooms[room_id], 
            state.config.temp_threshold_high, 
            state.config.temp_threshold_low
        )
    return state
