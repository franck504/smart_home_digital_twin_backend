import { OrbitControls } from '@react-three/drei'
import { Canvas } from '@react-three/fiber'
import React from 'react'
import HouseScene from './HouseScene'

const Scene = () => {
  return (
    <div style={{ position: "relative", width: "100%", height: "100%" }}>
    <Canvas
      shadows
      camera={{ position: [0, 4, 10], fov: 65 }}
      style={{ width: "100%", height: "100%", display: "block", background: "#0d0f14" }}
    >
     
      <OrbitControls
        enablePan
        minDistance={3}
        maxDistance={22}
        maxPolarAngle={Math.PI / 2 - 0.05}
      />
      <HouseScene />
    </Canvas>
  </div>
  )
}

export default Scene