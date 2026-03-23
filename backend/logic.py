from .models import HouseState
import random

import httpx
import os

# La clé API est récupérée via les variables d'environnement pour plus de sécurité sur Git
OPENWEATHER_API_KEY = os.getenv("OPENWEATHER_API_KEY", "")
CITY = os.getenv("CITY", "Paris")

async def get_weather_forecast():
    """
    Appel réel à l'API OpenWeatherMap pour obtenir les prévisions.
    Extrait l'indice d'ensoleillement (cloudiness) pour calculer le coefficient.
    """
    url = f"http://api.openweathermap.org/data/2.5/weather?q={CITY}&appid={OPENWEATHER_API_KEY}&units=metric"
    
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(url, timeout=10)
            if response.status_code == 200:
                data = response.json()
                # Cloudiness est en %, on inverse pour avoir l'ensoleillement (0 à 1)
                clouds = data.get("clouds", {}).get("all", 50)
                solar_prediction = (100 - clouds) / 100
                print(f"Météo réelle récupérée : {CITY}, Nuages : {clouds}%, Ensoleillement : {solar_prediction}")
                return solar_prediction
            else:
                print(f"Erreur API Météo : {response.status_code}")
                return 0.5 # Valeur par défaut en cas d'erreur
    except Exception as e:
        print(f"Exception API Météo : {e}")
        return 0.5

def calculate_energy_strategy(state: HouseState, solar_prediction: float):
    """
    Logique de décision pour le basculement énergétique hybride.
    """
    # Mise à jour du coefficient de basculement basé sur la météo de demain
    state.energy.switch_coefficient = solar_prediction
    
    # Règle : Si batterie faible et prévision météo mauvaise pour demain
    if state.energy.battery_level < state.config.battery_critical_threshold and solar_prediction < 0.3:
        state.energy.source = "grid"
    elif state.energy.battery_level > (state.config.battery_critical_threshold + 10):
        state.energy.source = "solar"
    
    # Règle d'économie : Si on est sur batterie et que personne n'est là
    if state.energy.source == "solar":
        if not state.sensors.presence_salon:
            state.controls.lights_salon = False
        if not state.sensors.presence_cuisine:
            state.controls.lights_cuisine = False
            
    return state

def update_climatisation(state: HouseState):
    """
    Logique de contrôle de la climatisation selon la température.
    Ne s'exécute que si le mode est AUTO.
    """
    if state.controls.climatisation_mode == "MANUAL":
        return state
        
    temp = state.sensors.temperature
    if temp > state.config.temp_threshold_high:
        state.controls.climatisation = "COOL"
        # Intensité proportionnelle à l'écart : 20% par degré d'écart, max 100%
        diff = temp - state.config.temp_threshold_high
        state.controls.climatisation_intensity = min(100.0, diff * 20.0)
    elif temp < state.config.temp_threshold_low:
        state.controls.climatisation = "HEAT"
        # Intensité proportionnelle à l'écart : 20% par degré d'écart, max 100%
        diff = state.config.temp_threshold_low - temp
        state.controls.climatisation_intensity = min(100.0, diff * 20.0)
    else:
        state.controls.climatisation = "OFF"
        state.controls.climatisation_intensity = 0.0
    return state
