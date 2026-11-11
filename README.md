# Analog-to-Digital Converter Design

An ideal single-ended SAR ADC model in MATLAB, with a binary-weighted charge-redistribution CDAC, successive bit decisions and noncoherent sine-wave FFT analysis with a periodic Hann window. The array includes a unit dummy capacitor and an explicit half-LSB comparator-reference bias. Nonideal effects are not modeled.

## Run

Requires MATLAB, Communications Toolbox and Richard Schreier's Delta Sigma Toolbox. Verified with MATLAB R2026a.

1. Add `sim-config`, `models`, `function` and `testbench`, including their subfolders, to the MATLAB path. Run `savepath` once to retain the setup.
2. Edit [createSimulationConfiguration.m](sim-config/createSimulationConfiguration.m) to set converter and test parameters.
3. Open [simConventionalSarADC.m](testbench/simConventionalSarADC.m) and click **Run**. The script displays the spectrum, SNDR and ENOB and keeps the output bits and analysis results in the workspace.

The testbench builds one capacitor array, converts and stores one sample at a time, then analyzes the complete record. Normal runs do not save files automatically.

## Main functions

- [cbwSarADC.m](models/cbwSarADC.m): converts one input voltage through successive bit trials and returns one MSB-first binary code.
- [binaryCDAC.m](function/binaryCDAC.m): calculates the CDAC output voltage from capacitor values, the input sample and switch positions.
- [idealDAC.m](function/data-processing/idealDAC.m): decodes output bits into nominal voltages for analysis.
- [processAdcData.m](function/data-processing/processAdcData.m): returns the complex single-sided spectrum, its magnitude in dBFS, SNDR and ENOB.
- [plotFrequencySpectrum.m](function/plotting/plotFrequencySpectrum.m): displays magnitude in dBFS and performance metrics.

## Default test and results

12-bit resolution, 1 V reference, 1 MS/s, 1024 samples, 61.25 sine cycles and 0 dBFS input. The input frequency is 59.814453125 kHz.

| Metric | Result |
|---|---:|
| SNDR | 74.039309 dB |
| ENOB | 12.006530 bits |

The FFT is normalized by the Hann window sum and referenced to a full-scale sine. Analysis and plotting exclude the first six bins, including DC. SNDR assigns the nearest tone bin and 25 bins on each side to signal; the remaining retained bins contain noise and distortion. ENOB is `(SNDR - 1.76) / 6.02`, without amplitude correction.

The spectrum displays individual bins down to -120 dBFS, with SNDR and ENOB inside the axes. A full MATLAB run on 2026-11-11 reproduced the metrics above. The retained FFT coefficients agreed with the Appendix A amplitude normalization within 2e-16 after matching the input scale and Nyquist weighting. At 1024 samples, a pure sine with 61 cycles had 3 bins above -60 dBFS; at 61.25 cycles it had 12, matching the ADC output at that threshold. The figure is manually exported.

These are finite-record estimates for the selected ideal test. Noise inside the signal region is excluded from the residual, while residual tone leakage can enter it; neither effect is corrected. Other tone settings must keep the 51-bin signal region inside the retained band and away from Nyquist. No measured hardware performance is implied.

## References

- Analog Devices, Testing Data Converters: sampling, windowing and ADC dynamic metrics.
- Understanding Delta-Sigma Data Converters, second edition, Appendix A: FFT analysis and the Delta Sigma Toolbox.
