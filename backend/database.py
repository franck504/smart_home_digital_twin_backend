import os
from influxdb_client import InfluxDBClient, Point, WritePrecision
from influxdb_client.client.write_api import SYNCHRONOUS
from datetime import datetime

# Configuration InfluxDB via variables d'environnement
URL = os.getenv("INFLUXDB_URL", "http://localhost:8086")
TOKEN = os.getenv("INFLUXDB_TOKEN", "my-super-secret-auth-token")
ORG = os.getenv("INFLUXDB_ORG", "my-org")
BUCKET = os.getenv("INFLUXDB_BUCKET", "jumeau_bucket")

client = InfluxDBClient(url=URL, token=TOKEN, org=ORG)
write_api = client.write_api(write_options=SYNCHRONOUS)

def save_sensor_data(room: str, temperature: float, luminosity: float, presence: bool):
    """
    Enregistre les données de capteurs dans InfluxDB par pièce.
    """
    point = Point("environment") \
        .tag("room", room) \
        .tag("host", "wokwi_esp32") \
        .field("temperature", float(temperature)) \
        .field("luminosity", float(luminosity)) \
        .field("presence", int(presence)) \
        .time(datetime.utcnow(), WritePrecision.NS)
    
    try:
        write_api.write(bucket=BUCKET, record=point)
    except Exception as e:
        print(f"Erreur lors de l'écriture dans InfluxDB : {e}")

def save_energy_state(source: str, battery_level: float):
    """
    Enregistre l'état énergétique dans InfluxDB.
    """
    point = Point("energy") \
        .field("source", source) \
        .field("battery_level", float(battery_level)) \
        .time(datetime.utcnow(), WritePrecision.NS)
    
    try:
        write_api.write(bucket=BUCKET, record=point)
    except Exception as e:
        print(f"Erreur lors de l'écriture dans InfluxDB : {e}")
