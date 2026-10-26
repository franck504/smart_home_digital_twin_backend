import datetime
import os
import httpx
from app.core.state import current_state
from app.db.database import save_sensor_data, save_energy_state

# Global weather configuration
WEATHER_CITY = "Fianarantsoa"
OPENWEATHER_API_KEY = os.getenv("OPENWEATHER_API_KEY", "")

def update_weather_city(city: str):
    """Updates the target city for weather calculations."""
    global WEATHER_CITY
    WEATHER_CITY = city
    current_state.weather.location = city

async def get_weather_forecast():
    """
    Retrieves weather data from OpenWeatherMap API if a key is configured,
    or falls back gracefully to deterministic simulated data.
    """
    # Si la clé est absente ou correspond à la valeur par défaut du template .env
    if not OPENWEATHER_API_KEY or OPENWEATHER_API_KEY == "votre_cle_ici":
        return {
            "outside_temp": 24.5,
            "description": "Ciel dégagé (Simulé)",
            "icon": "01d",
            "solar_prediction": 0.8,
            "location": WEATHER_CITY
        }

    url = "https://api.openweathermap.org/data/2.5/weather"
    params = {
        "q": WEATHER_CITY,
        "appid": OPENWEATHER_API_KEY,
        "units": "metric",
        "lang": "fr"
    }

    try:
        async with httpx.AsyncClient(timeout=5.0) as client:
            response = await client.get(url, params=params)
            if response.status_code == 200:
                data = response.json()
                temp = float(data["main"]["temp"])
                desc = data["weather"][0]["description"].capitalize()
                icon = data["weather"][0]["icon"]

                # Estimation de l'ensoleillement selon la nébulosité et le jour/nuit
                is_night = icon.endswith("n")
                if is_night:
                    solar_pred = 0.0
                else:
                    clouds = data.get("clouds", {}).get("all", 0)
                    solar_pred = round(max(0.0, min(1.0, 1.0 - (clouds / 100.0))), 2)

                return {
                    "outside_temp": temp,
                    "description": desc,
                    "icon": icon,
                    "solar_prediction": solar_pred,
                    "location": WEATHER_CITY
                }
            else:
                print(f"[Weather Warning] API returned status {response.status_code}: {response.text}")
    except Exception as e:
        print(f"[Weather Error] Failed to fetch live weather: {e}")

    # Fallback sécurisé en cas de coupure réseau ou erreur API
    return {
        "outside_temp": current_state.weather.outside_temp or 22.0,
        "description": current_state.weather.description or "Indisponible",
        "icon": current_state.weather.icon or "01d",
        "solar_prediction": current_state.weather.solar_prediction or 0.5,
        "location": WEATHER_CITY
    }

def calculate_energy_strategy(state, weather_data):
    """
    Determines the best energy source (Solar vs Grid) based on battery levels 
    and solar production forecasts.
    """
    state.weather.outside_temp = weather_data["outside_temp"]
    state.weather.description = weather_data["description"]
    state.weather.icon = weather_data["icon"]
    state.weather.solar_prediction = weather_data["solar_prediction"]
    state.weather.last_updated = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    if "location" in weather_data:
        state.weather.location = weather_data["location"]

    # Critical battery management
    if state.energy.battery_level < state.config.battery_critical_threshold:
        state.energy.source = "grid"
    elif state.energy.battery_level > 30 and state.weather.solar_prediction > 0.4:
        state.energy.source = "solar"
    
    return state

def process_all_climatisation(state):
    """
    Autonomous HVAC regulation.
    Decides whether to heat, cool or turn off based on room temperature vs target.
    """
    for room_id, room in state.rooms.items():
        if room.climatisation_mode == "MANUAL":
            continue

        # Economy mode: turn off if no presence and auto-off is enabled
        if not room.presence and state.config.auto_clim_off:
            room.climatisation = "OFF"
            continue

        # Hysteresis logic for temperature control
        if room.temperature > room.temperature_de_regulation + 1.0:
            room.climatisation = "COOL"
        elif room.temperature < room.temperature_de_regulation - 1.0:
            room.climatisation = "HEAT"
        else:
            room.climatisation = "OFF"
            
    return state

async def process_state_update():
    """
    Main background task to process sensor changes, update the digital twin logic,
    and persist data to the database.
    """
    from app.core.ws import sync_and_broadcast
    global current_state
    
    # Save current room states to history
    for room_id, room in current_state.rooms.items():
        save_sensor_data(room_id, room.temperature, room.luminosity, room.presence, room.humidity)

    # Process energy and HVAC strategies
    weather_data = await get_weather_forecast()
    current_state = calculate_energy_strategy(current_state, weather_data)
    save_energy_state(current_state.energy.source, current_state.energy.battery_level)
    
    current_state = process_all_climatisation(current_state)
    
    # Broadcast final state to all clients
    await sync_and_broadcast()
