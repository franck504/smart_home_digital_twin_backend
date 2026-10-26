import asyncio
import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from app.core.state import current_state, clients
from app.core.mqtt import mqtt_client, MQTT_BROKER, MQTT_PORT
from app.api.endpoints import router

# Configure structured logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s"
)
logger = logging.getLogger("smart_home_backend")

@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Modern lifespan context manager (replaces deprecated startup/shutdown events).
    Initializes MQTT connectivity and releases resources upon shutdown.
    """
    import app.core.state as state_module
    state_module.main_loop = asyncio.get_running_loop()

    try:
        mqtt_client.connect(MQTT_BROKER, MQTT_PORT, 60)
        mqtt_client.loop_start()
        logger.info(f"MQTT Client connected to {MQTT_BROKER}:{MQTT_PORT}")
    except Exception as e:
        logger.error(f"Failed to connect to MQTT Broker: {e}")

    yield

    logger.info("Application shutting down: stopping MQTT client...")
    mqtt_client.loop_stop()
    mqtt_client.disconnect()
    logger.info("MQTT Client stopped cleanly.")

# Create the FastAPI instance
app = FastAPI(
    title="Smart Home Digital Twin Backend",
    description="Orchestrator for 3D visualization, Mobile app, and Wokwi simulation.",
    version="1.0.0",
    lifespan=lifespan
)

# Enable Cross-Origin Resource Sharing
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include modular API routes
app.include_router(router)

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    """
    Main WebSocket hub for real-time synchronization.
    Sends full state upon connection, then remains open for live updates.
    """
    await websocket.accept()
    clients.append(websocket)
    # Send initial state immediately
    await websocket.send_text(current_state.model_dump_json())
    try:
        while True:
            # Keep connection alive (receive heartbeats if any)
            await websocket.receive_text()
    except WebSocketDisconnect:
        if websocket in clients:
            clients.remove(websocket)
