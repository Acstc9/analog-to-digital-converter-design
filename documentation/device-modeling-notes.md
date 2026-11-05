# Device Modeling Notes

These notes describe the physical assumptions and component responsibilities of the SAR ADC model. The converter remains ideal; no mismatch, noise, settling or transistor behavior is implemented.

## Components and control

[cbwSarADC](../models/cbwSarADC.m) is the complete converter model. It builds one device and reads a column of input voltages. It samples each voltage onto the CDAC, completes all bit decisions and stores the final 0/1 switch positions as one MSB-first row of binaryCodes before reading the next voltage. Its loops express the control sequence; there is no separate clocked hardware state machine.

| Operation | Implementation | Physical meaning |
|---|---|---|
| Build the CDAC | [synthesizeBinaryCDAC](../function/cdac-topologies/synthesizeBinaryCDAC.m), [cbwSarADC](../models/cbwSarADC.m) | Generate binary weights including the unit dummy, then multiply by the unit capacitance to obtain branch capacitances in fF |
| Read a sample | [cbwSarADC](../models/cbwSarADC.m) | Hold the next input voltage constant throughout its bit decisions |
| Set switch positions | [cbwSarADC](../models/cbwSarADC.m) | Clear all positions to 0, trial each bit at 1, then retain or revert it |
| Calculate the CDAC output | [binaryCDAC](../function/binaryCDAC.m) | Compute sampled charge and bottom-plate voltages from the input and switch positions, then return the floating top-node voltage as cdacOutputVolts |
| Decide a bit | [cbwSarADC](../models/cbwSarADC.m) | Directly retain the trial when comparator reference >= top-plate voltage |

## Charge and voltage

The low reference is ground. The model uses a nominal 1 V reference (`p.vRef`), so default signal voltages also give their numerical fractions of full scale. The sine is centered at `p.vCM = p.vRef / 2`.

During sampling, total top-plate charge is `Q = Ctotal * (0 - Vin)`. Its negative sign for positive input describes charge on the top node; it is not an invalid state. Capacitances are in fF and charge in fC, so fF times volts gives fC directly.

After releasing the top clamp, the solver uses `Vtop = (Q + sum(C .* Vbottom)) / Ctotal`. It receives the capacitor array, p, one input voltage and a row of MSB-first 0/1 switch positions. Each position connects a decision capacitor to ground or p.vRef. A final zero bottom-plate voltage keeps the dummy grounded. Switching changes individual capacitor charges while preserving their total at the isolated common top node. The same sampled charge is computed from the unchanged input for each trial. No common-mode voltage is added to the top-plate result.

The model first clears every switch position to 0. It then trials the MSB at 1, solves the node voltage and compares it. A kept trial leaves that switch position at 1. A rejected trial returns the switch position to 0. The next trial solves the voltage using all updated positions; no intermediate voltage calculation is needed. The same sequence continues down to the LSB. The final switch positions are the output bits; no separate integer code is assembled inside the model.

## Half-LSB transition convention

The configuration creates an ideal comparator-reference voltage equal to half the nominal LSB above the 0 V sampling clamp. This intentional bias implements the selected half-LSB transition convention; it is not random comparator offset and is not produced automatically by the CDAC. The direct comparator accepts equality. At the reference endpoints the finite code range saturates.

The ADC returns digital bits only, as a sample-by-bit double matrix. In the testbench, [idealDAC](../function/data-processing/idealDAC.m) decodes each row using bi2de with left-msb ordering and interprets the resulting integer as `code * nominalLSB`, with `nominalLSB = p.vRef / 2^p.resolutionBits`. This analysis decoder is separate from the physical binaryCDAC voltage calculation. [processAdcData](../function/data-processing/processAdcData.m) receives the decoded voltage column.

## Boundaries

Sample index n represents the ideal sampling instant n/Fs. No acquisition duration or per-bit delay is modeled, so changing Fs does not establish achievable circuit speed. The internal top node may go below 0 V; supply rails and comparator common-mode restrictions are not included. Using fF/fC improves numerical conditioning for the selected array but does not make all floating-point operations exact.

The explicit bias, topology and unit-capacitance value are project choices. See the [reference index](../literature/README.md) for the ADI transfer convention and charge-redistribution source.
