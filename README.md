# Analog-to-Digital Converter Design

An ideal single-ended SAR ADC model in MATLAB, with a binary-weighted charge-redistribution CDAC, successive bit decisions and coherent sine-wave FFT analysis. The array includes a unit dummy capacitor and an explicit half-LSB comparator-reference bias. Nonideal effects are not modeled.

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
- [processAdcData.m](function/data-processing/processAdcData.m): returns the shared single-sided spectrum, SNDR and ENOB.
- [plotFrequencySpectrum.m](function/plotting/plotFrequencySpectrum.m): displays magnitude in dBFS and performance metrics.

## Default test and results

12-bit resolution, 1 V reference, 1 MS/s, 1024 samples, 61 coherent sine cycles and 0 dBFS input. The input frequency is 59.5703125 kHz.

| Metric | Result |
|---|---:|
| SNDR | 73.683607 dB |
| ENOB | 11.947443 bits |

ENOB is calculated as `(SNDR - 1.76) / 6.02`, without amplitude correction. The sine peak amplitude is fixed at `p.vRef / 2`, giving a full-scale input centered at `p.vCM`. SNDR includes all non-DC noise and distortion bins except the coherent fundamental.

Verified on 2026-11-06 with a complete testbench run. SNDR agreed with an independent single-sided power calculation within 1e-10 dB, and all 512 plotted values matched the processed spectrum. The binary output dimensions and active model, processing and plotting paths were also checked. Moving the sample loop to the testbench preserved all 12288 output bits and the FFT results exactly for this record. These results describe the ideal model under the stated coherent test conditions, not measured hardware performance.

## References

- Analog Devices, Testing Data Converters: coherent sampling and ADC dynamic metrics.
- Understanding Delta-Sigma Data Converters, second edition, Appendix A: FFT analysis and the Delta Sigma Toolbox.
