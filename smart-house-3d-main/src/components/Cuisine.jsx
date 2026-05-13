import React from 'react'
import { useHouseData } from '../hooks/useHouseData';
import { Floor, Wall } from './HouseComponent';
import Bulb from './Bulb';
import { Chair, CounterProps, Fridge, HerbPot, KitchenCounter, KitchenTable, Microwave, Oven, PendantLight, RangeHood, Sink, WallClock } from './CuisineComponent';
import RoomFog from './RoomFog';
import Person from './Person';

const wallColor = "#d4c9b8";
const wallRough = 0.95;

const Cuisine = ({ fogConfig }) => {
  const data = useHouseData();
  const lightOn = data?.rooms?.cuisine?.lights ?? false;
  const ambientColor = lightOn ? "#fff5e0" : "#c8b89a";
  const presence = data?.rooms?.cuisine?.presence ?? false;


  return (
    <>
      <ambientLight color={ambientColor} intensity={lightOn ? 0.6 : 0.25} />
      <pointLight
        position={[2.5, 2.7, 0]}
        color="#ffe4b0"
        intensity={lightOn ? 15.2 : 0}
        distance={8}
        decay={2}
        castShadow
        shadow-mapSize-width={512}
        shadow-mapSize-height={512}
      />

      {/* Structure */}
      <Floor position={[2, 0, 0]} size={[5, 5]} color="#c8bdb0" />
      <Wall position={[2, 1.5, -2.5]} size={[5, 3, 0.15]} color={wallColor} roughness={wallRough} />
      <Wall position={[4.5, 1.5, 0]} size={[0.15, 3, 5]} color={wallColor} roughness={wallRough} />

      {/* Ampoules */}
      <Bulb position={[.5, 2.88, -0.5]} on={lightOn} />
      <Bulb position={[3.5, 2.88, 1.5]} on={lightOn} />
      <PendantLight position={[2, 2.88, 0]} on={lightOn} />

      {/* Meubles */}
      <KitchenTable position={[1.8, 0, 1.0]} />
      <Chair position={[1.0, 0, 1.0]} rotation={[0, Math.PI / 2, 0]} />
      <Chair position={[2.6, 0, 1.0]} rotation={[0, -Math.PI / 2, 0]} />
      <Chair position={[1.8, 0, 1.55]} rotation={[0, Math.PI, 0]} />
      <Chair position={[1.8, 0, 0.45]} rotation={[0, 0, 0]} />

      <KitchenCounter position={[3.5, 0, -2.2]} />
      <Sink position={[3.5, 0, -2.1]} />
      <CounterProps position={[4, 0.9, -2.3]} />
      <Microwave position={[2.9, 1.1, -2.3]} />

      <Fridge position={[0, 0, -2.1]} />
      <Oven position={[1.2, 0.3, -2.2]} />
      <RangeHood position={[1.2, 2, -2.3]} />
      <HerbPot position={[0, 2, -2.0]} color="#4a9a4a" />
      <HerbPot position={[0.2, 2, -2.2]} color="#2e7a2e" />


      <RoomFog
        color={fogConfig?.color}
        active={fogConfig?.density > 0}
        position={[2, 1.5, 0]}
        size={[5, 3, 5]}
      />

     

      {presence && <Person position={[3, -.5, 0.5]} />}
    </>
  );
};

export default Cuisine;
