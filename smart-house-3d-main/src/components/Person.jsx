// Person.jsx
import { useRef } from 'react'
import { useFrame } from '@react-three/fiber'

const Person = ({ position = [0, 0, 0] }) => {
    const groupRef = useRef();

    // légère animation de respiration
    useFrame((state) => {
        if (groupRef.current) {
            groupRef.current.position.y =
                position[1] + Math.sin(state.clock.elapsedTime * 1.5) * 0.01;
        }
    });

    return (
        <group ref={groupRef} position={position}>
            {/* Tête */}
            <mesh position={[0, 1.65, 0]}>
                <sphereGeometry args={[0.15, 16, 16]} />
                <meshStandardMaterial color="#f5cba7" />
            </mesh>

            {/* Corps */}
            <mesh position={[0, 1.2, 0]}>
                <boxGeometry args={[0.35, 0.55, 0.2]} />
                <meshStandardMaterial color="#3498db" />
            </mesh>

            {/* Bras gauche */}
            <mesh position={[-0.28, 1.2, 0]} rotation={[0, 0, -0.3]}>
                <boxGeometry args={[0.12, 0.45, 0.12]} />
                <meshStandardMaterial color="#3498db" />
            </mesh>

            {/* Bras droit */}
            <mesh position={[0.28, 1.2, 0]} rotation={[0, 0, 0.3]}>
                <boxGeometry args={[0.12, 0.45, 0.12]} />
                <meshStandardMaterial color="#3498db" />
            </mesh>

            {/* Jambe gauche */}
            <mesh position={[-0.1, 0.7, 0]}>
                <boxGeometry args={[0.13, 0.45, 0.15]} />
                <meshStandardMaterial color="#2c3e50" />
            </mesh>

            {/* Jambe droite */}
            <mesh position={[0.1, 0.7, 0]}>
                <boxGeometry args={[0.13, 0.45, 0.15]} />
                <meshStandardMaterial color="#2c3e50" />
            </mesh>
        </group>
    );
};

export default Person;