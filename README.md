# Analog-to-Digital Converter Design

An ideal, single-ended SAR ADC built from a binary-weighted charge-redistribution CDAC, an ideal comparator and successive bit decisions. A coherent sine-wave testbench runs the converter, computes an FFT and displays performance metrics. This repository also reserves space for future circuit design and measurements.

## Run in MATLAB

1. Open this project folder in MATLAB. MATLAB R2026a is the verified environment; no additional toolbox is required.
2. Edit [createSimulationConfiguration.m](sim-config/createSimulationConfiguration.m) to choose resolution, reference voltages, capacitance, sampling rate, record length, cycle count, input amplitude and harmonic count.
3. Open [simConventionalSarADC.m](testbench/simConventionalSarADC.m) and click **Run**. Run the whole script after changing settings so derived values are recalculated.
4. Read the FFT and Performance panel. The `result` variable contains configuration, stimulus settings, digital codes and spectrum data in the MATLAB workspace.

There is no startup script or automatic file saving. The testbench adds its own required paths. It replaces workspace variables on each run and opens a new figure; close old figures when finished. The former `modeling/matlab/main.m` entry point belongs to the previous implementation and is no longer part of the current working tree.

## Project structure

```text
.
|-- sim-config/createSimulationConfiguration.m   Experiment settings
|-- testbench/simConventionalSarADC.m             Run the complete experiment
|-- models/cbwSarADC.m                           Sampling, switching and SAR control
|-- function/
|   |-- cdac-topologies/synthesizeBinaryCDAC.m    Construct the capacitor array
|   |-- sampleInputOntoCDAC.m                    Capture one input sample and charge
|   |-- calculateTopPlateVoltage.m              Solve charge conservation
|   |-- compareVoltages.m                       Ideal comparator
|   |-- generateCoherentContinuousSineWave.m     Continuous input as a function of time
|   |-- data-processing/processAdcData.m         Code interpretation, FFT and metrics
|   |-- data-processing/codeDensityTest.m        Empty instructor placeholder
|   `-- plotting/plotFrequencySpectrum.m         Basic spectrum and performance panel
|-- documentation/                              Device and testing notebooks
|-- coding-style/                               Maintained MATLAB coding rules
|-- literature/                                 Reference index; local originals are ignored
|-- drawing/blockDiagram.drawio                 Instructor drawing template
|-- design/                                     Future circuit and layout work
`-- measurements/                               Future measured data
```

The testbench calls configuration -> coherent source -> converter -> FFT processing -> plotting. Inside the converter, one capacitor array is built once. Each sample is captured, fully converted from MSB to LSB, and stored before the next sample. Switching belongs to the model's control loop; the component functions supply the sampling, charge calculation and comparison operations. The converter returns digital codes only. Analysis interprets them in nominal volts.

`cbwSarADC` retains the instructor's wrapper name. The supplied template does not define what CBW stands for. The drawing and code-density file remain templates, not completed features.

## Current scope and parameter choices

- Ideal matched capacitors, ideal reference voltages and an ideal comparator; no noise, mismatch, settling, jitter or transistor-level behavior.
- A unit dummy completes the binary array. Capacitance is in fF, charge in fC and voltage in V. Sampling clamps the common top plate to 0 V and connects the bottom plates to the input; conversion conserves total top-node charge.
- An explicit ideal comparator-reference bias of half a nominal LSB implements the chosen half-LSB transition convention. This is an intentional circuit assumption.
- Defaults: 12 bits, 0/1 V references, 10 fF unit capacitance, 1 MS/s, 16384 samples, 997 cycles, -1 dBFS input, and harmonics 2-6. The resulting input frequency is 60.85205078125 kHz.
- Use a power-of-two sample count and an odd prime cycle count for the selected coherent test profile. Set `maximumHarmonicOrder * coherentCycleCount < sampleCount / 2`. The current analyzer does not fold selected harmonics above Nyquist or process noncoherent records. These assumptions are documented rather than enforced by runtime validators.
- `amplitudeDbfs` can be set to 0 for a full-scale sine or below 0 for a smaller input. This changes the experiment; a lower amplitude is not automatically a more accurate measurement.
- FFT power is reported per frequency bin in dBFS, referenced to a full-scale sine. DC is excluded from metrics. SNR excludes the selected harmonics; SINAD includes their distortion. Higher-order components remain in the residual-noise sum. ENOB in the plot includes the below-full-scale amplitude correction; the uncorrected value remains in `result.spectrum.metrics`.

The plot uses thin classic-blue stems and a fixed -160 to 5 dBFS display range. Zero-power bins remain `-Inf` in the data and are omitted from the stems. Plot limits do not change the FFT or metric calculations.

## Notes and references

- [Device modeling notes](documentation/device-modeling-notes.md): physical assumptions and component responsibilities.
- [Converter testing notes](documentation/converter-testing-notes.md): the retained coherent-sampling rationale, including coprime cycle counts and the 16384/997 choices.
- [Reference index and alignment](literature/README.md): applicable ADI pages, project choices and local source locations.
- [MATLAB coding style](coding-style/matlab-coding-style.md): instructor rules and explicitly approved exceptions.
- [Assistant handoff instructions](AGENTS.md): current scope and change constraints.

## Verification

The default ideal-model baseline is SNR 73.043654 dB, SINAD 73.039112 dB, THD -102.847274 dBc, SFDR 96.876367 dBc and amplitude-corrected ENOB 12.006499 bits. Finite deterministic quantization records can differ slightly from the approximate ideal-noise formula; a value slightly above 12 bits does not establish extra physical resolution.

On 2026-11-01, MATLAB R2026a executed the complete assembled testbench. All 16384 output codes were finite, integer-valued and within range; the five reported metrics matched this baseline within 1e-8. The single-sided power sum matched the mean square of the centered code-derived voltage within 1e-12 V^2. All 11 MATLAB files, including the empty instructor placeholder, passed Code Analyzer. One figure was created, no results directory was generated, and all MATLAB sources and instructor templates remained byte-identical to the pre-integration rebuild. Verification used a temporary script, not a permanent test suite. No circuit nonidealities, noncoherent analysis or laboratory performance are validated by this baseline.

## Repository and local materials

The existing public repository is [Acstc9/analog-to-digital-converter-design](https://github.com/Acstc9/analog-to-digital-converter-design). The instructor-guided implementation replaces the previous working tree in a normal history-preserving commit. The final local working folder is `ADC OCT 2026 version`.

Source code, documentation, coding rules and retained instructor templates are versioned. `.gitignore` excludes editor backups, `/results/` and `/literature/source-documents/`; it does not exclude every PDF, image, CSV or MAT file. Future intentional design artifacts and measured data can therefore be versioned selectively.

Local reference books and instructor originals live under `literature/source-documents/references/`. A one-time migration archive under `literature/source-documents/project-history/` preserves the previous local source, uncommitted documentation and pre-integration rebuild records, with a SHA-256 preservation manifest. These materials are not required to run the model and are not uploaded. Generated run files and their copied source snapshots are excluded from the migration archive; older Git commits remain available in repository history.
