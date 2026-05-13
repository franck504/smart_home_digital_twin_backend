import React from 'react'
import { Floor, Wall } from './HouseComponent';
import Bulb from './Bulb';
import { useHouseData } from '../hooks/useHouseData';
import { CoffeeTable, Sofa, TV, Rug, FloorLamp, Bookshelf } from './SalonComponent';
import RoomFog from './RoomFog';
import Person from './Person';

const wallColor = "#d4c9b8";
const wallRough = 0.95;

const Salon = ({ fogConfig }) => {
  const data = useHouseData();
  const lightOn = data?.rooms?.salon?.lights ?? false;
  const ambientColor = lightOn ? "#fff5e0" : "#c8b89a";
  const presence = data?.rooms?.salon?.presence ?? false;
  return (
    <>
      <ambientLight color={ambientColor} intensity={lightOn ? 0.6 : 0.25} />
      <pointLight
        position={[-3, 2.7, 0]}
        color="#ffe4b0"
        intensity={lightOn ? 15.2 : 0}
        distance={8}
        decay={2}
        castShadow
        shadow-mapSize-width={512}
        shadow-mapSize-height={512}
      />

      <Floor position={[-3, 0, 0]} size={[5, 5]} color="#b8a98a" />
      <Wall position={[-3, 1.5, -2.5]} size={[5, 3, 0.15]} color={wallColor} roughness={wallRough} />
      <Wall position={[-5.5, 1.5, 0]} size={[0.15, 3, 5]} color={wallColor} roughness={wallRough} />

      {/* Ampoules */}
      <Bulb position={[-2.5, 2.88, -0.5]} on={lightOn} />
      <Bulb position={[-3.8, 2.88, 1.0]} on={lightOn} />

      {/* Meubles */}
      <Sofa position={[-3, -0.1, -1]} />
      <group position={[0, 0, 2]}>
        <CoffeeTable position={[-3, 0, 0]} />
        <TV position={[-3, -.15, 0]} />
      </group>

      <Rug position={[-3, 0.01, 0.5]} />
      <FloorLamp position={[-1.6, 0, -2]} />
      <Bookshelf position={[-5, 0, -2.35]} />

      <RoomFog
        color={fogConfig?.color}
        active={fogConfig?.density > 0}
        position={[-3, 1.5, 0]}
        size={[5, 3, 5]}
      />

      {presence && <Person position={[-3, -.5, 0.5]} />}
    </>
  );
};

export default Salon;
