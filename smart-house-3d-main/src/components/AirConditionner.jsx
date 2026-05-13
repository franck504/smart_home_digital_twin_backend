import { useRef } from "react";
import { useFrame } from "@react-three/fiber";
import { Text } from "@react-three/drei";
import { useHouseData } from "../hooks/useHouseData";
import { Box } from "./HouseComponent";

const STATE_CFG = {
  OFF:  { ledColor: "#1a2a3a", ledEmissive: "#000000", intensity: 0,   screenColor: "#0a1520", screenEmissive: "#0a1520" },
  COOL: { ledColor: "#00cfff", ledEmissive: "#00cfff", intensity: 3.0, screenColor: "#00cfff", screenEmissive: "#003d5c" },
  HEAT: { ledColor: "#ff6a00", ledEmissive: "#ff4400", intensity: 3.0, screenColor: "#ff6a00", screenEmissive: "#5c1a00" },
};

export function AirConditioner({ position, rotation = [0, 0, 0], room = "salon" }) {
  const data          = useHouseData();
  const roomData      = data?.rooms?.[room];
  const climatisation = roomData?.climatisation ?? "OFF";
  const temperature   = roomData?.temperature   ?? 22.0;
  const tempRegul     = roomData?.temperature_de_regulation ?? 22.0;
  const on            = climatisation !== "OFF";

  const ledRef      = useRef();
  const screenBgRef = useRef();
  const timeRef     = useRef(0);

  useFrame((_, delta) => {
    const cfg = STATE_CFG[climatisation] ?? STATE_CFG.OFF;
    timeRef.current += delta;

    if (ledRef.current) {
      if (!on) {
        ledRef.current.emissiveIntensity = 0;
        ledRef.current.color.set(cfg.ledColor);
        ledRef.current.emissive.set("#000");
      } else {
        const pulse = cfg.intensity * (0.75 + 0.25 * Math.sin(timeRef.current * 2.5));
        ledRef.current.emissiveIntensity = pulse;
        ledRef.current.color.set(cfg.ledColor);
        ledRef.current.emissive.set(cfg.ledEmissive);
      }
    }

    if (screenBgRef.current) {
      if (!on) {
        screenBgRef.current.emissiveIntensity = 0.04;
        screenBgRef.current.color.set("#050e18");
        screenBgRef.current.emissive.set("#050e18");
      } else {
        const flicker = 0.12 + 0.02 * Math.sin(timeRef.current * 8.0);
        screenBgRef.current.emissiveIntensity = flicker;
        screenBgRef.current.color.set(cfg.screenEmissive);
        screenBgRef.current.emissive.set(cfg.screenEmissive);
      }
    }
  });

  const cfg       = STATE_CFG[climatisation] ?? STATE_CFG.OFF;
  const textColor = on ? cfg.ledColor : "#2a3a4a";

  // Quand OFF : température actuelle seulement (grande)
  // Quand ON  : température de régulation grande, température actuelle petite en dessous
  const regulDisplay = `${tempRegul.toFixed(1)}°`;
  const tempDisplay  = `${temperature.toFixed(1)}°`;
  const modeLabel    = on ? (climatisation === "HEAT" ? "HEAT" : "COOL") : "OFF";

  return (
    <group position={position} rotation={rotation} scale={[1.8, 1.8, 1.8]}>
      {/* Corps principal */}
      <Box position={[0, 0, -0.01]} size={[0.94, 0.28, 0.22]} color="#dedad5" roughness={0.45} metalness={0.05} />

      {/* Face avant */}
      <mesh position={[0, 0, 0.1]}>
        <boxGeometry args={[0.92, 0.26, 0.005]} />
        <meshStandardMaterial color="#eeebe6" roughness={0.35} metalness={0.08} />
      </mesh>

      {/* Ligne supérieure */}
      <mesh position={[0, 0.12, 0.104]}>
        <boxGeometry args={[0.90, 0.004, 0.004]} />
        <meshStandardMaterial color="#c8c4be" roughness={0.3} />
      </mesh>

      {/* Lamelles de ventilation */}
      {[-0.075, -0.035, 0.005, 0.045, 0.08].map((y, i) => (
        <mesh key={i} position={[-0.12, y, 0.108]}>
          <boxGeometry args={[0.48, 0.011, 0.018]} />
          <meshStandardMaterial color="#c5c1bb" roughness={0.5} />
        </mesh>
      ))}

      {/* Grille basse */}
      <mesh position={[-0.12, -0.095, 0.106]}>
        <boxGeometry args={[0.48, 0.006, 0.01]} />
        <meshStandardMaterial color="#b0aca6" roughness={0.8} />
      </mesh>

      {/* Volet bas */}
      <mesh
        position={[-0., -0.117, 0.092]}
        rotation={on ? [0.5, 0, 0] : [-0, 0, 0]}
      >
        <boxGeometry args={[0.80, 0.016, 0.09]} />
        <meshStandardMaterial color="#dedad4" roughness={0.4} />
      </mesh>

      {/* Écran fond sombre */}
      <mesh position={[0.285, 0.012, 0.102]}>
        <boxGeometry args={[0.275, 0.19, 0.008]} />
        <meshStandardMaterial color="#1a2530" roughness={0.2} metalness={0.3} />
      </mesh>

      {/* Écran actif */}
      <mesh position={[0.285, 0.012, 0.107]}>
        <boxGeometry args={[0.255, 0.17, 0.002]} />
        <meshStandardMaterial
          ref={screenBgRef}
          color="#050e18"
          emissive="#050e18"
          emissiveIntensity={0.04}
          roughness={0.05}
          metalness={0.1}
        />
      </mesh>

      {/* Reflet écran */}
      <mesh position={[0.285, 0.018, 0.1085]}>
        <boxGeometry args={[0.255, 0.17, 0.001]} />
        <meshStandardMaterial
          color="#ffffff"
          transparent
          opacity={0.04}
          roughness={0}
          metalness={0.8}
        />
      </mesh>

      {/* ── AFFICHAGE ÉCRAN ── */}
      {!on ? (
        // OFF : température actuelle centrée, grande
        <group position={[0.285, 0.012, 0.112]}>
          <Text
            fontSize={0.072}
            color="#2a3a4a"
            anchorX="center"
            anchorY="middle"
            letterSpacing={0.03}
          >
            {tempDisplay}
          </Text>
        </group>
      ) : (
        <>
          {/* ON : température de régulation — grande, en haut */}
          <group position={[0.285, 0.042, 0.112]}>
            <Text
              fontSize={0.080}
              color={textColor}
              anchorX="center"
              anchorY="middle"
              letterSpacing={0.03}
            >
              {regulDisplay}
            </Text>
          </group>

          {/* ON : température actuelle — petite, en dessous */}
          <group position={[0.285, -0.022, 0.112]}>
            <Text
              fontSize={0.036}
              color={textColor}
              anchorX="center"
              anchorY="middle"
              letterSpacing={0.02}
            >
              {`${tempDisplay}`}
            </Text>
          </group>

          {/* Mode HEAT / COOL */}
          <group position={[0.285, -0.062, 0.112]}>
            <Text
              fontSize={0.028}
              color={textColor}
              anchorX="center"
              anchorY="middle"
              letterSpacing={0.12}
            >
              {modeLabel}
            </Text>
          </group>

          {/* Ligne déco sous le mode */}
          <mesh position={[0.285, -0.078, 0.111]}>
            <boxGeometry args={[0.06, 0.003, 0.001]} />
            <meshStandardMaterial
              color={cfg.ledColor}
              emissive={cfg.ledEmissive}
              emissiveIntensity={1.2}
            />
          </mesh>
        </>
      )}

      {/* Boutons droite */}
      {[0.06, 0.01, -0.04].map((y, i) => (
        <mesh key={i} position={[0.424, y, 0.106]}>
          <circleGeometry args={[0.013, 12]} />
          <meshStandardMaterial color="#2a3540" roughness={0.3} metalness={0.5} />
        </mesh>
      ))}

      {/* Halo LED */}
      {on && (
        <mesh position={[0.424, -0.075, 0.1075]}>
          <circleGeometry args={[0.022, 20]} />
          <meshStandardMaterial
            color={cfg.ledColor}
            emissive={cfg.ledEmissive}
            emissiveIntensity={0.6}
            transparent
            opacity={0.35}
          />
        </mesh>
      )}

      {/* LED principale */}
      <mesh position={[0.424, -0.075, 0.109]}>
        <circleGeometry args={[0.013, 20]} />
        <meshStandardMaterial
          ref={ledRef}
          color={cfg.ledColor}
          emissive={cfg.ledEmissive}
          emissiveIntensity={on ? cfg.intensity : 0}
          roughness={0.0}
          metalness={0.2}
        />
      </mesh>

      {/* Côtés */}
      {[-1, 1].map((side, i) => (
        <mesh key={i} position={[side * 0.455, 0, 0.038]}>
          <boxGeometry args={[0.018, 0.24, 0.16]} />
          <meshStandardMaterial color="#d8d4ce" roughness={0.5} metalness={0.05} />
        </mesh>
      ))}

      {[-1, 1].map((side, i) => (
        <mesh key={i} position={[side * 0.453, 0, 0.108]}>
          <boxGeometry args={[0.012, 0.24, 0.005]} />
          <meshStandardMaterial color="#ccc8c2" roughness={0.4} />
        </mesh>
      ))}
    </group>
  );
}