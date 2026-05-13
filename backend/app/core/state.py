from typing import List
from fastapi import WebSocket
from app.models.house import HouseState

# Global state of the digital twin
current_state = HouseState()

# Connected WebSocket clients (mobile apps, 3D dashboards)
clients: List[WebSocket] = []

# Reference to the main asyncio loop for thread-safe operations
main_loop = None
