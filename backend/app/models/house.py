from typing import Dict, Literal
from pydantic import BaseModel, Field

class RoomState(BaseModel):
    """
    Represents the physical and logical state of a specific room.
    """
    temperature: float = Field(22.0, description="Ambient temperature in Celsius")
    humidity: float = Field(50.0, description="Relative humidity percentage")
    presence: bool = Field(False, description="Whether human presence is detected")
    luminosity: float = Field(300.0, description="Ambient light level in Lux")
    lights: bool = Field(False, description="Main light switch state")
    climatisation: Literal["OFF", "HEAT", "COOL"] = Field("OFF", description="HVAC operation mode")
    climatisation_mode: Literal["AUTO", "MANUAL"] = Field("AUTO", description="Thermostat regulation logic")
    temperature_de_regulation: float = Field(22.0, description="Target temperature for AUTO mode")

class Configuration(BaseModel):
    """
    Global system rules and thresholds.
    """
    temp_threshold_high: float = Field(26.0, ge=15, le=40, description="High threshold for cooling")
    temp_threshold_low: float = Field(18.0, ge=5, le=30, description="Low threshold for heating")
    battery_critical_threshold: float = Field(20.0, ge=0, le=50, description="Critical battery percentage")
    auto_light_off: bool = Field(True, description="Automatically turn off lights when no presence")
    auto_clim_off: bool = Field(True, description="Automatically turn off HVAC when no presence")
    lux_threshold: float = Field(200.0, description="Lux threshold for automatic lighting")

class Energy(BaseModel):
    """
    Power management and source state.
    """
    source: Literal["solar", "grid"] = Field("solar", description="Current power source")
    battery_level: float = Field(100.0, ge=0, le=100, description="Current battery charge %")
    consumption: float = Field(0.0, description="Instantaneous power consumption in Watts")

class Weather(BaseModel):
    """
    External environmental conditions.
    """
    outside_temp: float = Field(20.0, description="External temperature")
    description: str = Field("Ensoleillé", description="Weather description")
    icon: str = Field("01d", description="OpenWeather icon code")
    solar_prediction: float = Field(0.5, ge=0, le=1, description="Solar energy yield coefficient")
    location: str = Field("Fianarantsoa", description="Target city for weather forecasts")
    last_updated: str = Field("", description="Timestamp of the last update")

class HouseState(BaseModel):
    """
    The full state of the smart home digital twin.
    """
    rooms: Dict[str, RoomState] = {
        "salon": RoomState(),
        "cuisine": RoomState(),
        "chambre": RoomState(),
        "douche": RoomState()
    }
    config: Configuration = Configuration()
    energy: Energy = Energy()
    weather: Weather = Weather()
