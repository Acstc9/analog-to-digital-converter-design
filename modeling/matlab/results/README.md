# Simulation Results

The repository includes the default implementation 3.0.2 run, run_20261026_000733_tpbee5f8eb_f899_48ab_9fab_569a104d4ee2, as its selected baseline. Other historical and newly generated runs remain local unless deliberately selected for version control. Historical links in verification documents may refer to those local-only records.

main.m calls runCoherentSineWaveTest, which creates a new results/coherent_sine_wave/run_<UTC_timestamp>_<unique_identifier> directory for each completed invocation.

| File or directory | Contents |
|---|---|
| run.mat | Complete configuration, metadata, source parameters, capacitor-array values, sampling/acquisition/hold times, sampled input and charge, output codes and completion times, final top-plate voltages, nominal reconstructed voltages, and spectrum. |
| summary.json | Configuration, references, tool version, metrics, harmonic components, integrated powers, and completion status. |
| metrics.csv | Scalar performance metrics using stable saved-field names. |
| harmonics.csv | Individual harmonic orders, frequency-bin indices, and levels. |
| spectrum.csv | Frequency in Hz and power per bin in dBFS. |
| frequency_spectrum.png / frequency_spectrum.pdf | Spectrum plots. |
| source_snapshot/ | The entry point, converter functions, testing functions, and model definitions used for the run. |

Historical runs remain in sar_ideal with their original names and contents. Their plots may be named fft.png and fft.pdf. Old configurations, error identifiers, and snapshots have not been rewritten. Some historical results contain verification.mat; that does not imply a separate daily self-test workflow. Resolve stale paths using [Project Structure](../../../documentation/PROJECT_STRUCTURE.md).

Implementation 2.3.0 introduced result.sampling with timeSeconds, heldInputVolts, and holdEndTimeSeconds. Implementation 2.4.0 retains these fields; holdEndTimeSeconds is still the record endpoint. It adds sampling.acquisitionStartTimeSeconds, sampling.holdIntervalEndTimeSeconds, and conversion.completionTimeSeconds for chronological device timing. Implementation 3.0.0 also saves result.capacitorArray, sampling.sampledTopPlateChargeCoulombs and conversion.finalTopPlateVoltageVolts. heldInputVolts remains the sampled input diagnostic, not the floating top-plate voltage during conversion. The source function handle is not saved; source parameters reconstruct it. Existing result.stimulus.timeSeconds and inputVolts are retained as sampled-input data.

## Export format 3

Implementation 2.2.0 introduced the current plot names and source layout. Current configuration definitions use schemaVersion 3, including the capacitor-array and explicit comparator-reference assumptions; earlier implementations used schemaVersion 2. A completed summary has status=complete and exportFormatVersion=3. Previous exportFormatVersion 2 used the former plot names and source paths.

Source snapshots contain main.m, +converterModel, testing, and documentation/MODEL_DEFINITIONS.md. metadata.sourceSnapshot lists the relative paths and SHA-256 checksums. To reproduce a saved configuration from the current format, use a fresh MATLAB session:

```matlab
savedRun = load('/absolute/path/to/run_directory/run.mat');
snapshotRoot = '/absolute/path/to/run_directory/source_snapshot';
addpath(snapshotRoot);
addpath(fullfile(snapshotRoot, 'testing'));
repeatedResult = runCoherentSineWaveTest(savedRun.result.configuration, ...
    '/absolute/path/to/new_results_directory');
```

Use an output directory outside the historical run so the original record remains intact. Running a snapshot's main.m instead uses the parameters in that script, which may differ from a saved programmatic call. Replay older formats using the paths and function names in their own snapshots.

Configurations saved before implementation 2.4.0 lack acquisitionDurationSeconds and bitDecisionDurationSeconds. Their snapshots remain the direct replay path. To use current source instead, create a current default configuration, deliberately copy the prior settings, and choose the timing values. Configurations before implementation 3.0.0 also lack unitCapacitanceFarads, samplingTopPlateVoltageVolts and comparatorReferenceShiftVolts. Supply these explicitly when migrating to schema 3. The nominal half-LSB bias depends on resolution and reference span; recompute it after changing those settings if that convention is intended. Current code does not silently infer circuit assumptions or physical timing from an old configuration.

Exports are staged in hidden .incomplete_run_* directories and renamed to run_* only after the standard files are written. Incomplete directories are retained when an export fails. Saved and returned results include the same final path and source metadata.

JSON cannot represent numeric infinities or NaN. A nonfinite metric is null in metrics and has an explicit +Inf, -Inf, or NaN entry in metricNonfiniteStatus. Finite metrics have no status entry. Harmonic rows include LevelDbcStatus. MAT and CSV preserve numerical nonfinite values. An absent fundamental fails before export rather than producing an invalid measurement.

Generated outputs are excluded from Git by default. Archive formal milestones with the source and configuration, not just the plot. Source snapshots are captured from disk during export; avoid editing files while a simulation runs.
