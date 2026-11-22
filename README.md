# SAR ADC MATLAB Model

A single-ended SAR ADC model in MATLAB, with a selectable binary-weighted or bridge charge-redistribution CDAC, static capacitor mismatch and periodic-Hann FFT analysis. The array includes a unit dummy capacitor and an explicit half-LSB comparator-reference bias. Thermal noise, settling and transistor behavior are not modeled.

## Run

Requires MATLAB, Communications Toolbox, Statistics and Machine Learning Toolbox (`normrnd`), and Richard Schreier's Delta Sigma Toolbox. Verified with MATLAB R2026a.

1. Add `sim-config`, `models`, `function` and `testbench`, including their subfolders, to the MATLAB path.
2. Edit [createSimulationConfiguration.m](sim-config/createSimulationConfiguration.m) to set converter and test parameters, including the bridge split (`p.msbBitCount` and `p.lsbBitCount`).
3. Open [simADC.m](testbench/simADC.m). On the first line, choose the CDAC type (`"bridge"` or `"binary"`) and the unit capacitor's relative mismatch standard deviation (`0` for ideal capacitors, `0.05` for 5%). Click **Run** to simulate one array and display its spectrum, SNDR and ENOB. The samples, output codes and decoded voltages stay in the workspace with the spectrum.

## Main functions

- [cbwSarADC.m](models/cbwSarADC.m): converts one input voltage through successive bit trials and returns one MSB-first binary code.
- [synthesizeCDAC.m](function/cdac-topologies/synthesizeCDAC.m) builds the selected CDAC, applies Gaussian mismatch and returns its branch capacitances and array totals in fF.
- [binaryCDAC.m](function/binaryCDAC.m) and [bridgeCDAC.m](function/bridgeCDAC.m): calculate the selected CDAC output voltage from capacitor values, the input sample and switch positions.
- [idealDAC.m](function/data-processing/idealDAC.m): decodes output bits into nominal voltages for analysis.
- [processAdcData.m](function/data-processing/processAdcData.m): returns the complex single-sided spectrum, its magnitude in dBFS, SNDR and ENOB.
- [plotFrequencySpectrum.m](function/plotting/plotFrequencySpectrum.m): displays magnitude in dBFS and performance metrics.

## Default test and results

The single-run default is a 6+6 bridge CDAC with 12-bit resolution, 1 V reference, 1 MS/s, 1024 samples, 61 coherent sine cycles and 0 dBFS input. The input frequency is 59.5703125 kHz. The periodic Hann window remains enabled.

The unit capacitance is 10 fF. `normrnd` draws each weight with mean `w` and standard deviation `p.mismatchStd * sqrt(w)` before scaling to fF, including the dummy and bridge. All 1024 samples use the same array. Extending this area-scaling model to the fractional bridge weight is an assumption.

Full MATLAB verification on 2026-11-22 gave these bridge-CDAC coherent-Hann results. The 5% row uses seed 20261122 in a temporary verification script. Normal-run results vary.

| Unit mismatch standard deviation | SNDR (dB) | ENOB (bits) |
|---|---:|---:|
| 0% | 73.725225 | 11.954356 |
| 5% (default) | 45.540673 | 7.272537 |

Run [plotEnobVsMismatch.m](function/plotting/plotEnobVsMismatch.m) for the binary CDAC mismatch curve. Each entry in `mismatchStdValues` gives one point, the median FFT-based ENOB of 100 independent arrays. A 1,000-point sweep in steps of 0.0001 with seed 20261122 gave 11.95 bits at 0.01% unit-capacitor mismatch and 9.33 bits at 10%.

Zero mismatch exactly reproduced the saved 61.25-cycle baseline codes, voltages and FFT fields for binary and bridge splits 6+6, 7+5 and 5+7. Independent node solutions reproduced all coherent mismatch-run codes, with bridge voltage error below 2.78e-16 V. Across 20000 arrays per topology, capacitor standard deviations matched predictions within 0.93%. Code Analyzer reported no issues.

The FFT uses Hann window-sum normalization and a full-scale-sine reference. Analysis excludes the windowed-DC bins 0 and 1 and weights Nyquist by 1/sqrt(2). SNDR counts the nearest tone bin and its two neighbors as signal, and all remaining bins as residual. ENOB is `(SNDR - 1.76) / 6.02`.

The coherent default avoids the off-bin leakage that dominated the former 61.25-cycle estimate. Changing back to a noncoherent tone can put signal leakage in the residual. Neither residual leakage nor noise hidden under the signal is corrected. Keep other tones' three-bin regions inside the retained band and away from Nyquist. These are simulation estimates, not hardware measurements.

The spectrum uses a solid blue 2.5 pt line, a linear kHz axis and a -120 dBFS lower limit, with metrics inside the axes. The frequency spectrum and binary CDAC mismatch curve in `drawing` are manually exported. The spectrum PNG shows the earlier zero-mismatch run.

## References

- Analog Devices, Testing Data Converters: sampling, windowing and ADC dynamic metrics.
- Understanding Delta-Sigma Data Converters, second edition, Appendix A: FFT analysis and the Delta Sigma Toolbox.
