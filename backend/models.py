from pydantic import BaseModel, Field
from typing import Literal

class Sensors(BaseModel):
    temperature: float = Field(22.0, ge=-50, le=100, description="Température en °C", examples=[24.5])
    presence_salon: bool = Field(False, description="Détection de présence salon", examples=[True])
    presence_cuisine: bool = Field(False, description="Détection de présence cuisine", examples=[False])
    luminosity: float = Field(0.0, ge=0, le=2000, description="Luminosité en Lux", examples=[650.0])

class Configuration(BaseModel):
    temp_threshold_high: float = Field(26.0, ge=15, le=40, description="Seuil clim Froid", examples=[26.0])
    temp_threshold_low: float = Field(18.0, ge=5, le=30, description="Seuil clim Chaud", examples=[18.0])
    battery_critical_threshold: float = Field(20.0, ge=0, le=50, description="Seuil batterie critique %", examples=[20.0])

class Energy(BaseModel):
    source: Literal["solar", "grid"] = Field("solar", description="Source d'énergie actuelle", examples=["solar"])
    battery_level: float = Field(100.0, ge=0, le=100, description="Niveau de batterie en %", examples=[85.0])
    switch_coefficient: float = Field(1.0, ge=0, le=1, description="Coefficient d'ensoleillement météo", examples=[0.8])

class Controls(BaseModel):
    climatisation_mode: Literal["AUTO", "MANUAL"] = Field("AUTO", description="Mode de régulation", examples=["AUTO"])
    climatisation: Literal["OFF", "HEAT", "COOL"] = Field("OFF", description="État de la clim", examples=["OFF"])
    climatisation_intensity: float = Field(0.0, ge=0, le=100, description="Puissance de la clim en %", examples=[75.0])
    lights_salon: bool = Field(False, description="Lumière Salon", examples=[True])
    lights_cuisine: bool = Field(False, description="Lumière Cuisine", examples=[False])

class HouseState(BaseModel):
    sensors: Sensors = Sensors()
    energy: Energy = Energy()
    controls: Controls = Controls()
    config: Configuration = Configuration()
