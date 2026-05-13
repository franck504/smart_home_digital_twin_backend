from app.core.state import clients, current_state
from app.core.mqtt import publish_actuators

async def sync_and_broadcast(send_mqtt: bool = True):
    """
    Synchronizes the digital twin state across all connected clients.
    Broadcasts the state via WebSockets and optionally updates physical devices via MQTT.
    """
    message = current_state.model_dump_json()
    
    # Broadcast to all connected WebSocket clients (mobile/web)
    for client in list(clients):
        try:
            await client.send_text(message)
        except Exception:
            # Safely remove disconnected clients
            if client in clients:
                clients.remove(client)
    
    # Update physical hardware if required
    if send_mqtt:
        publish_actuators(current_state)
