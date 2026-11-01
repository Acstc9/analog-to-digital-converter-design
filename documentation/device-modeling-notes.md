# Device Modeling Notes

These notes collect the physical model decisions already discussed during the rebuild. The converter remains ideal; no mismatch, noise, settling or transistor behavior is implemented.

## Components and control

[cbwSarADC](../models/cbwSarADC.m) is the complete converter model. It builds one device, samples one input value, completes all bit decisions and stores its digital code before taking the next sample. Its loops express the control sequence; there is no separate clocked hardware state machine.

| Operation | Implementation | Physical meaning |
|---|---|---|
| Create the CDAC | [synthesizeBinaryCDAC](../function/cdac-topologies/synthesizeBinaryCDAC.m) | Binary-weighted parallel groups of identical units, plus one unit dummy |
| Capture a sample | [sampleInputOntoCDAC](../function/sampleInputOntoCDAC.m) | Top plate clamped to 0 V, bottom plates connected to the input |
| Switch bottom plates | [cbwSarADC](../models/cbwSarADC.m) | First all low, then trial each bit high; retain or revert it |
| Solve the floating node | [calculateTopPlateVoltage](../function/calculateTopPlateVoltage.m) | Conserve total top-node charge after switching |
| Decide a bit | [compareVoltages](../function/compareVoltages.m) | Retain the trial when comparator reference >= top-plate voltage |

## Charge and voltage

During sampling, total top-plate charge is `Q = Ctotal * (0 - Vin)`. Its negative sign for positive input describes charge on the top node; it is not an invalid state. Capacitances are in fF and charge in fC, so fF times volts gives fC directly.

After releasing the top clamp, the solver uses `Vtop = (Q + sum(C .* Vbottom)) / Ctotal`. Switching changes individual capacitor charges while preserving their total at the isolated common top node. The dummy remains connected to the low reference during conversion.

The model first switches every bottom plate to the low reference. It then trials the MSB, solves the node voltage and compares it. A kept trial leaves that branch high and sets the corresponding register bit. A rejected trial returns the branch low and recalculates the node voltage. The same sequence continues down to the LSB.

## Half-LSB transition convention

The configuration creates an ideal comparator-reference voltage equal to half the nominal LSB above the 0 V sampling clamp. This intentional bias implements the selected half-LSB transition convention; it is not random comparator offset and is not produced automatically by the CDAC. The direct comparator accepts equality. At the reference endpoints the finite code range saturates.

The ADC output is a digital code only. [processAdcData](../function/data-processing/processAdcData.m) interprets it as `referenceLowVolts + code * nominalLSB` for analysis. This nominal voltage is a code interpretation, not an extra analog output or recovery of the exact original input.

## Boundaries

The sampling time is n/Fs. No acquisition duration or per-bit delay is modeled, so changing Fs does not establish achievable circuit speed. The internal top node may go below 0 V; supply rails and comparator common-mode restrictions are not included. Using fF/fC improves numerical conditioning for the selected array but does not make all floating-point operations exact.

The explicit bias, topology and unit-capacitance value are project choices. See the [reference index](../literature/README.md) for the ADI transfer convention and charge-redistribution source.
