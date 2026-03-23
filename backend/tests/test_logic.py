import pytest
from backend.models import HouseState
from backend.logic import calculate_energy_strategy, update_climatisation

def test_climate_control_auto_neutral_zone():
    """Test que la clim est OFF entre les seuils."""
    state = HouseState()
    state.sensors.temperature = 22.0
    state.config.temp_threshold_high = 25.0
    state.config.temp_threshold_low = 19.0
    
    update_climatisation(state)
    
    assert state.controls.climatisation == "OFF"
    assert state.controls.climatisation_intensity == 0.0

def test_climate_control_auto_cool_proportional():
    """Test que l'intensité augmente avec la température (COOL)."""
    state = HouseState()
    # 26°C avec un seuil à 24°C -> écart de 2°C -> 40% d'intensité
    state.sensors.temperature = 26.0
    state.config.temp_threshold_high = 24.0
    
    update_climatisation(state)
    
    assert state.controls.climatisation == "COOL"
    assert state.controls.climatisation_intensity == 40.0

def test_energy_strategy_solar_high_battery():
    """Test du maintien en mode Solaire si batterie pleine."""
    state = HouseState()
    state.energy.battery_level = 90.0
    
    calculate_energy_strategy(state, solar_prediction=1.0)
    
    assert state.energy.source == "solar"

def test_energy_strategy_grid_low_battery_no_sun():
    """Test du basculement sur le réseau si batterie faible et pas de soleil."""
    state = HouseState()
    state.energy.battery_level = 15.0 # En dessous du seuil de 20%
    
    calculate_energy_strategy(state, solar_prediction=0.2)
    
    assert state.energy.source == "grid"

def test_energy_saving_lights():
    """Test de l'extinction automatique des lumières en mode Solaire sans présence."""
    state = HouseState()
    state.energy.source = "solar"
    state.sensors.presence_salon = False
    state.controls.lights_salon = True # On l'allume manuellement
    
    calculate_energy_strategy(state, solar_prediction=1.0)
    
    # La stratégie doit l'éteindre pour économiser la batterie
    assert state.controls.lights_salon == False

def test_manual_mode_no_auto_update():
    """Test que le mode MANUAL empêche les mises à jour automatiques."""
    state = HouseState()
    state.controls.climatisation_mode = "MANUAL"
    state.controls.climatisation = "OFF"
    state.sensors.temperature = 35.0 # Très chaud, devrait déclencher COOL en AUTO
    
    update_climatisation(state)
    
    # Doit rester OFF car on est en MANUAL
    assert state.controls.climatisation == "OFF"
