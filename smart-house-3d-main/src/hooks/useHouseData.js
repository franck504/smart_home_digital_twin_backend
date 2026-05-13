import { useState, useEffect } from "react";
import { api } from "../services/api";

export function useHouseData() {
  const [data, setData] = useState(null);

  useEffect(() => {
    // 1. Chargement initial
    api.getState().then(setData).catch(console.error);

    // 2. Connexion WebSocket pour le temps réel
    const ws = api.connectWebSocket((newData) => {
      setData(newData);
    });

    return () => {
      if (ws) ws.close();
    };
  }, []);

  return data;
}