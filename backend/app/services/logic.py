import datetime
from app.core.state import current_state
from app.db.database import save_sensor_data, save_energy_state

# Global weather configuration
WEATHER_CITY = "Fianarantsoa"

def update_weather_city(city: str):
    """Updates the target city for weather calculations."""
    global WEATHER_CITY
    WEATHER_CITY = city

async def get_weather_forecast():
    """
    Retrieves weather data (mocked for now).
    Returns basic temperature and solar yield coefficients.
    """
    return {
        "outside_temp": 24.5,
        "description": "Ciel dégagé",
        "icon": "01d",
        "solar_prediction": 0.8
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
        save_sensor_data(room_id, room.temperature, room.luminosity, room.presence)

    # Process energy and HVAC strategies
    weather_data = await get_weather_forecast()
    current_state = calculate_energy_strategy(current_state, weather_data)
    save_energy_state(current_state.energy.source, current_state.energy.battery_level)
    
    current_state = process_all_climatisation(current_state)
    
    # Broadcast final state to all clients
    await sync_and_broadcast()
