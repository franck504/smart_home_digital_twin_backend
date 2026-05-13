import Salon from './Salon'
import Divider from './Divider'
import Cuisine from './Cuisine'
import { AirConditioner } from './AirConditionner'
import { useHouseData } from '../hooks/useHouseData'

const STATE_COLORS = {
    OFF:  { color: "#000000", density: 0 },
    COOL: { color: "#00aaff", density: 0.03 },
    HEAT: { color: "#ff5500", density: 0.03 },
};

const HouseScene = () => {
    const data = useHouseData();

    const climatisationSalon   = data?.rooms?.salon?.climatisation   ?? "OFF";
    const climatisationCuisine = data?.rooms?.cuisine?.climatisation ?? "OFF";

    const fogSalon   = STATE_COLORS[climatisationSalon]   || STATE_COLORS.OFF;
    const fogCuisine = STATE_COLORS[climatisationCuisine] || STATE_COLORS.OFF;

    return (
        <>
          

            <Salon fogConfig={fogSalon}/>
            <Divider/>
            <Cuisine fogConfig={fogCuisine}/>
            {/* prop room="salon" pour lire data.rooms.salon.climatisation */}
            <AirConditioner position={[-2.9, 2.5, -2.3]} room="salon" />
            <AirConditioner position={[3.5, 2.5, -2.3]} room="cuisine" />
        </>
    )
}

export default HouseScene
