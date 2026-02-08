# Kossel Delta Printer - Klipper Configuration

This repository contains the complete Klipper configuration for a Kossel 3D delta printer running on a Smoothieboard (LPC176x) with Mainsail interface.

## Hardware Configuration

- **Printer**: Kossel 3D Delta Printer
- **Controller**: MKS SBASE v1.3 (uses LPC176x) - [MKS SBASE GitHub](https://github.com/makerbase-mks/MKS-SBASE)

![SBASE Pin-out](docs/MKS%20SBASE%20V1.3_002%20PIN.png)
- **Kinematics**: Delta
- **Build Area**: 110mm radius
- **Hotend**: Standard 0.4mm nozzle
- **Bed**: Heated bed with Honeywell thermistor
- **Extruder**: 1.75mm filament, 22.73mm rotation distance
- **Display**: RepRapDiscount 128x64 Full Graphic Smart Controller (ST7920)
- **Probe**: Z-probe with auto-bed leveling
- **Accelerometer**: FLY-ADXL345 USB for resonance testing

## Configuration Files

### `printer.cfg`
Main configuration file containing:
- Delta kinematics setup
- Stepper motor configuration (A, B, C towers + extruder)
- Hotend and heated bed configuration
- Probe settings for auto-bed leveling
- Input shaping for vibration reduction
- Display configuration
- Current control via MCP4451 digipots

### `accelerometer.cfg`
Accelerometer configuration for resonance testing:
- FLY-ADXL345 USB accelerometer setup
- Resonance testing configuration
- Reference: [Mellow USB Accelerometer ADXL345 Documentation](https://mellow.klipper.cn/en/docs/category/usb%E5%8A%A0%E9%80%9F%E5%BA%A6%E8%AE%A1adxl345)



## Key Settings

### Delta Configuration
- **Delta Radius**: 103.13mm (auto-calibrated)
- **Arm Length**: 208.1mm
- **Print Radius**: 110mm
- **Max Velocity**: 200mm/s
- **Max Acceleration**: 10000mm/s²

### Input Shaping
- **Type**: EI (Exponential Input)
- **Frequency**: 38Hz (X and Y axes)

## Using The Accelerometer (Resonance Testing)

The accelerometer is not always connected. In `printer.cfg` the include for `accelerometer.cfg` is intentionally commented out.

Enable it when the sensor is plugged in:
1. Connect the USB accelerometer
2. Edit `printer.cfg` and uncomment the line:
   - `# [include accelerometer.cfg]`
3. Restart Klipper

Verify the sensor is working:
```gcode
ACCELEROMETER_QUERY
```

Measure baseline noise:
```gcode
MEASURE_AXES_NOISE
```

Run resonance tests (example):
```gcode
TEST_RESONANCES AXIS=X
TEST_RESONANCES AXIS=Y
```

Generate new input shaper values:
```gcode
SHAPER_CALIBRATE
SAVE_CONFIG
```

Disable it again when done (so Klipper will start without the sensor):
- Re-comment the `include accelerometer.cfg` line in `printer.cfg`
- Restart Klipper

### Probe Settings
- **Z Offset**: 24.5mm
- **Speed**: 5mm/s
- **Samples**: 5 (median result)

### Extruder
- **Pressure Advance**: 0.32
- **Smooth Time**: 0.04s
- **Nozzle Diameter**: 0.4mm
- **Filament Diameter**: 1.75mm

## Probe Z-Offset Calibration

To calibrate the probe Z-offset:

1. **Home the printer**:
   ```
   G28
   ```

2. **Move to center of build area**:
   ```
   G0 X0 Y0 Z30
   ```

3. **Test probe deployment**:
   ```
   QUERY_PROBE
   ```

4. **Perform manual Z-offset calibration**:
   ```
   PROBE_CALIBRATE
   ```
   - Follow the on-screen prompts
   - Use a piece of paper to test nozzle-to-bed distance
   - Adjust until you feel slight drag when moving paper

5. **Save the new Z-offset**:
   ```
   SAVE_CONFIG
   ```

6. **Verify the setting**:
   ```
   GET_PROBE
   ```

**Current Z-offset**: 24.5mm (can be updated after calibration)

## Maintenance

- Run `DELTA_CALIBRATE` command if tower positions change
- Use `TEST_RESONANCES` with accelerometer for input shaping updates
- Re-tune PID values if temperature control issues occur
- Update probe Z-offset if bed leveling accuracy degrades

## Filament Runout

This config has filament runout detection enabled. When a runout is detected, Klipper will execute `PAUSE`.

What happens on runout:
- The print pauses
- The toolhead parks (this config customizes the Mainsail PAUSE behavior to park at `X0 Y0` with a small Z lift)

To recover:
1. Replace/load filament (and make sure it is actually feeding)
2. Heat the hotend if needed
3. Purge a little filament and clean the nozzle
4. In Mainsail, click `RESUME` (or run `RESUME` from the console)

Notes:
- Runout sensors are defined in `printer.cfg` as `filament_switch_sensor filament_runout` and `filament_motion_sensor filament_motion` (either can trigger a pause).
- `RESUME` is configured to check the runout sensor set in `_CLIENT_VARIABLE.variable_runout_sensor` and will refuse to resume if it still reports "no filament".

## License

Licensed under the MIT License - see [`LICENSE`](LICENSE).
