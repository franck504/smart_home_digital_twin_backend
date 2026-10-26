# Re-export all models from the canonical source
from app.models.house import RoomState, Configuration, Energy, Weather, HouseState

__all__ = ["RoomState", "Configuration", "Energy", "Weather", "HouseState"]

