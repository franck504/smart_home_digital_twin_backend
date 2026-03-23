import paho.mqtt.client as mqtt
import json
import time
import random

def simulate_esp32():
    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
    try:
        client.connect("localhost", 1883, 60)
        print("Simulateur ESP32 connecté au broker MQTT.")
    except Exception as e:
        print(f"Erreur : Est-ce qu'un broker MQTT (mosquitto) tourne sur localhost ? {e}")
        return

    while True:
        # Simulation de données capteurs
        data = {
            "temperature": round(random.uniform(15.0, 30.0), 1),
            "presence_salon": random.choice([True, False]),
            "presence_cuisine": random.choice([True, False]),
            "luminosity": random.uniform(200, 800)
        }
        
        print(f"Publication : {data}")
        client.publish("home/sensors", json.dumps(data))
        time.sleep(5)

if __name__ == "__main__":
    simulate_esp32()
