# MATLAB Code Structure

## Start with the execution path

[main.m](../main.m) is the user entry point. It sets parameters, adds the MATLAB project root and testing directory to the session path, runs the coherent sine-wave test, and displays the spectrum.

[runCoherentSineWaveTest.m](../testing/runCoherentSineWaveTest.m) organizes the performance test. It prepares the source, calls the complete converter, analyzes the output, and saves and displays results. It does not schedule individual device events.

```text
main.m
  -> parameters.createDefaultConfiguration
  -> runCoherentSineWaveTest
      -> parameters.validateConfiguration
      -> inputSignals.generateCoherentContinuousSineWave
      -> converterModel.simulateConverter
          -> converterModel.validateConverterParameters
          -> converterModel.createCapacitorArray (once per device)
          -> repeat for each sample, completing conversion before the next:
              -> converterModel.sampleCapacitorArray
                  -> converterModel.calculateTopPlateVoltage
              -> converterModel.convertSampledChargeToCode
                  -> repeat for each bit, from most significant to least:
                      -> switch trial branch to high reference
                      -> converterModel.calculateTopPlateVoltage
                      -> converterModel.compareComparatorInputs
                      -> retain branch, or switch it low and recalculate voltage
      -> spectrumAnalysis.analyzeCoherentSpectrum
      -> reporting.saveSimulationResults
          -> reporting.saveSourceSnapshot
          -> reporting.plotFrequencySpectrum (hidden export)
      -> reporting.displayPerformanceMetrics
  -> reporting.plotFrequencySpectrum (visible figure)
```

The generator returns inputVoltageAtTime, a function that evaluates the sine at any requested time, plus numeric source parameters. simulateConverter creates a single capacitor array for the run and passes it to each sampling and conversion operation. Sampling captures total charge on the array's common top plate. Successive bottom-plate switching changes the floating-node voltage, which drives the comparator. The array is both the sampling element and the capacitive DAC; there is no separate ideal hold buffer.

The scheduler retains the sequential sample/convert/store loop. Time is simulated circuit time, independent of MATLAB execution time. Acquisition ends at the sampling edge; trial switching occurs at the start of a bit interval and comparison at its end. All components settle instantaneously in this ideal model. No generic event framework or unused nonideality state is introduced.

## Converter model

These functions live directly in +converterModel and have no dependency on testing tools, files or figures.

| Function | Responsibility |
|---|---|
| [simulateConverter](../+converterModel/simulateConverter.m) | Create the device once, schedule acquisition and conversion, and collect numeric results. |
| [createCapacitorArray](../+converterModel/createCapacitorArray.m) | Create binary-weighted branch and dummy capacitances; actual values initially equal nominal values. |
| [sampleCapacitorArray](../+converterModel/sampleCapacitorArray.m) | Evaluate the source at one edge, store the sampled top-node charge, and switch bottom plates to the low reference. |
| [calculateTopPlateVoltage](../+converterModel/calculateTopPlateVoltage.m) | Solve the floating-node voltage from total stored charge, actual capacitances and current bottom-plate voltages. |
| [convertSampledChargeToCode](../+converterModel/convertSampledChargeToCode.m) | Switch and compare each branch, return the accepted code and final node voltage, and optionally record the trial sequence. |
| [compareComparatorInputs](../+converterModel/compareComparatorInputs.m) | Return whether the positive comparator input is at least its negative input. |
| [validateConverterParameters](../+converterModel/validateConverterParameters.m) | Check supported resolution, references, capacitance and bias settings, and numerical representability. |

The former idealSampleAndHold, evaluateHeldVoltage, convertHeldSampleToCode, calculateTrialVoltageAndThreshold and compareInputToThreshold interfaces are removed. Historical snapshots retain them. See [Model Definitions](MODEL_DEFINITIONS.md) for the charge equations, comparator polarity and explicit half-LSB reference-bias assumption.

## Performance-test tools

These functions live in `testing`. The runner is an ordinary function; the four `+` folders group related functions.

| Group | Function | Responsibility |
|---|---|---|
| Test runner | [runCoherentSineWaveTest](../testing/runCoherentSineWaveTest.m) | Execute one coherent sine-wave performance test. |
| Parameters | [createDefaultConfiguration](../testing/+parameters/createDefaultConfiguration.m) | Create the default configuration structure. |
| Parameters | [validateConfiguration](../testing/+parameters/validateConfiguration.m) | Check configuration version, sampling conditions, and harmonic separation. |
| Input signals | [generateCoherentContinuousSineWave](../testing/+inputSignals/generateCoherentContinuousSineWave.m) | Return a continuous-time sine evaluator and its frequency, amplitude, and offset; the frequency remains coherent with the test settings. |
| Spectrum analysis | [analyzeCoherentSpectrum](../testing/+spectrumAnalysis/analyzeCoherentSpectrum.m) | Compute the spectrum, harmonic components and dynamic metrics, and record analysis settings. |
| Reporting | [plotFrequencySpectrum](../testing/+reporting/plotFrequencySpectrum.m) | Render the same spectrum for display and export, with component markers, metrics and analysis conditions. |
| Reporting | [displayPerformanceMetrics](../testing/+reporting/displayPerformanceMetrics.m) | Print full metric descriptions, values, units, and harmonic components. |
| Reporting | [saveSimulationResults](../testing/+reporting/saveSimulationResults.m) | Save data, tables, plots, and completion metadata. |
| Reporting | [saveSourceSnapshot](../testing/+reporting/saveSourceSnapshot.m) | Copy the current implementation and model definitions and record checksums. |

