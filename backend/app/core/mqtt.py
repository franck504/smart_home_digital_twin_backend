import json
import asyncio
import os
import paho.mqtt.client as mqtt
from app.core.state import current_state, main_loop

# MQTT Configuration from environment
MQTT_BROKER = os.getenv("MQTT_BROKER", "localhost")
MQTT_PORT = 1883
MQTT_TOPIC_SENSORS = "franck504/home/sensors"
MQTT_TOPIC_ACTUATORS = "franck504/home/actuators"

# Initialize MQTT Client (using v2 callback API)
mqtt_client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)

def on_connect(client, userdata, flags, rc, properties):
    """
    Triggered when the client connects to the broker.
    Subscribes to sensor data and actuator feedback topics.
    """
    print(f"Connected to MQTT Broker with code {rc}", flush=True)
    client.subscribe(MQTT_TOPIC_SENSORS)
    client.subscribe(MQTT_TOPIC_ACTUATORS)

def on_message(client, userdata, msg):
    """
    Handles incoming MQTT messages.
    Updates the global state based on sensor data or physical actuator changes (Wokwi).
    """
    from app.core.ws import sync_and_broadcast
    from app.services.logic import process_state_update
    
    try:
        topic = msg.topic
        payload = json.loads(msg.payload.decode())
        
        if topic == MQTT_TOPIC_SENSORS:
            # Update sensors per room
            for room_id, data in payload.items():
                if room_id in current_state.rooms:
                    room = current_state.rooms[room_id]
                    room.temperature = data.get("temperature", room.temperature)
                    room.presence = data.get("presence", room.presence)
                    room.luminosity = data.get("luminosity", room.luminosity)
            
            if main_loop:
                asyncio.run_coroutine_threadsafe(process_state_update(), main_loop)

        elif topic == MQTT_TOPIC_ACTUATORS:
            # Physical Button Sync: If Wokwi reports a manual light change
            if "rooms" in payload:
                changed = False
                for room_id, data in payload["rooms"].items():
                    if room_id in current_state.rooms:
                        # If physical state differs from digital twin state
                        if "lights" in data and current_state.rooms[room_id].lights != data["lights"]:
                            current_state.rooms[room_id].lights = data["lights"]
                            changed = True
                
                # Broadcast changes to mobile apps via WebSockets without looping MQTT
                if changed and main_loop:
                    asyncio.run_coroutine_threadsafe(sync_and_broadcast(send_mqtt=False), main_loop)
    except Exception as e:
        print(f"MQTT Error in message handling: {e}")

# Assign callbacks
mqtt_client.on_connect = on_connect
mqtt_client.on_message = on_message

def publish_actuators(state):
    """
    Publishes the current actuator state to the MQTT broker.
    Used to synchronize physical devices (Wokwi) with the digital twin.
    """
    commands = {
        "energy_source": state.energy.source,
        "rooms": {
            room_id: {
                "lights": room.lights,
                "climatisation": room.climatisation,
                "temperature_de_regulation": room.temperature_de_regulation
            } for room_id, room in state.rooms.items()
        }
    }
    mqtt_client.publish(MQTT_TOPIC_ACTUATORS, json.dumps(commands))
