# Ideal Successive-Approximation Converter in MATLAB

## Click to run

Open main.m in this directory in the MATLAB editor, edit the parameters at the top, and click the green Run button to execute the entire file. If a path prompt appears, choose Change Folder. The entry point sets session paths, runs the model, displays the FFT, prints metrics vertically and then the harmonic table, and saves results. The testing functions run automatically; no separate startup or self-test script is required.

Only base MATLAB is required. The implementation has been executed in R2026a and does not depend on Signal Processing Toolbox. The syntax targets R2021b or later; other versions have not been verified by execution.

| main parameter | Default | Constraint or meaning |
|---|---:|---|
| resolutionBits | 12 | 1-24 bits |
| sampleRateHz | 1e6 | Positive sample rate in Hz |
| acquisitionDurationSeconds | 200e-9 | Acquisition interval before each sampling edge |
| bitDecisionDurationSeconds | 25e-9 | Time from a trial-bit update to its comparison |
| minimumInputVolts / maximumInputVolts | 0 / 1 | Lower and upper references in V |
| unitCapacitanceFarads | 10e-15 | Nominal unit capacitance; binary branches are parallel groups of units |
| samplingTopPlateVoltageVolts | 0 | Ideal top-plate clamp during sampling |
| comparatorReferenceShiftVolts | nominal LSB/2 | Explicit comparator-reference bias above the sampling clamp; computed from resolution and reference span |
| sampleCount | 16384 | Power of two, at least 32 |
| coherentCycleCount | 997 | Odd prime, less than sampleCount/2 |
| amplitudeDbfs | -1 | At or below 0 dBFS; 0 selects a full-scale sine, and the default leaves endpoint margin |
| maximumHarmonicOrder | 6 | Defaults to harmonics 2-6 following Analog Devices; changing this changes the metric convention |

Input frequency = coherentCycleCount * sampleRateHz / sampleCount, which defaults to 60.85205078125 kHz. Change the cycle count or sample rate to change the input frequency; do not independently hard-code a frequency inside the stimulus function. Short records with too many harmonics are rejected if spectral components overlap.

For everyday changes, edit only main.m and run the entire file, rather than just its Run and display section. The configured reference range and resolution determine the half-LSB comparator bias, capacitor weights, switching levels and code reconstruction. The source automatically updates its midpoint and amplitude; FFT analysis updates its full-scale power reference and recalculates every metric, including the measured-level ENOB correction. The plot shows the configured amplitude and analytic sine voltage bounds. Supported timing and coherence constraints still apply.

At 0 dBFS, the sine extends from minimumInputVolts to maximumInputVolts. The exact upper endpoint converts to the maximum code, whose nominal reconstructed value is maximumInputVolts minus one LSB. It also sets overrangeMask under the existing [Vmin, Vmax) convention. This diagnostic does not remove the sample from FFT or suppress endpoint effects.

The acquisition duration plus resolutionBits times the bit-decision duration must fit within one sampling period. These durations are explicit project assumptions, not device specifications. The default 12-bit conversion takes 300 ns after each sampling edge; acquisition occupies the 200 ns before the next edge. Sampling remains at 0, 1/sampleRateHz, and so on. The first sample assumes ideal acquisition before time zero.

For the reasoning behind these values, read [Converter Testing Notes](documentation/CONVERTER_TESTING_NOTES.md). It explains coherence, leakage, coprime phase coverage, one-cycle records, and why powers of two and prime cycle counts are project choices rather than universal mathematical requirements.

The Workspace variable result contains configuration, stimulus, capacitorArray, sampling, conversion, spectrum, and outputDirectory. result.spectrum.metrics.enobBits includes the Analog Devices amplitude correction; enobUncorrectedBits retains the uncorrected value to avoid confusion with previous versions. The figure's performance panel displays the corrected value. Each successful run creates a separate results directory with a source snapshot and leaves previous figure windows open. Invalid or unmeasurably small inputs produce an explicit error rather than an unexplained NaN table.

## Find the code

Read main.m, then [runCoherentSineWaveTest.m](testing/runCoherentSineWaveTest.m), then the functions called by that runner. Converter behavior is in +converterModel. Test setup, signal generation, spectrum analysis, and reporting are in testing. The leading + marks a MATLAB package; calls use the group name without that plus sign.

See [Code Structure](documentation/CODE_STRUCTURE.md) for the full call chain and a one-line description of every function. Read [Model Definitions](documentation/MODEL_DEFINITIONS.md) for the algorithms, [Verified Simulation Results](documentation/VERIFIED_SIMULATION_RESULTS.md) for executed checks, and [reference alignment](../../documentation/ANALOG_DEVICES_REFERENCE_ALIGNMENT.md) for manual conventions.

The coherent continuous source supplies a voltage-versus-time function. simulateConverter creates one capacitor array, then samples charge, completes all bit decisions, stores the result, and repeats. sampleCapacitorArray connects all bottom plates to the input while the common top plate is clamped. During conversion the top node floats, bottom plates switch between references, and calculateTopPlateVoltage solves its voltage from conserved total charge. There is no independent ideal hold buffer in front of this array.

Inspect result.capacitorArray for nominal and actual branch capacitances, result.sampling for captured input values, sampled charge and timing, and result.conversion for output codes, final top-plate voltage and completion times. The legacy heldInputVolts field means sampled input voltage; it is not the switching top-plate waveform. A detailed switching trace is available through a direct single-sample conversion, rather than allocated for every sample.

Capacitors, switches, references and comparator decisions remain ideal. The unit capacitance sets physical charge scale but does not change ideal capacitor ratios. The explicit comparator-reference bias preserves the selected half-LSB transition convention. main.m and the default-configuration function compute that bias from resolution and reference span. If changing those fields programmatically after configuration creation, also update the bias deliberately. Actual branch capacitances equal nominal values; createCapacitorArray is the future mismatch entry point, with one fixed array per device. No random mismatch is generated.

For programmatic runs, add this directory and its testing directory to the MATLAB path, then call runCoherentSineWaveTest(configuration). It saves and prints results without opening a visible figure. The main script additionally displays a visible spectrum. Current implementation 3.0.2 retains configuration schema 3 and export format 3. It adds full-scale input support and source-condition labels without changing conversion or FFT equations. Historical naming migrations preserved their numerical models; the later capacitor-array change is a new model implementation with separately recorded verification.

New runs are stored under results/coherent_sine_wave. Existing results/sar_ideal runs retain their original files. Figure exports use frequency_spectrum.png and frequency_spectrum.pdf. Close obsolete editor tabs after migration and reopen main.m from this directory; restart MATLAB if old search paths remain.

## Working notes

- [Device Modeling Notes](documentation/DEVICE_MODELING_NOTES.md): reserved for device modeling and design reasoning; currently title-only.
- [Converter Testing Notes](documentation/CONVERTER_TESTING_NOTES.md): contains the existing sampling-parameter rationale and is the home for future testing notes.

These evolving notes are separate from MODEL_DEFINITIONS.md (implemented contracts), CODE_STRUCTURE.md (software organization), and VERIFIED_SIMULATION_RESULTS.md (executed evidence). No additional lesson content was added during their creation.
