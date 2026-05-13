import { Wall } from "./HouseComponent";



export default function Divider() {
  return (
    <>
    <group position={[-0.5, 0, 0]}>
      <Wall position={[0, 1.5, -1.5]}       size={[0.15, 3, 2]}  color="#c8bfb0" />
      <Wall position={[0, 1.5,1.5]} size={[0.15, 3, 2]}  color="#c8bfb0" />
      <Wall position={[0, 2.55, 0]} size={[0.15, 0.5, 1]} color="#c8bfb0" />
      </group>
    </>
  );
}