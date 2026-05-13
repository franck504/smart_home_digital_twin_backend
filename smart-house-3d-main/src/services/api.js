import axios from "axios";

const USE_FAKE = false;
const API_URL = `http://${window.location.hostname}:8000`;
const WS_URL = `ws://${window.location.hostname}:8000/ws`;

export const api = {
  async getState() {
    if (USE_FAKE) {
      return {
        rooms: {
          salon: {
            name: "Salon",
            temperature: 22.0,
            luminosity: 0.0,
            presence: true,
            lights: true,
            climatisation_mode: "AUTO",
            climatisation: "COOL", // OFF/HEAT/COOL
            temperature_de_regulation: 22.0,
          },
          cuisine: {
            name: "Cuisine",
            temperature: 23.0,
            luminosity: 0.0,
            presence: true,
            lights: false,
            climatisation_mode: "AUTO",
            climatisation: "OFF",
            temperature_de_regulation: 30.0,
          },
        },
        energy: {
          source: "solar",
          battery_level: 100.0,
        },
        config: {
          temp_threshold_high: 26.0,
          temp_threshold_low: 18.0,
          battery_critical_threshold: 20.0,
        },
        weather: {
          outside_temp: 20.0,
          description: "Ensoleillé",
          icon: "01d",
          solar_prediction: 0.5,
        },
      };
    }

    const res = await axios.get(`${API_URL}/state`);
    return res.data;
  },

  connectWebSocket(onMessage) {
    if (USE_FAKE) return null;
  
    const ws = new WebSocket(WS_URL);
  
    ws.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);
        onMessage(data);
      } catch (e) {
        console.error("Failed to parse WS message:", e);
      }
    };
  
    ws.onerror = (err) => console.error("WebSocket error:", err);
    ws.onclose = () => {
      console.log("WebSocket connection closed. Retrying in 3s...");
      setTimeout(() => this.connectWebSocket(onMessage), 3000);
    };
  
    return ws;
  },
};




