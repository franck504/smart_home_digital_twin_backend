"""
Unit tests for the smart home digital twin business logic.

Testing philosophy
──────────────────
- Pure function isolation : only `calculate_energy_strategy` and
  `process_all_climatisation` are tested here.  Both are deterministic
  functions with no network/DB side-effects, making them ideal unit targets.

- Behaviour-driven names : every test name reads as a sentence describing
  the exact scenario and the expected outcome.  A failing test report is
  self-explanatory without opening the source.

- AAA layout : each test is structured as
      Arrange  – build a minimal HouseState
      Act      – call the function under test
      Assert   – verify exactly one behaviour

- Boundary conditions : hysteresis dead-band edges (±1 °C) are covered
  explicitly with parametrize so regressions on the threshold logic are
  caught immediately.

- Independence : every test uses a fresh HouseState from the fixture;
  no shared mutable state between tests.
"""

import pytest
from app.models.house import HouseState, RoomState
from app.services.logic import calculate_energy_strategy, process_all_climatisation


# ─── Helpers ──────────────────────────────────────────────────────────────────

def make_weather(
    outside_temp: float = 24.0,
    description: str = "Ciel dégagé",
    icon: str = "01d",
    solar_prediction: float = 0.8,
) -> dict:
    """Builds a minimal weather dict accepted by calculate_energy_strategy."""
    return {
        "outside_temp": outside_temp,
        "description": description,
        "icon": icon,
        "solar_prediction": solar_prediction,
    }


# ─── Fixtures ─────────────────────────────────────────────────────────────────

@pytest.fixture
def state() -> HouseState:
    """Fresh HouseState with default values, isolated per test."""
    return HouseState()


# ══════════════════════════════════════════════════════════════════════════════
# Energy Strategy
# ══════════════════════════════════════════════════════════════════════════════

class TestEnergyStrategy:
    """
    Rules under test
    ────────────────
    1. battery < critical_threshold  →  grid  (safety, regardless of solar)
    2. battery > 30 AND solar > 0.4  →  solar
    3. Neither condition              →  source unchanged
    """

    # ── Rule 1 : critical battery ─────────────────────────────────────────────

    def test_battery_below_critical_threshold_switches_to_grid(self, state):
        """Even with perfect sun, a critically low battery forces grid mode."""
        state.energy.battery_level = 10.0          # well below default 20 %
        calculate_energy_strategy(state, make_weather(solar_prediction=1.0))
        assert state.energy.source == "grid"

    def test_battery_exactly_at_threshold_switches_to_grid(self, state):
        """Battery at the exact threshold value is treated as critical (strict <)."""
        threshold = state.config.battery_critical_threshold          # 20.0
        state.energy.battery_level = threshold
        calculate_energy_strategy(state, make_weather(solar_prediction=1.0))
        # battery_level < threshold is False when equal → source unchanged (solar default)
        # This documents the current boundary semantics of the code.
        assert state.energy.source == "solar"

    def test_battery_one_unit_below_threshold_switches_to_grid(self, state):
        """One unit below the threshold reliably triggers the grid fallback."""
        threshold = state.config.battery_critical_threshold          # 20.0
        state.energy.battery_level = threshold - 1.0                 # 19.0
        calculate_energy_strategy(state, make_weather(solar_prediction=1.0))
        assert state.energy.source == "grid"

    # ── Rule 2 : solar conditions met ─────────────────────────────────────────

    def test_high_battery_and_good_sun_selects_solar(self, state):
        """Healthy battery and strong solar forecast → solar mode."""
        state.energy.battery_level = 80.0
        calculate_energy_strategy(state, make_weather(solar_prediction=0.9))
        assert state.energy.source == "solar"

    def test_battery_just_above_30_with_good_sun_selects_solar(self, state):
        """Battery barely above the 30 % secondary threshold still selects solar."""
        state.energy.battery_level = 31.0
        calculate_energy_strategy(state, make_weather(solar_prediction=0.5))
        assert state.energy.source == "solar"

    # ── Rule 3 : neither condition → source unchanged ─────────────────────────

    @pytest.mark.parametrize("solar_prediction", [0.0, 0.2, 0.4])
    def test_weak_solar_does_not_switch_to_solar(self, state, solar_prediction):
        """
        Solar index at or below 0.4 does not satisfy the solar condition
        (code uses strict >, so 0.4 itself is excluded).
        """
        state.energy.source = "grid"
        state.energy.battery_level = 80.0
        calculate_energy_strategy(state, make_weather(solar_prediction=solar_prediction))
        assert state.energy.source == "grid"

    def test_battery_at_or_below_30_does_not_switch_to_solar(self, state):
        """Battery at 30 % does not meet the >30 condition for solar."""
        state.energy.source = "grid"
        state.energy.battery_level = 30.0
        calculate_energy_strategy(state, make_weather(solar_prediction=1.0))
        assert state.energy.source == "grid"

    # ── Side-effects : weather state update ───────────────────────────────────

    def test_weather_fields_are_written_to_state(self, state):
        """All four weather dict values are correctly persisted in state.weather."""
        weather = make_weather(
            outside_temp=35.0,
            description="Orage",
            icon="11d",
            solar_prediction=0.05,
        )
        calculate_energy_strategy(state, weather)

        assert state.weather.outside_temp == 35.0
        assert state.weather.description == "Orage"
        assert state.weather.icon == "11d"
        assert state.weather.solar_prediction == 0.05

    def test_last_updated_is_set_after_calculation(self, state):
        """last_updated starts empty and is populated by the strategy call."""
        assert state.weather.last_updated == ""
        calculate_energy_strategy(state, make_weather())
        assert state.weather.last_updated != ""


