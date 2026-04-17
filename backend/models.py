from pydantic import BaseModel, Field
from typing import Literal, Dict

class RoomState(BaseModel):
    name: str = Field(..., description="Nom de la pièce")
    temperature: float = Field(22.0, description="Température en °C")
    luminosity: float = Field(0.0, description="Luminosité en Lux")
    presence: bool = Field(False, description="Détection de présence")
    
    # Contrôles spécifiques à la pièce
    lights: bool = Field(False, description="État de la lumière")
    climatisation_mode: Literal["AUTO", "MANUAL"] = Field("AUTO", description="Mode de régulation clim")
    climatisation: Literal["OFF", "HEAT", "COOL"] = Field("OFF", description="État de la clim")
    temperature_de_regulation: float = Field(22.0, ge=10, le=35, description="Température cible pour le thermostat")

class Configuration(BaseModel):
    temp_threshold_high: float = Field(26.0, ge=15, le=40, description="Seuil clim Froid")
    temp_threshold_low: float = Field(18.0, ge=5, le=30, description="Seuil clim Chaud")
    battery_critical_threshold: float = Field(20.0, ge=0, le=50, description="Seuil batterie critique %")

class Energy(BaseModel):
    source: Literal["solar", "grid"] = Field("solar", description="Source d'énergie actuelle")
    battery_level: float = Field(100.0, ge=0, le=100, description="Niveau de batterie en %")

class Weather(BaseModel):
    outside_temp: float = Field(20.0, description="Température extérieure réelle")
    description: str = Field("Ensoleillé", description="Description météo")
    icon: str = Field("01d", description="Code icône OpenWeather")
    solar_prediction: float = Field(0.5, ge=0, le=1, description="Indice d'ensoleillement")

class HouseState(BaseModel):
    rooms: Dict[str, RoomState] = {
        "salon": RoomState(name="Salon"),
        "cuisine": RoomState(name="Cuisine")
    }
    energy: Energy = Energy()
    config: Configuration = Configuration()
    weather: Weather = Weather()
