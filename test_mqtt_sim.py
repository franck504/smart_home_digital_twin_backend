import paho.mqtt.client as mqtt
import json
import time
import random

MQTT_BROKER = "localhost"
MQTT_TOPIC = "home/sensors"

client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)

def generate_room_data(base_temp, base_lum):
    return {
        "temperature": round(base_temp + random.uniform(-0.5, 0.5), 1),
        "presence": random.choice([True, False]),
        "luminosity": max(0, int(base_lum + random.uniform(-50, 50)))
    }

def simulate():
    print(f"Connexion au broker {MQTT_BROKER}...")
    try:
        client.connect(MQTT_BROKER, 1883, 60)
    except Exception as e:
        print(f"Erreur de connexion : {e}")
        return

    print("Simulation multi-zone démarrée (Ctrl+C pour arrêter)")
    try:
        while True:
            data = {
                "salon": generate_room_data(22.0, 500),
                "cuisine": generate_room_data(24.0, 200)
            }
            
            client.publish(MQTT_TOPIC, json.dumps(data))
            print(f"Publié : {data}")
            time.sleep(5)
    except KeyboardInterrupt:
        print("Arrêt de la simulation.")
        client.disconnect()

if __name__ == "__main__":
    simulate()