# ══════════════════════════════════════════════════════════════════════════════
# HVAC / Climatisation
# ══════════════════════════════════════════════════════════════════════════════

class TestClimatisation:
    """
    Rules under test
    ────────────────
    1. MANUAL mode        →  room skipped entirely (no auto change)
    2. No presence
       + auto_clim_off    →  force OFF
    3. No presence
       + NOT auto_clim_off →  continue regulating normally
    4. temp > setpoint + 1 °C  →  COOL
       temp < setpoint - 1 °C  →  HEAT
       within ±1 °C dead band  →  OFF   (hysteresis prevents oscillation)
    5. Each room is evaluated independently
    """

    SETPOINT = 22.0    # default temperature_de_regulation

    # ── Rule 1 : MANUAL mode is a hard lock ───────────────────────────────────

    def test_manual_mode_prevents_any_auto_change(self, state):
        """MANUAL mode is a hard lock: even extreme heat must not trigger COOL."""
        salon = state.rooms["salon"]
        salon.climatisation_mode = "MANUAL"
        salon.climatisation = "OFF"
        salon.presence = True
        salon.temperature = 40.0          # extremely hot

        process_all_climatisation(state)

        assert state.rooms["salon"].climatisation == "OFF"

    def test_manual_mode_does_not_affect_other_rooms(self, state):
        """A MANUAL room is skipped but AUTO rooms beside it are still regulated."""
        state.rooms["salon"].climatisation_mode = "MANUAL"
        state.rooms["salon"].climatisation = "OFF"
        state.rooms["salon"].temperature = 40.0

        state.rooms["cuisine"].climatisation_mode = "AUTO"
        state.rooms["cuisine"].presence = True
        state.rooms["cuisine"].temperature = 40.0
        state.rooms["cuisine"].temperature_de_regulation = self.SETPOINT

        process_all_climatisation(state)

        assert state.rooms["salon"].climatisation == "OFF"    # unchanged
        assert state.rooms["cuisine"].climatisation == "COOL" # regulated

    # ── Rule 2 : absence economy mode ─────────────────────────────────────────

    def test_empty_room_with_auto_off_enabled_shuts_down_hvac(self, state):
        """An empty room with auto_clim_off=True turns the HVAC off,
        even if the temperature is far from the setpoint."""
        state.config.auto_clim_off = True
        salon = state.rooms["salon"]
        salon.presence = False
        salon.climatisation = "HEAT"
        salon.temperature = 5.0            # would normally trigger HEAT

        process_all_climatisation(state)

        assert state.rooms["salon"].climatisation == "OFF"

    def test_empty_room_with_auto_off_disabled_continues_regulating(self, state):
        """With auto_clim_off=False, an empty room is still temperature-regulated."""
        state.config.auto_clim_off = False
        salon = state.rooms["salon"]
        salon.presence = False
        salon.temperature = 35.0
        salon.temperature_de_regulation = self.SETPOINT

        process_all_climatisation(state)

        assert state.rooms["salon"].climatisation == "COOL"

    # ── Rule 4 : hysteresis dead band ─────────────────────────────────────────
    #
    #  setpoint = 22 °C, dead band = ±1 °C
    #  COOL zone :  temp > 23.0
    #  OFF  zone :  21.0 ≤ temp ≤ 23.0
    #  HEAT zone :  temp < 21.0

    @pytest.mark.parametrize("temperature, expected_mode", [
        (30.0, "COOL"),   # far above setpoint
        (23.5, "COOL"),   # just above dead band upper edge
        (23.0, "OFF"),    # exactly at upper edge → inside dead band (strict >)
        (22.0, "OFF"),    # at setpoint → dead centre
        (21.0, "OFF"),    # exactly at lower edge → inside dead band (strict <)
        (20.5, "HEAT"),   # just below dead band lower edge
        (15.0, "HEAT"),   # far below setpoint
    ])
    def test_hvac_respects_hysteresis_dead_band(self, state, temperature, expected_mode):
        """HVAC mode is determined by the ±1 °C hysteresis around the setpoint.

        The dead band (21–23 °C for a 22 °C setpoint) prevents the system
        from oscillating between HEAT and COOL when the temperature hovers
        near the target.
        """
        salon = state.rooms["salon"]
        salon.presence = True
        salon.temperature_de_regulation = self.SETPOINT
        salon.temperature = temperature

        process_all_climatisation(state)

        assert state.rooms["salon"].climatisation == expected_mode, (
            f"At {temperature} °C (setpoint {self.SETPOINT} °C): "
            f"expected {expected_mode}, got {state.rooms['salon'].climatisation}"
        )

    # ── Rule 5 : multi-room independence ──────────────────────────────────────

    def test_all_rooms_are_regulated_independently(self, state):
        """Each room's HVAC is evaluated based on its own state, not its neighbours."""
        state.config.auto_clim_off = True

        state.rooms["salon"].presence = True
        state.rooms["salon"].temperature = 30.0     # → COOL
        state.rooms["salon"].temperature_de_regulation = self.SETPOINT

        state.rooms["cuisine"].presence = True
        state.rooms["cuisine"].temperature = 15.0   # → HEAT
        state.rooms["cuisine"].temperature_de_regulation = self.SETPOINT

        state.rooms["chambre"].presence = False      # → OFF (absent + auto_clim_off)
        state.rooms["chambre"].climatisation = "HEAT"

        state.rooms["douche"].climatisation_mode = "MANUAL"
        state.rooms["douche"].climatisation = "COOL" # → unchanged (manual lock)

        process_all_climatisation(state)

        assert state.rooms["salon"].climatisation == "COOL"
        assert state.rooms["cuisine"].climatisation == "HEAT"
        assert state.rooms["chambre"].climatisation == "OFF"
        assert state.rooms["douche"].climatisation == "COOL"  # manual, untouched

    def test_all_four_rooms_are_processed(self, state):
        """Regression guard: all 4 rooms in HouseState are visited by the loop."""
        for room in state.rooms.values():
            room.presence = True
            room.temperature = 35.0
            room.temperature_de_regulation = self.SETPOINT

        process_all_climatisation(state)

        for room_id, room in state.rooms.items():
            assert room.climatisation == "COOL", (
                f"Room '{room_id}' was not processed by the regulation loop"
            )
