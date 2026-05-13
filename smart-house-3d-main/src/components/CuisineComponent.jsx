import { Box } from "./HouseComponent";

export function KitchenCounter({ position }) {
  return (
    <group position={position}>
      <Box position={[0, 0.45,  0]}    size={[1.8, 0.9,  0.55]} color="#c9b99a" />
      <Box position={[0, 0.92,  0.02]} size={[1.86, 0.05, 0.58]} color="#e8e0d5" metalness={0.1} roughness={0.4} />
      <Box position={[0, 1.8,  -0.1]}  size={[1.8, 0.7,  0.35]} color="#c9b99a" />
    </group>
  );
}

export function Sink({ position }) {
  return (
    <group position={position}>
      <Box position={[0, 0.93, 0]} size={[0.5, 0.04, 0.4]} color="#d0d0d0" metalness={0.6} roughness={0.2} />
      <mesh position={[0, 0.92, 0]}>
        <boxGeometry args={[0.38, 0.12, 0.28]} />
        <meshStandardMaterial color="#b0b0b0" metalness={0.7} roughness={0.2} />
      </mesh>
      <Box position={[0, 1.08, -0.1]}  size={[0.03, 0.2,  0.03]} color="#aaa" metalness={0.9} roughness={0.1} />
      <Box position={[0, 1.18, -0.02]} size={[0.03, 0.03, 0.18]} color="#aaa" metalness={0.9} roughness={0.1} />
    </group>
  );
}

export function KitchenTable({ position }) {
  const legs = [[-0.43, -0.25], [0.43, -0.25], [-0.43, 0.25], [0.43, 0.25]];
  return (
    <group position={position}>
      <Box position={[0, 0.76, 0]} size={[1.0, 0.05, 0.6]} color="#a0784a" roughness={0.5} metalness={0.05} />
      {legs.map(([x, z], i) => (
        <Box key={i} position={[x, 0.38, z]} size={[0.05, 0.75, 0.05]} color="#8b6030" />
      ))}
    </group>
  );
}

export function Chair({ position, rotation = [0, 0, 0] }) {
  const legs = [[-0.17, -0.17], [0.17, -0.17], [-0.17, 0.17], [0.17, 0.17]];
  return (
    <group position={position} rotation={rotation}>
      <Box position={[0, 0.44,  0]}    size={[0.42, 0.04, 0.42]} color="#8b6030" />
      <Box position={[0, 0.75, -0.19]} size={[0.42, 0.58, 0.04]} color="#7a5428" />
      {legs.map(([x, z], i) => (
        <Box key={i} position={[x, 0.22, z]} size={[0.04, 0.44, 0.04]} color="#7a5428" />
      ))}
    </group>
  );
}


export function Fridge({ position }) {
  return (
    <group position={position}>
      <Box position={[0, 1.0,  0]} size={[0.7, 2.0, 0.65]} color="#e0ddd8" roughness={0.3} metalness={0.15} />
      <Box position={[0, 1.32, 0.33]} size={[0.68, 0.02, 0.01]} color="#bbb" metalness={0.4} roughness={0.3} />
      <Box position={[0.28, 1.6,  0.34]} size={[0.03, 0.28, 0.04]} color="#999" metalness={0.8} roughness={0.1} />
      <Box position={[0.28, 0.9,  0.34]} size={[0.03, 0.28, 0.04]} color="#999" metalness={0.8} roughness={0.1} />
    </group>
  );
}


export function Microwave({ position }) {
  return (
    <group position={position}>
      <Box position={[0, 0, 0]} size={[0.55, 0.32, 0.38]} color="#2a2a2a" roughness={0.4} metalness={0.2} />
      <mesh position={[-0.1, 0, 0.195]}>
        <planeGeometry args={[0.32, 0.26]} />
        <meshStandardMaterial color="#0d1a0d" emissive="#051005" emissiveIntensity={0.3} roughness={0.1} metalness={0.2} />
      </mesh>
      <Box position={[0.18, 0, 0.195]} size={[0.16, 0.28, 0.01]} color="#1a1a1a" />
      <mesh position={[0.2, -0.05, 0.2]}>
        <cylinderGeometry args={[0.025, 0.025, 0.015, 10]} />
        <meshStandardMaterial color="#555" metalness={0.6} roughness={0.3} />
      </mesh>
    </group>
  );
}


export function Oven({ position }) {
  return (
    <group position={position}>

      <Box position={[0, 0, 0]} size={[0.6, 0.55, 0.55]} color="#1e1e1e" roughness={0.5} />
   
      <mesh position={[0, 0.02, 0.278]}>
        <planeGeometry args={[0.50, 0.40]} />
        <meshStandardMaterial color="#0a0a0a" roughness={0.15} metalness={0.3} />
      </mesh>
     
      <Box position={[0, 0.22, 0.29]} size={[0.40, 0.03, 0.03]} color="#888" metalness={0.8} roughness={0.15} />
    
      {[-0.15, 0, 0.15].map((x, i) => (
        <mesh key={i} position={[x, -0.22, 0.282]}>
          <cylinderGeometry args={[0.022, 0.022, 0.012, 10]} />
          <meshStandardMaterial color="#666" metalness={0.6} roughness={0.3} />
        </mesh>
      ))}
    </group>
  );
}



