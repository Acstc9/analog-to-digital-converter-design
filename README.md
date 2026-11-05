# Analog-to-Digital Converter Design

An ideal, single-ended SAR ADC built from a binary-weighted charge-redistribution CDAC, an ideal comparator and successive bit decisions. A coherent sine-wave testbench runs the converter, computes an FFT and displays performance metrics. This repository also reserves space for future circuit design and measurements.

## Run in MATLAB

1. Open this project folder in MATLAB. MATLAB R2026a with Communications Toolbox and Richard Schreier's Delta Sigma Toolbox is the verified environment. idealDAC uses bi2de to decode the binary output, and processAdcData uses dbv and calculateSNR for the metrics. plotFrequencySpectrum uses toolbox dbv and MATLAB stem for the raw spectrum.
2. On first use, select `sim-config`, `models`, `function` and `testbench` in the MATLAB Files panel. Right-click and choose **Add to Path > Selected Folders and Subfolders**. Run `savepath` in the Command Window to keep these paths for future sessions. Repeat this step if you move the project.
3. Edit [createSimulationConfiguration.m](sim-config/createSimulationConfiguration.m) to choose resolution, nominal reference, capacitance, sampling rate, record length, cycle count and input level in dBFS. The function returns the parameter structure `p`.
4. Open [simConventionalSarADC.m](testbench/simConventionalSarADC.m) and click **Run**. Run the whole script after changing settings so derived values are recalculated.
5. Read the FFT and Performance panel. The workspace keeps p, stimulus, inputVoltageSamples, binaryCodes, outputVolts and spectrum directly. Each row of binaryCodes is one conversion, with the MSB in the first column. outputVolts holds the decoded voltage samples, and spectrum contains the FFT and metrics.

The testbench replaces workspace variables on each run and opens a new figure. Close old figures when finished. Results are not saved automatically.

## Project structure

```text
.
|-- sim-config/createSimulationConfiguration.m   Experiment settings
|-- testbench/simConventionalSarADC.m             Run the complete experiment
|-- models/cbwSarADC.m                           Sampling, switching and SAR control
|-- function/
|   |-- cdac-topologies/synthesizeBinaryCDAC.m    Generate binary weights and the unit dummy
|   |-- binaryCDAC.m                            Calculate the CDAC output voltage
|   |-- generateCoherentSineSamples.m            Coherent sine voltage samples
|   |-- data-processing/idealDAC.m               Decode binary codes into nominal volts
|   |-- data-processing/processAdcData.m         FFT and metrics from voltage samples
|   |-- data-processing/codeDensityTest.m        Empty placeholder
|   `-- plotting/plotFrequencySpectrum.m         Raw spectrum and performance panel
|-- documentation/                              Device and testing notebooks
|-- coding-style/                               Maintained MATLAB coding rules
|-- literature/                                 Reference index; local originals are ignored
|-- drawing/blockDiagram.drawio                 Drawing template
|-- design/                                     Future circuit and layout work
`-- measurements/                               Future measured data
```

The testbench calls configuration -> coherent source -> converter -> ideal DAC -> FFT processing -> plotting. The source generates a column of sample voltages from the sample indices. The converter builds one capacitor array and computes its total capacitance once. For each sample, the model trials 0/1 switch positions from MSB to LSB, calls binaryCDAC and directly compares cdacOutputVolts to the half-LSB reference. The voltage function receives the capacitor array, p, the input voltage and switch positions. It computes sampled charge and bottom-plate voltages with the dummy grounded, then solves charge conservation. The model stores the final switch positions as one row of binaryCodes before reading the next sample. idealDAC decodes those rows with bi2de using left-msb ordering and multiplies the resulting integers by the nominal LSB voltage. processAdcData receives the resulting voltage column, computes the FFT and calls the Delta Sigma Toolbox for SNDR. The testbench passes spectrum and p directly to plotFrequencySpectrum, which converts the normalized FFT to dBFS with toolbox dbv and displays individual bins with MATLAB stem.

The drawing and code-density file are placeholders, not implemented features.

## Current scope and parameter choices

