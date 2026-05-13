import network
import time
from machine import Pin, ADC
import dht
import ujson
from umqtt.simple import MQTTClient

# --- CONFIGURATION PUBLIQUE ---
MQTT_SERVER = "broker.hivemq.com" 
ROOM_ID     = "salon"
TOPIC_SUB   = "franck504/home/actuators"
TOPIC_PUB   = "franck504/home/sensors"
TOPIC_ACT   = "franck504/home/actuators" # Pour informer le Twin du changement manuel

# --- PINS ---
sensor_dht = dht.DHT22(Pin(15))
pir        = Pin(13, Pin.IN)
ldr        = ADC(Pin(34))
ldr.atten(ADC.ATTN_11DB) 

led_light = Pin(2, Pin.OUT)
led_cool  = Pin(17, Pin.OUT)
led_heat  = Pin(4, Pin.OUT)
button    = Pin(16, Pin.IN, Pin.PULL_DOWN)

# --- VARIABLES D'ÉTAT ---
last_button_state = 0
light_state = 0
last_msg = 0

# --- MQTT CALLBACK : COMMANDE VENANT DU BACKEND ---
def sub_cb(topic, msg):
    global light_state
    print("\n[MQTT] Ordre reçu :", msg)
    try:
        data = ujson.loads(msg)
        if "rooms" in data and ROOM_ID in data["rooms"]:
            room_data = data["rooms"][ROOM_ID]

            # Mise à jour de la lumière
            light_state = 1 if room_data["lights"] else 0
            led_light.value(light_state)

            # Mise à jour Climatisation
            clim = room_data["climatisation"]
            led_cool.value(1 if clim == "COOL" else 0)
            led_heat.value(1 if clim == "HEAT" else 0)

            print("-> Synchro OK : Lumière={}, Clim={}".format(light_state, clim))
    except Exception as e:
        print("Erreur traitement message :", e)

# --- CONNEXION RÉSEAU ---
print("Connexion au WiFi...", end="")
sta_if = network.WLAN(network.STA_IF)
sta_if.active(True)
sta_if.connect('Wokwi-GUEST', '')
while not sta_if.isconnected():
    print(".", end="")
    time.sleep(0.5)
print(" OK !")

print("Connexion à HiveMQ...", end="")
client = MQTTClient("esp32-franck-sync", MQTT_SERVER)
client.set_callback(sub_cb)
try:
    client.connect()
    client.subscribe(TOPIC_SUB)
    print(" SUCCESS !")
except Exception as e:
    print(" Erreur MQTT :", e)

# --- BOUCLE PRINCIPALE ---
while True:
    try:
        # Vérifier si un message MQTT est arrivé
        client.check_msg()

        # 1. ENVOI DES CAPTEURS (Toutes les 2 secondes)
        if (time.time() - last_msg) > 2:
            sensor_dht.measure()
            
            # Calcul luminosité inversé et calibré (0 à 1000)
            val_brute = ldr.read()
            lum = int(((4095 - val_brute) / 4095) * 1000)

            payload = {
                ROOM_ID: {
                    "temperature": sensor_dht.temperature(),
                    "presence": pir.value() == 1,
                    "luminosity": lum
                }
            }
            client.publish(TOPIC_PUB, ujson.dumps(payload))
            print("[MQTT] Envoi Capteurs :", payload)
            last_msg = time.time()

        # 2. GESTION DU BOUTON PHYSIQUE (Action Manuelle)
        current_button_val = button.value()
        if current_button_val == 1 and last_button_state == 0:
            # Action Locale immédiate
            light_state = 1 - light_state
            led_light.value(light_state)
            print("Bouton pressé -> Lumière locale :", "ON" if light_state else "OFF")

            # Notification du Jumeau Numérique (Backend)
            cmd_payload = {
                "rooms": {
                    ROOM_ID: {
                        "lights": True if light_state == 1 else False
                    }
                }
            }
            client.publish(TOPIC_ACT, ujson.dumps(cmd_payload))
            print("[MQTT] Mise à jour Twin envoyée !")
            time.sleep(0.3) # Petit délai pour éviter les doubles appuis

        last_button_state = current_button_val

    except Exception as e:
        print("Erreur boucle :", e)
        time.sleep(5)

    time.sleep(0.05)
