from typing import Literal
from fastapi import APIRouter, Query, HTTPException
from app.core.state import current_state
from app.core.ws import sync_and_broadcast
from app.services.logic import process_state_update, update_weather_city, get_weather_forecast, calculate_energy_strategy, process_all_climatisation

router = APIRouter()

@router.get("/state", tags=["Global"], summary="Retrieve full house state")
async def get_state():
    """Returns the complete digital twin data structure."""
    return current_state

@router.post("/control/{room}/light", tags=["Lighting"], summary="Toggle room lights")
async def toggle_light(room: str, state: bool = Query(...)):
    """Turns light on (true) or off (false) for the specified room."""
    if room in current_state.rooms:
        current_state.rooms[room].lights = state
        await sync_and_broadcast()
        return {"status": "ok", "room": room, "lights": state}
    raise HTTPException(status_code=404, detail="Room not found")

@router.post("/control/{room}/climatisation/mode", tags=["HVAC"], summary="Set thermostat mode")
async def set_clim_mode(room: str, mode: Literal["AUTO", "MANUAL"] = Query(...)):
    """Switch between automatic and manual HVAC regulation."""
    global current_state
    if room in current_state.rooms:
        current_state.rooms[room].climatisation_mode = mode
        if mode == "AUTO":
            current_state = process_all_climatisation(current_state)
        await sync_and_broadcast()
        return {"status": "ok", "room": room, "mode": mode}
    raise HTTPException(status_code=404, detail="Room not found")

@router.post("/control/{room}/climatisation/set", tags=["HVAC"], summary="Force HVAC state")
async def set_climatisation(room: str, value: Literal["OFF", "HEAT", "COOL"] = Query(...)):
    """Manually force HVAC power state. Switches mode to MANUAL automatically."""
    if room in current_state.rooms:
        r = current_state.rooms[room]
        r.climatisation = value
        r.climatisation_mode = "MANUAL"
        await sync_and_broadcast()
        return {"status": "ok", "room": room, "value": value}
    raise HTTPException(status_code=404, detail="Room not found")

@router.post("/control/{room}/climatisation/target_temp", tags=["HVAC"], summary="Set target temperature")
async def set_target_temp(room: str, temp: float = Query(..., ge=10, le=35)):
    """Set thermostat setpoint. Switches mode to AUTO automatically."""
    global current_state
    if room in current_state.rooms:
        r = current_state.rooms[room]
        r.temperature_de_regulation = temp
        r.climatisation_mode = "AUTO" 
        current_state = process_all_climatisation(current_state)
        await sync_and_broadcast()
        return {"status": "ok", "room": room, "target_temp": temp}
    raise HTTPException(status_code=404, detail="Room not found")

@router.post("/control/energy/battery", tags=["Simulation"], summary="Force battery level")
async def set_battery(level: float = Query(..., ge=0, le=100)):
    """Simulation API: Artificially change battery charge level."""
    current_state.energy.battery_level = level
    await process_state_update()
    return {"status": "ok", "battery_level": level}

@router.post("/control/{room}/presence", tags=["Simulation"], summary="Force presence detection")
async def set_presence(room: str, state: bool = Query(...)):
    """Simulation API: Mimic human detection in a room."""
    if room in current_state.rooms:
        current_state.rooms[room].presence = state
        await process_state_update()
        return {"status": "ok", "room": room, "presence": state}
    raise HTTPException(status_code=404, detail="Room not found")

@router.post("/control/weather", tags=["Simulation"], summary="Force global weather")
async def set_weather(
    temp: float = Query(None),
    desc: str = Query(None),
    icon: str = Query(None),
    solar: float = Query(None)
):
    """Simulation API: Manually override weather conditions."""
    if temp is not None: current_state.weather.outside_temp = temp
    if desc is not None: current_state.weather.description = desc
    if icon is not None: current_state.weather.icon = icon
    if solar is not None: current_state.weather.solar_prediction = solar
    
    await process_state_update()
    return {"status": "ok", "weather": current_state.weather.model_dump()}

@router.post("/config/weather/location", tags=["Configuration"], summary="Change weather city")
async def set_weather_location(city: str = Query(...)):
    """Updates the location used for external weather data."""
    global current_state
    update_weather_city(city)
    weather_data = await get_weather_forecast()
    current_state = calculate_energy_strategy(current_state, weather_data)
    await process_state_update()
    return {"status": "ok", "location": city, "weather": current_state.weather.model_dump()}

@router.post("/control/config/auto_light", tags=["Configuration"], summary="Toggle auto-light-off")
async def set_auto_light_off(state: bool = Query(...)):
    """Enable/Disable power saving rule that turns off lights when empty."""
    current_state.config.auto_light_off = state
    await process_state_update()
    return {"status": "ok", "auto_light_off": state}
