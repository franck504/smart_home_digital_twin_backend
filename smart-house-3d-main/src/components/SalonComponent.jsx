import { Box } from "./HouseComponent";

export function Sofa({ position }) {
  return (
    <group position={position}>
      <Box position={[0, 0.2,   0]}    size={[1.6, 0.3,  0.7]}  color="#7a6652" />
      <Box position={[0, 0.55, -0.3]}  size={[1.6, 0.45, 0.12]} color="#6b5847" />
      <Box position={[-0.76, 0.38, 0]} size={[0.12, 0.35, 0.7]} color="#6b5847" />
      <Box position={[ 0.76, 0.38, 0]} size={[0.12, 0.35, 0.7]} color="#6b5847" />
    </group>
  );
}

export function CoffeeTable({ position }) {
  const legs = [[-0.33, -0.16], [0.33, -0.16], [-0.33, 0.16], [0.33, 0.16]];
  return (
    <group position={position}>
      <Box position={[0, 0.22, 0]} size={[0.8, 0.06, 0.45]} color="#a0784a" roughness={0.4} metalness={0.1} />
      {legs.map(([x, z], i) => (
        <Box key={i} position={[x, 0.1, z]} size={[0.06, 0.2, 0.06]} color="#7a5c30" roughness={0.5} />
      ))}
    </group>
  );
}

export function TV({ position }) {
  return (
    <group position={position} rotation={[0, Math.PI, 0]}>
      <Box position={[0, 0.8, 0]}     size={[1.1, 0.65, 0.06]}  color="#111" metalness={0.3} roughness={0.4} />
      <mesh position={[0, 0.8, 0.032]}>
        <planeGeometry args={[1.0, 0.58]} />
        <meshStandardMaterial color="#0a1a2f" emissive="#061020" emissiveIntensity={0.5} />
      </mesh>
      <Box position={[0, 0.44, 0]}    size={[0.08, 0.08, 0.08]} color="#222" />
      <Box position={[0, 0.4,  0.04]} size={[0.3,  0.04, 0.18]} color="#1a1a1a" />
    </group>
  );
}

export function Rug({ position }) {
  return (
    <mesh position={position} rotation={[-Math.PI / 2, 0, 0]} receiveShadow>
      <planeGeometry args={[2.2, 1.4]} />
      <meshStandardMaterial color="#8b4a2f" roughness={1} />
    </mesh>
  );
}

export function FloorLamp({ position }) {
  return (
    <group position={position}>

      <Box position={[0, 0.75, 0]} size={[0.04, 1.5, 0.04]} color="#b0a090" metalness={0.4} roughness={0.5} />

      <Box position={[0, 0.02, 0]} size={[0.18, 0.04, 0.18]} color="#b0a090" metalness={0.4} roughness={0.5} />
  
      <mesh position={[0, 1.55, 0]}>
        <coneGeometry args={[0.2, 0.3, 12, 1, true]} />
        <meshStandardMaterial color="#e8d8b0" side={2} roughness={0.8} />
      </mesh>
 
      <mesh position={[0, 1.52, 0]}>
        <sphereGeometry args={[0.04, 8, 8]} />
        <meshStandardMaterial emissive="#ffe8a0" emissiveIntensity={2} color="#fffbe0" />
      </mesh>
    </group>
  );
}

export function Bookshelf({ position }) {
  const shelves = [0.25, 0.6, 0.95];
  return (
    <group position={position}>
    
      <Box position={[0, 0.65, 0]}    size={[1.0, 1.3, 0.28]} color="#7a5c30" roughness={0.6} />
   
      {shelves.map((y, i) => (
        <Box key={i} position={[0, y, 0.01]} size={[0.96, 0.04, 0.26]} color="#9a7840" roughness={0.5} />
      ))}
   
      {[-0.3, -0.15, 0.0, 0.15, 0.3].map((x, i) => (
        <Box key={i} position={[x, 0.41, 0.01]}
          size={[0.1, 0.28, 0.18]}
          color={["#c0392b","#2980b9","#27ae60","#e67e22","#8e44ad"][i]}
          roughness={0.9}
        />
      ))}
    
      {[-0.25, -0.05, 0.15].map((x, i) => (
        <Box key={i} position={[x, 0.76, 0.01]}
          size={[0.12, 0.26, 0.18]}
          color={["#16a085","#d35400","#2c3e50"][i]}
          roughness={0.9}
        />
      ))}
    </group>
  );
}
