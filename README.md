# Analog-to-Digital Converter Design

A single-ended SAR ADC model in MATLAB, with a selectable binary-weighted or bridge charge-redistribution CDAC, static capacitor mismatch and periodic-Hann FFT analysis. The array includes a unit dummy capacitor and an explicit half-LSB comparator-reference bias. Thermal noise, settling and transistor behavior are not modeled.

## Run

Requires MATLAB, Communications Toolbox, Statistics and Machine Learning Toolbox (`normrnd`), and Richard Schreier's Delta Sigma Toolbox. Verified with MATLAB R2026a.

1. Add `sim-config`, `models`, `function` and `testbench`, including their subfolders, to the MATLAB path.
2. Edit [createSimulationConfiguration.m](sim-config/createSimulationConfiguration.m) to set converter and test parameters. Select `p.cdacType = "binary"` or `"bridge"`; the bridge split uses `p.msbBitCount` and `p.lsbBitCount`.
3. Open [simConventionalSarADC.m](testbench/simConventionalSarADC.m) and click **Run**. The script displays the spectrum, SNDR and ENOB and keeps the output bits and analysis results in the workspace.

The testbench draws one capacitor array per run, holds it fixed throughout conversion, then analyzes the complete record. Normal runs do not save files automatically or reset the random generator.

## Main functions

- [cbwSarADC.m](models/cbwSarADC.m): converts one input voltage through successive bit trials and returns one MSB-first binary code.
- [synthesizeCDAC.m](function/cdac-topologies/synthesizeCDAC.m): generates capacitor weights with independent Gaussian mismatch for the selected topology.
- [binaryCDAC.m](function/binaryCDAC.m) and [bridgeCDAC.m](function/bridgeCDAC.m): calculate the selected CDAC output voltage from capacitor values, the input sample and switch positions.
- [idealDAC.m](function/data-processing/idealDAC.m): decodes output bits into nominal voltages for analysis.
- [processAdcData.m](function/data-processing/processAdcData.m): returns the complex single-sided spectrum, its magnitude in dBFS, SNDR and ENOB.
- [plotFrequencySpectrum.m](function/plotting/plotFrequencySpectrum.m): displays magnitude in dBFS and performance metrics.

## Default test and results

The default is a 6+6 bridge CDAC: 12-bit resolution, 1 V reference, 1 MS/s, 1024 samples, 61 coherent sine cycles and 0 dBFS input. The input frequency is 59.5703125 kHz. The periodic Hann window remains enabled.

The unit capacitance is 10 fF. `p.mismatchStd = 0.05` means 5% relative standard deviation for a unit capacitor. `normrnd` draws each weight with mean `w` and standard deviation `0.05 * sqrt(w)` before scaling to fF, including the dummy and bridge. Extending this area-scaling model to the fractional bridge weight is an assumption; its nominal value is not tuned to compensate for array errors. Set `mismatchStd = 0` for ideal capacitances.

Full MATLAB verification on 2026-11-22 gave these coherent-Hann results. The 5% row uses seed 20261122 in a temporary verification script; normal-run results vary.

| Unit mismatch standard deviation | SNDR (dB) | ENOB (bits) |
|---|---:|---:|
| 0% | 73.725225 | 11.954356 |
| 5% (default) | 45.540673 | 7.272537 |

Zero mismatch exactly reproduced the saved 61.25-cycle baseline codes, voltages and FFT fields for binary and bridge splits 6+6, 7+5 and 5+7. Independent node solutions reproduced all coherent mismatch-run codes, with bridge voltage error below 2.78e-16 V. Across 20000 arrays per topology, capacitor standard deviations matched predictions within 0.93%. Code Analyzer reported no issues.

A temporary 20-device comparison at unit mismatch levels 0.1%, 0.5%, 1% and 5% gave median ENOB values of 11.81, 10.64, 9.68 and 7.42 bits. This supports the expected trend for this model; it does not establish process matching limits or reproduce a published statistical curve. The 5% setting makes mismatch visible and is large for retaining near-12-bit performance in this uncalibrated 6+6 array.

The FFT uses Hann window-sum normalization and a full-scale-sine reference. Analysis excludes the windowed-DC bins 0 and 1 and weights Nyquist by 1/sqrt(2). SNDR counts the nearest tone bin and its two neighbors as signal, and all remaining bins as residual. ENOB is `(SNDR - 1.76) / 6.02`.

The coherent default avoids the off-bin leakage that dominated the former 61.25-cycle estimate. Changing back to a noncoherent tone can put signal leakage in the residual. Neither residual leakage nor noise hidden under the signal is corrected. Keep other tones' three-bin regions inside the retained band and away from Nyquist. These are simulation estimates, not hardware measurements.

The spectrum uses a solid blue 2.5 pt line, a linear kHz axis and a -120 dBFS lower limit, with metrics inside the axes. The retained PNG is the earlier manually exported zero-mismatch result; it is not updated by running the model.

## References

- Analog Devices, Testing Data Converters: sampling, windowing and ADC dynamic metrics.
- Understanding Delta-Sigma Data Converters, second edition, Appendix A: FFT analysis and the Delta Sigma Toolbox.
