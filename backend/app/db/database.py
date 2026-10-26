import os
import time
from influxdb_client import InfluxDBClient, Point, WritePrecision
from influxdb_client.client.write_api import SYNCHRONOUS

# Database connection configuration
INFLUXDB_URL = os.getenv("INFLUXDB_URL", "http://localhost:8086")
INFLUXDB_TOKEN = os.getenv("INFLUXDB_TOKEN") or os.getenv("DOCKER_INFLUXDB_INIT_ADMIN_TOKEN", "")
INFLUXDB_ORG = os.getenv("INFLUXDB_ORG") or os.getenv("DOCKER_INFLUXDB_INIT_ORG", "my-org")
INFLUXDB_BUCKET = os.getenv("INFLUXDB_BUCKET") or os.getenv("DOCKER_INFLUXDB_INIT_BUCKET", "jumeau_bucket")

_db_client = None

def get_db_client():
    """Initializes or reuses the InfluxDB client singleton."""
    global _db_client
    if not INFLUXDB_TOKEN:
        return None
    if _db_client is None:
        try:
            _db_client = InfluxDBClient(url=INFLUXDB_URL, token=INFLUXDB_TOKEN, org=INFLUXDB_ORG)
        except Exception as e:
            print(f"[InfluxDB Error] Could not initialize client: {e}")
            return None
    return _db_client

def save_sensor_data(room_id: str, temperature: float, luminosity: float, presence: bool, humidity: float = 50.0):
    """
    Persists room sensor metrics to InfluxDB.
    Useful for historical analysis and dashboarding (e.g. Grafana).
    """
    client = get_db_client()
    if not client:
        return
    try:
        write_api = client.write_api(write_options=SYNCHRONOUS)
        point = Point("room_sensors") \
            .tag("room", room_id) \
            .field("temperature", float(temperature)) \
            .field("humidity", float(humidity)) \
            .field("luminosity", float(luminosity)) \
            .field("presence", int(presence)) \
            .time(time.time_ns(), WritePrecision.NS)
        write_api.write(bucket=INFLUXDB_BUCKET, record=point)
    except Exception as e:
        print(f"Database Error (Sensors): {e}")

def save_energy_state(source: str, battery_level: float):
    """
    Persists energy metrics to InfluxDB.
    """
    client = get_db_client()
    if not client:
        return
    try:
        write_api = client.write_api(write_options=SYNCHRONOUS)
        point = Point("energy_state") \
            .field("source", source) \
            .field("battery_level", float(battery_level)) \
            .time(time.time_ns(), WritePrecision.NS)
        write_api.write(bucket=INFLUXDB_BUCKET, record=point)
    except Exception as e:
        print(f"Database Error (Energy): {e}")
