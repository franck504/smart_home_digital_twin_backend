import { useRef } from "react";
import { useFrame } from "@react-three/fiber";

export default function Bulb({ position, on }) {

  const glowRef = useRef();

  const color    = on ? "#ffe57a" : "#2a2a2a";
  const emissive = on ? "#ffcc00" : "#000000";

  useFrame(({ clock }) => {
    if (on && glowRef.current) {
      glowRef.current.intensity =
        1.8 + Math.sin(clock.getElapsedTime() * 3) * 0.15;
    }
  });

  return (
    <group position={position}>
      <mesh position={[0, 0.12, 0]}>
        <cylinderGeometry args={[0.008, 0.008, 0.22, 6]} />
        <meshStandardMaterial color="#555" />
      </mesh>
      <mesh position={[0, 0, 0]}>
        <cylinderGeometry args={[0.045, 0.045, 0.06, 12]} />
        <meshStandardMaterial color="#888" metalness={0.8} roughness={0.3} />
      </mesh>

      <mesh position={[0, -0.085, 0]}>
        <sphereGeometry args={[0.07, 16, 16]} />
        <meshStandardMaterial
          color={color}
          emissive={emissive}
          emissiveIntensity={on ? 1.2 : 0}
          transparent
          opacity={on ? 0.92 : 0.55}
          roughness={0.1}
          metalness={0.0}
        />
      </mesh>
      {on && (
        <pointLight
          ref={glowRef}
          position={[0, -0.1, 0]}
          intensity={1.8}
          distance={4}
          color="#ffe57a"
          castShadow
        />
      )}
    </group>
  );
}