export function RangeHood({ position }) {
  return (
    <group position={position}>

      <Box position={[0, 0.55, 0]} size={[0.5, 0.9, 0.28]} color="#c8c8c8" metalness={0.5} roughness={0.25} />
     
      <mesh position={[0, 0.08, 0]}>
        <boxGeometry args={[0.7, 0.18, 0.42]} />
        <meshStandardMaterial color="#b5b5b5" metalness={0.55} roughness={0.2} />
      </mesh>

      <mesh position={[0, -0.02, 0.22]}>
        <planeGeometry args={[0.55, 0.04]} />
        <meshStandardMaterial emissive="#fff8e0" emissiveIntensity={1.5} color="#fffbe8" />
      </mesh>
    </group>
  );
}



export function HerbPot({ position, color = "#3a7a3a" }) {
  return (
    <group position={position}>
    
      <mesh position={[0, 0.07, 0]}>
        <cylinderGeometry args={[0.07, 0.055, 0.14, 10]} />
        <meshStandardMaterial color="#b05a2a" roughness={0.85} />
      </mesh>
    
      <mesh position={[0, 0.145, 0]}>
        <cylinderGeometry args={[0.068, 0.068, 0.01, 10]} />
        <meshStandardMaterial color="#2e1a0e" roughness={1} />
      </mesh>
    
      {[[-0.02, 0.02], [0.01, -0.01], [0.03, 0.03]].map(([x, z], i) => (
        <Box key={i} position={[x, 0.22 + i * 0.02, z]} size={[0.012, 0.12, 0.012]} color={color} />
      ))}
    </group>
  );
}


export function CounterProps({ position }) {
  return (
    <group position={position}>
   
      <mesh position={[0, 0.18, 0]}>
        <cylinderGeometry args={[0.04, 0.04, 0.28, 8]} />
        <meshStandardMaterial color="#c8a840" transparent opacity={0.75} roughness={0.1} metalness={0.05} />
      </mesh>
      <mesh position={[0, 0.34, 0]}>
        <cylinderGeometry args={[0.015, 0.032, 0.06, 8]} />
        <meshStandardMaterial color="#888" metalness={0.6} roughness={0.2} />
      </mesh>

     
      <mesh position={[0.18, 0.12, 0]}>
        <cylinderGeometry args={[0.055, 0.055, 0.2, 10]} />
        <meshStandardMaterial color="#c8e0c0" transparent opacity={0.6} roughness={0.15} />
      </mesh>
      <mesh position={[0.18, 0.225, 0]}>
        <cylinderGeometry args={[0.058, 0.058, 0.02, 10]} />
        <meshStandardMaterial color="#888" metalness={0.5} roughness={0.3} />
      </mesh>

      
      <mesh position={[-0.16, 0.1, 0]}>
        <cylinderGeometry args={[0.035, 0.035, 0.16, 8]} />
        <meshStandardMaterial color="#e8e0d0" roughness={0.5} />
      </mesh>
      <mesh position={[-0.16, 0.19, 0]}>
        <cylinderGeometry args={[0.038, 0.038, 0.018, 8]} />
        <meshStandardMaterial color="#c0392b" metalness={0.3} roughness={0.4} />
      </mesh>
    </group>
  );
}



export function WallClock({ position }) {
  return (
    <group position={position}>
     
      <mesh>
        <circleGeometry args={[0.18, 24]} />
        <meshStandardMaterial color="#f5f0e8" roughness={0.6} />
      </mesh>
     
      <mesh position={[0, 0, -0.01]}>
        <ringGeometry args={[0.17, 0.20, 24]} />
        <meshStandardMaterial color="#5a3e28" roughness={0.5} />
      </mesh>
      
      <Box position={[0, 0.06, 0.01]} size={[0.015, 0.10, 0.01]} color="#222" />
  
      <Box position={[0.04, 0.04, 0.015]} size={[0.01, 0.13, 0.008]}
           color="#222" rotation={[0, 0, -0.6]} />
     
      <mesh position={[0, 0, 0.02]}>
        <circleGeometry args={[0.015, 10]} />
        <meshStandardMaterial color="#c0392b" />
      </mesh>
    </group>
  );
}



export function PendantLight({ position, on = true }) {
  return (
    <group position={position}>
      <Box position={[0, 0.2, 0]} size={[0.01, 0.4, 0.01]} color="#333" />
      
      <mesh position={[0, -0.02, 0]}>
        <coneGeometry args={[0.18, 0.22, 14, 1, true]} />
        <meshStandardMaterial color="#d4a96a" side={2} roughness={0.7} />
      </mesh>
     
      <mesh position={[0, 0.09, 0]} rotation={[Math.PI, 0, 0]}>
        <circleGeometry args={[0.018, 10]} />
        <meshStandardMaterial color="#b08040" />
      </mesh>
     
      <mesh position={[0, -0.0, 0]}>
        <sphereGeometry args={[0.04, 8, 8]} />
        <meshStandardMaterial
          emissive={on ? "#ffe080" : "#000"}
          emissiveIntensity={on ? 2 : 0}
          color="#fffbe0"
        />
      </mesh>

      {on && (
        <pointLight
          position={[0, -0.1, 0]}
          color="#ffe4a0"
          intensity={0.8}
          distance={3.5}
          decay={2}
        />
      )}
    </group>
  );
}