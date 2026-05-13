import os
import time
from influxdb_client import InfluxDBClient, Point, WritePrecision
from influxdb_client.client.write_api import SYNCHRONOUS

# Database connection configuration
INFLUXDB_URL = os.getenv("INFLUXDB_URL", "http://localhost:8086")
INFLUXDB_TOKEN = os.getenv("DOCKER_INFLUXDB_INIT_ADMIN_TOKEN", "my-super-secret-auth-token")
INFLUXDB_ORG = os.getenv("DOCKER_INFLUXDB_INIT_ORG", "my-org")
INFLUXDB_BUCKET = os.getenv("DOCKER_INFLUXDB_INIT_BUCKET", "jumeau_bucket")

def get_db_client():
    """Initializes the InfluxDB client."""
    return InfluxDBClient(url=INFLUXDB_URL, token=INFLUXDB_TOKEN, org=INFLUXDB_ORG)

def save_sensor_data(room_id: str, temperature: float, luminosity: float, presence: bool):
    """
    Persists room sensor metrics to InfluxDB.
    Useful for historical analysis and dashboarding (e.g. Grafana).
    """
    try:
        with get_db_client() as client:
            write_api = client.write_api(write_options=SYNCHRONOUS)
            point = Point("room_sensors") \
                .tag("room", room_id) \
                .field("temperature", float(temperature)) \
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
    try:
        with get_db_client() as client:
            write_api = client.write_api(write_options=SYNCHRONOUS)
            point = Point("energy_state") \
                .field("source", source) \
                .field("battery_level", float(battery_level)) \
                .time(time.time_ns(), WritePrecision.NS)
            write_api.write(bucket=INFLUXDB_BUCKET, record=point)
    except Exception as e:
        print(f"Database Error (Energy): {e}")
