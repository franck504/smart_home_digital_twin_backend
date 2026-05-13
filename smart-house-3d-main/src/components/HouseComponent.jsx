
export function Box({ position, size, color, metalness = 0, roughness = 0.8 }) {
    return (
      <mesh position={position} castShadow receiveShadow>
        <boxGeometry args={size} />
        <meshStandardMaterial color={color} metalness={metalness} roughness={roughness} />
      </mesh>
    );
  }
  
  export function Wall({ position, size, rotation = [0, 0, 0], color = "#d6cfc4" }) {
    return (
      <mesh position={position} rotation={rotation} receiveShadow castShadow>
        <boxGeometry args={size} />
        <meshStandardMaterial color={color} roughness={0.9} />
      </mesh>
    );
  }
  
  export function Floor({ position, size, color }) {
    return (
      <mesh position={position} receiveShadow rotation={[-Math.PI / 2, 0, 0]}>
        <planeGeometry args={size} />
        <meshStandardMaterial color={color} roughness={0.85} />
      </mesh>
    );
  }