A package folder such as `+inputSignals` gives its functions a group name: `inputSignals.generateCoherentContinuousSineWave(...)`. Add the package's parent directory to the MATLAB path, not the plus folder itself. The project uses explicit paths, without genpath, savepath, or global variables.

## Where to make changes

Change everyday simulation parameters in main.m; defaults for programmatic calls live in createDefaultConfiguration. The script computes comparatorReferenceShiftVolts from resolution and reference span. After changing those fields programmatically, deliberately recompute that bias if retaining the half-LSB transfer convention.

Run the entire main.m script after editing its parameters. The same configuration supplies capacitor construction and switching, nominal code reconstruction, coherent sine frequency and amplitude, and FFT scaling and metrics. ENOB correction uses the measured fundamental level, so amplitude changes need no separate analyzer edit. Implementation 3.0.2 permits amplitudeDbfs = 0 for a full-scale sine and reports configured amplitude and analytic source bounds; it retains the -1 dBFS default. Parameter combinations must still satisfy the existing timing, coherence and numerical constraints.

Physical converter changes belong in +converterModel. createCapacitorArray owns nominal and actual capacitances; a future mismatch realization belongs there once per device, not in each sample or comparison. sampleCapacitorArray owns acquisition and stored charge. calculateTopPlateVoltage expresses charge conservation, while convertSampledChargeToCode owns the switch sequence and per-bit timing. compareComparatorInputs is the ideal comparator decision. More detailed settling, leakage or reference behavior would require the corresponding physical state and equations when requested; none is implemented preemptively.

The capacitor array uses N+1 weighted branches, including a dummy. Each branch represents parallel matching units, not a separate allocation of every unit capacitor. Only the total floating-node charge is conserved during switching; individual capacitor charges redistribute. The explicit comparator-reference bias is a circuit assumption for the selected transfer convention, not random comparator offset. Nominal code reconstruction stays independent of actual capacitance values.

Input waveforms belong in +inputSignals, measurement definitions in +spectrumAnalysis, and presentation/exports in +reporting. Spectrum analysis is numerical measurement, so it does not need a circuit implementation. Consult [reference alignment](../../../documentation/ANALOG_DEVICES_REFERENCE_ALIGNMENT.md) before changing circuit or measurement assumptions.

The current converter is ideal. Noncoherent analysis, code-density tests and other performance tests should have explicit runners or analysis methods when implemented. There is no startup script or separate automated self-test suite. Focused checks are recorded in [Verified Simulation Results](VERIFIED_SIMULATION_RESULTS.md).

## Results and reproducibility

Configuration structures are independent of the MATLAB base Workspace. schemaVersion identifies model conventions; implementationVersion identifies code revision. Implementation 3.0.0 uses schema 3 for the charge-redistribution topology, capacitance parameters, top-plate clamp and explicit comparator-reference bias. Its default mathematical transfer and FFT conventions retain the schema 2 definitions. Replay older saved configurations using their source snapshots, or deliberately migrate their settings into a current configuration with the new physical and timing parameters.

Saved result.capacitorArray records nominal and actual capacitances. result.sampling retains timeSeconds, heldInputVolts (sampled input diagnostic), acquisitionStartTimeSeconds, holdIntervalEndTimeSeconds and holdEndTimeSeconds (record endpoint), and adds sampledTopPlateChargeCoulombs. result.conversion includes codes, nominal reconstructedVolts, completionTimeSeconds and finalTopPlateVoltageVolts. Existing result.stimulus.timeSeconds and inputVolts retain sampled-input meanings. The source function handle is runtime-only.

Implementation 3.0.1 adds result.spectrum.analysisSettings and summary.json analysisSettings, describing the rectangular window, bin width, equivalent noise bandwidth, analysis band, DC exclusion, harmonic range and spectral reference. Plot annotations use the existing spectrum and metrics. This reporting update preserves numerical definitions, configuration schema 3 and export format 3; no toolbox or additional analysis mode is introduced.

Implementation 3.0.2 expands the permitted input amplitude to include 0 dBFS and adds source-condition labels to the shared plot. It preserves numerical equations, field meanings, configuration schema 3 and export format 3.

A direct single-sample conversion can return an optional per-bit trace of trial code, trial top-plate voltage, bottom-plate settings, comparator reference, decisions and timing. It is not allocated for a complete record automatically. Saved sampled-input values are not the switching capacitor-node waveform.

Every completed export captures main.m, +converterModel, testing, and MODEL_DEFINITIONS.md in source_snapshot, with relative paths and SHA-256 checksums. Source is copied from disk at export time, so avoid editing it during a run. This supports local reproduction but does not replace source-control history.

Exports are staged in a hidden .incomplete_run_* directory and published as run_* only after the standard artifacts are written. Saved and returned results contain the same source metadata and final output path. See [result formats](../results/README.md) for saved-configuration replay and nonfinite-value handling.

## Documentation and working notes

[Model Definitions](MODEL_DEFINITIONS.md) describes implemented behavior. [Verified Simulation Results](VERIFIED_SIMULATION_RESULTS.md) records executed evidence. [Device Modeling Notes](DEVICE_MODELING_NOTES.md) and [Converter Testing Notes](CONVERTER_TESTING_NOTES.md) are evolving notebooks; the device note remains title-only, and no new lessons were added during the naming migration.
