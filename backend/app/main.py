import asyncio
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from app.core.state import current_state, clients, main_loop as global_main_loop
from app.core.mqtt import mqtt_client, MQTT_BROKER, MQTT_PORT
from app.api.endpoints import router

# Create the FastAPI instance
app = FastAPI(
    title="Smart Home Digital Twin Backend",
    description="Orchestrator for 3D visualization, Mobile app, and Wokwi simulation.",
    version="1.0.0"
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

@app.on_event("startup")
async def startup_event():
    """
    Application startup sequence: initializes MQTT and captures the main loop.
    """
    import app.core.state as state_module
    state_module.main_loop = asyncio.get_running_loop()
    
    try:
        mqtt_client.connect(MQTT_BROKER, MQTT_PORT, 60)
        mqtt_client.loop_start()
        print(f"MQTT Client started on {MQTT_BROKER}:{MQTT_PORT}")
    except Exception as e:
        print(f"Failed to connect to MQTT Broker: {e}")

@app.on_event("shutdown")
def shutdown_event():
    """Cleanup sequence on application shutdown."""
    mqtt_client.loop_stop()
    mqtt_client.disconnect()
