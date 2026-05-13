
const RoomFog = ({ color, active, position, size = [5, 3, 5] }) => {
    if (!active) return null;
    return (
        <mesh position={position}>
            <boxGeometry args={size} />
            <meshStandardMaterial
                color={color}
                transparent
                opacity={0.08}
                depthWrite={false}
            />
        </mesh>
    );
};

export default RoomFog;