import paho.mqtt.client as mqtt
import json
import time
import random

MQTT_BROKER = "localhost"
MQTT_TOPIC = "franck504/home/sensors"  # Doit correspondre à mqtt.py

client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)

# Profils réalistes par pièce : (temp_base, lum_base, humidity_base)
ROOM_PROFILES = {
    "salon":   (22.0, 500, 45.0),
    "cuisine": (24.0, 200, 60.0),
    "chambre": (20.0, 100, 50.0),
    "douche":  (26.0,  50, 80.0),
}

def generate_room_data(base_temp, base_lum, base_humidity):
    """Génère des données capteurs réalistes avec bruit aléatoire."""
    return {
        "temperature": round(base_temp + random.uniform(-0.5, 0.5), 1),
        "humidity":    round(base_humidity + random.uniform(-2.0, 2.0), 1),
        "presence":    random.choice([True, False]),
        "luminosity":  max(0, int(base_lum + random.uniform(-50, 50))),
    }

def simulate():
    print(f"Connexion au broker {MQTT_BROKER}...")
    try:
        client.connect(MQTT_BROKER, 1883, 60)
    except Exception as e:
        print(f"Erreur de connexion : {e}")
        return

    print(f"Simulation 4 zones démarrée sur '{MQTT_TOPIC}' (Ctrl+C pour arrêter)")
    try:
        while True:
            data = {
                room: generate_room_data(*profile)
                for room, profile in ROOM_PROFILES.items()
            }

            client.publish(MQTT_TOPIC, json.dumps(data))
            print(f"Publié : {json.dumps(data, indent=2)}")
            time.sleep(5)
    except KeyboardInterrupt:
        print("Arrêt de la simulation.")
        client.disconnect()

if __name__ == "__main__":
    simulate()
