# Project Structure and Naming

## Where files belong

| Content | Location | Purpose |
|---|---|---|
| Shared decisions and reference alignment | `documentation/` | Conventions used across modeling, design, and measurement work. |
| External manuals, papers, and data sheets | `references/<source>/` | Preserve source content and record checksums. |
| Behavioral modeling | `modeling/<tool>/` | Tool-specific entry points, converter models, performance tests, documentation, and results. |
| Circuit and layout implementation | `design/` | Add circuit and layout directories when that work begins. |
| Acquired measurement data | `measurements/` | Preserve original data separately from processed results. |

Within MATLAB, `+converterModel` contains the converter itself. `testing` contains the coherent sine-wave test and its parameter, signal-generation, analysis, and reporting functions. The leading plus sign marks a MATLAB package, not an execution step. See [Code Structure](../modeling/matlab/documentation/CODE_STRUCTURE.md) for every function's role.

## Naming and wording

Use complete, natural English that communicates the actual content or action. Function names start with a meaningful action where appropriate: create configuration, generate a signal, validate parameters, convert samples, analyze a spectrum, plot a spectrum, or save results. Folder names describe their contents. Do not apply a generic test prefix to every function or confuse parameter validation with converter performance testing.

Use lower_snake_case for ordinary folders and data files, lowerCamelCase for MATLAB function and package names, and UPPER_SNAKE_CASE.md for maintained documentation. Use `documentation`, not an abbreviated folder name. Keep required names such as main.m, README.md, AGENTS.md, MATLAB file extensions, and the package `+` marker. Standard engineering units and established saved-data fields retain their documented meanings. Explain technical terms in prose when needed.

The user-named outer project directory and historical records retain their names. New maintained filenames and folder names use complete words. Avoid ambiguous revision suffixes such as final2 and new. Git tracks the project in the private Acstc9/analog-to-digital-converter-design repository. Reference PDFs and routine generated results remain local; the default implementation 3.0.2 run is explicitly included as a reproducible baseline.

## Naming migration on 2026-10-25

The following source paths are relative to `modeling/matlab`. The naming migration retained the numerical model and default parameters. Current paths below also reflect the subsequent continuous-source separation and chronological device loop.

| Previous location | Current location |
|---|---|
| `src/+adc/+config/idealBaseline.m` | `testing/+parameters/createDefaultConfiguration.m` |
| `src/+adc/+config/validate.m` | `testing/+parameters/validateConfiguration.m` |
| `src/+adc/+config/validateConverter.m` | `+converterModel/validateConverterParameters.m` |
| `src/+adc/+stimulus/coherentSine.m` | `testing/+inputSignals/generateCoherentContinuousSineWave.m` |
| `src/+adc/+sampling/idealSampleHold.m` | `+converterModel/sampleCapacitorArray.m` |
| `src/+adc/+sar/convert.m` | `+converterModel/convertSampledChargeToCode.m` |
| `src/+adc/+sar/dacVoltage.m` | `+converterModel/calculateTopPlateVoltage.m` |
| `src/+adc/+sar/compare.m` | `+converterModel/compareComparatorInputs.m` |
| `src/+adc/+analysis/coherentFft.m` | `testing/+spectrumAnalysis/analyzeCoherentSpectrum.m` |
| `src/+adc/+report/plotSpectrum.m` | `testing/+reporting/plotFrequencySpectrum.m` |
| `src/+adc/+report/exportRun.m` | `testing/+reporting/saveSimulationResults.m` |
| `src/+adc/+report/captureSource.m` | `testing/+reporting/saveSourceSnapshot.m` |
| `experiments/sar_ideal/runIdealSar.m` | `testing/runCoherentSineWaveTest.m` |

`testing/+reporting/displayPerformanceMetrics.m` now owns the command-window presentation previously embedded in the test runner. It displays full metric names and units while saved metric fields remain compatible with schemaVersion 2.

| Previous documentation or output name | Current name |
|---|---|
| Both `docs/` directories | `documentation/` at the same level |
| `ADI_ALIGNMENT.md` | `ANALOG_DEVICES_REFERENCE_ALIGNMENT.md` |
| `MODEL.md` | `MODEL_DEFINITIONS.md` |
| `ARCHITECTURE.md` | `CODE_STRUCTURE.md` |
| `BASELINE.md` | `VERIFIED_SIMULATION_RESULTS.md` |
| `ADC_TESTING_NOTES.md` | `CONVERTER_TESTING_NOTES.md` |
| `references/adi/adi-analog-digital-conversion-chapter-5-testing-data-converters.pdf` | `references/analog_devices/analog_devices_testing_data_converters.pdf` |
| New run parent: `results/sar_ideal/` | `results/coherent_sine_wave/` |
| New plots: `fft.png` and `fft.pdf` | `frequency_spectrum.png` and `frequency_spectrum.pdf` |

The manual's file content is unchanged. Historical runs, including their saved source snapshots, remain in `results/sar_ideal/` with their original names and contents. Previous verification documents are retained in the MATLAB documentation's `history/` directory. Old function calls are replaced, without compatibility wrappers that duplicate the visible entry points.

The ideal-source separation renamed generateCoherentSineWave.m to generateCoherentContinuousSineWave.m. Implementation 2.4.0 introduced simulateConverter as the chronological device scheduler. Implementation 3.0.0 replaces the voltage-equivalent converter with a physical charge-redistribution model: createCapacitorArray constructs the device, sampleCapacitorArray replaces idealSampleAndHold, convertSampledChargeToCode replaces convertHeldSampleToCode, calculateTopPlateVoltage replaces calculateTrialVoltageAndThreshold, and compareComparatorInputs replaces compareInputToThreshold. evaluateHeldVoltage is removed: the capacitor array samples charge, and its floating top-plate voltage changes with switching. Historical snapshots retain their earlier interfaces.

## Earlier root migration on 2026-10-24

| Original location | Current location |
|---|---|
| Root `main.m` | `modeling/matlab/main.m` |
| Root `matlab/+adc/` | Functions now distributed between `modeling/matlab/+converterModel/` and `modeling/matlab/testing/` |
| Root `experiments/` | Current performance-test runner in `modeling/matlab/testing/` |
| Root `results/` | Preserved historical runs in `modeling/matlab/results/sar_ideal/` |
| Root model, architecture, and baseline documents | `modeling/matlab/documentation/` |
| Supplied manual in the root | `references/analog_devices/analog_devices_testing_data_converters.pdf` |

Absolute paths inside old MAT files and links in previous conversations may be stale. Use these tables to locate the corresponding files rather than rewriting historical outputs. After migration, close old editor tabs and open the current main.m. Restart MATLAB if an existing session retains obsolete search paths; main adds its current paths for the session and does not call savepath.

## Result management

Each completed run has a `run_<UTC_timestamp>_<unique_identifier>` directory with configuration, tool version, metric definitions, and a source snapshot. Failed exports retain a hidden `.incomplete_run_*` directory. Generated results are excluded from Git by default. Archive formal milestones with their configuration and source, and keep simulation results separate from physical measurements.