- Ideal matched capacitors, ideal reference voltages and an ideal comparator; no noise, mismatch, settling, jitter or transistor-level behavior.
- A unit dummy completes the binary array. Capacitance is in fF, charge in fC and voltage in V. Sampling clamps the common top plate to 0 V and connects the bottom plates to the input; conversion conserves total top-node charge.
- An explicit ideal comparator-reference bias of half a nominal LSB implements the chosen half-LSB transition convention. This is an intentional circuit assumption.
- The default converter uses 12 bits, a grounded low reference, a nominal 1 V full-scale span (`p.vRef`) and 10 fF unit capacitors. The sine is centered at `p.vCM = p.vRef / 2`. The test uses 1 MS/s, 1024 samples, 61 cycles and a -1 dBFS sine at 59.5703125 kHz. Set `p.amplitudeDbfs` to choose the level relative to the full-scale peak amplitude of `p.vRef / 2`.
- Use a power-of-two sample count and an odd prime cycle count below half the record length.
- The FFT is referenced to a full-scale sine. The plot displays individual positive-frequency bin powers in dBFS, without averaging. SNDR (also called SINAD) compares fundamental power to the total power in all other non-DC bins, including distortion. The plot reports SNDR and amplitude-corrected ENOB. No SFDR, individual harmonic analysis or extra power summaries are produced.

processAdcData computes fft/N * 4/p.vRef, so a full-scale coherent sine below Nyquist has unit magnitude at its positive-frequency peak. It then prepares singleSidedTransform from DC through Nyquist: DC is set to zero and the Nyquist entry is divided by sqrt(2) to preserve single-sided relative power weighting. This shared complex spectrum is used directly by both calculateSNR and plotFrequencySpectrum. The returned structure contains singleSidedTransform and metrics with sndrDb and enobBits, without separate frequency or dBFS arrays. calculateSNR receives a third argument of 0 so only the coherent fundamental bin counts as signal; the default of three bins is intended for Hann-windowed data. All other non-DC components, including harmonics and Nyquist, remain in the denominator.

ENOB is amplitude corrected: (SNDR - 1.76 - measured fundamental dBFS) / 6.02. This accounts for the -1 dBFS input, following ADI Equation 5.23. It does not demonstrate actual full-scale performance. dbv measures the fundamental level from the unsmoothed FFT.

The display follows the raw-spectrum route in the toolbox examples: normalized FFT -> dbv -> MATLAB plotting. plotFrequencySpectrum reads singleSidedTransform( 2 : end ), converts amplitudes to dBFS and uses thin classic-blue stems on a linear kHz axis. Nyquist weighting has already been applied in processAdcData and is not repeated. The horizontal limits are 0 to Fs/2 and the vertical limits are -160 to 5 dBFS. DC is omitted; Nyquist is included. Zero-power bins remain -Inf and are not drawn. No bins are averaged and no artificial dB floor is applied. The toolbox plotSpectrum helper is not used because its smoothing hides individual-bin detail. Plotting does not alter SNDR or ENOB.

## Notes and references

- [Device modeling notes](documentation/device-modeling-notes.md): physical assumptions and component responsibilities.
- [Converter testing notes](documentation/converter-testing-notes.md) explain coherent sampling, the 1024-point processing gain and the choice of 61 cycles.
- [Reference index and alignment](literature/README.md): applicable ADI pages, project choices and supporting literature.
- [MATLAB coding style](coding-style/matlab-coding-style.md): naming, formatting and implementation conventions.

## Verification

Verified in MATLAB R2026a with Communications Toolbox and Delta Sigma Toolbox on 2026-11-05. The default 12-bit, 1024-sample, -1 dBFS test produces:

| Quantity | Result |
|---|---:|
| Input frequency | 59.5703125 kHz |
| Input range | 0.054374531 to 0.945625469 V |
| Measured fundamental | -1.000094 dBFS |
| SNDR | 73.234642 dB |
| Amplitude-corrected ENOB | 12.038993 bits |

The full testbench returned a 1024-by-12 matrix of output bits. All decoded codes matched rounding to the nearest nominal LSB for this record. Focused checks covered CDAC trial voltages, the half-LSB comparison threshold, endpoint saturation, MSB-first decoding and scaling with a 1.2 V reference.

A synthetic signal containing DC, a fundamental, an adjacent harmonic and a Nyquist component matched analytical SNDR and corrected ENOB. The shared single-sided spectrum produced identical metric inputs and plotted values to the separate calculations. The raw display was also checked against direct single-sided power calculations within 1e-10 dB. These checks cover the ideal converter and coherent rectangular-window analysis; they do not establish noncoherent, windowed or physical-device performance.

## Repository contents

Source code, project documentation, coding conventions and the retained placeholders are versioned. Editor backups, generated results and external reference documents are excluded. Reference books and MATLAB toolboxes are not bundled; the dependencies listed above must be installed separately.
