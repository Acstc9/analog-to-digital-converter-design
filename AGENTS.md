# Converter Project: Assistant Instructions

Read README.md, coding-style/matlab-coding-style.md and literature/README.md first. Before MATLAB changes, read both notebooks in documentation and inspect the actual current source. This is the completed instructor-guided working project; old sibling-directory instructions are historical.

## User preferences

- All project-authored text is English. Conversation may be Chinese. Teach in small batches, identify the call chain, and link exact current file lines.
- Prefer simple physical steps, descriptive names and minimal changes. Avoid dense nested expressions and unnecessary aliases. Do not introduce speculative extension points, safeguards or frameworks.
- Keep parameters in sim-config/createSimulationConfiguration.m. Run the entire testbench/simConventionalSarADC.m after changing them. Do not restore main.m, startup scripts, validators or a separate software-test runner without a request.
- The user deliberately removed validation assertions, harmonic folding, runtime version metadata, analysisSettings, file export and source snapshots. Do not restore them merely because older documentation mentions them.
- No automatic result saving, archives per run or console report. The current run stays in the MATLAB workspace and opens a figure.
- Preserve original instructor attachments, references, measured data and the retained empty codeDensityTest.m and drawing template. Do not implement placeholders without a request. Do not add new notebook lessons unless requested.

## Model boundaries

- models/cbwSarADC.m creates one capacitor array and owns both the chronological sample-convert-store loop and MSB-to-LSB control loop. It returns only a double column vector of integer-valued digital codes. Do not restore analog diagnostic outputs or a separate runSARConversion layer.
- Four component functions serve the model: synthesizeBinaryCDAC, sampleInputOntoCDAC, calculateTopPlateVoltage and compareVoltages. The voltage solver expresses CDAC physics, not an additional physical device. Switching remains directly in the model.
- generateCoherentContinuousSineWave returns a function of time; preserve Coherent in its name. Sample once, complete that conversion, then take the next sample. Do not precompute all inputs before conversion.
- samplingResult contains the sample time, input voltage and captured total top-node charge. The model adds bottom-plate connections and computed top-plate voltage. Reference switching and post-switch voltage solving do not belong in the sampler.
- Use nominal binary-weighted capacitors plus one unit dummy, with capacitances in fF, charge in fC and volts unchanged. Do not add actual-capacitance duplicates or nonideality hooks yet.
- Sample with the top plate clamped to 0 V and all bottoms at the input. Release the top clamp; switch bottoms low, then perform successive trials. Conserve total top-node charge, not individual branch charge. The dummy stays low during conversion.
- Keep the explicit half-LSB comparator-reference bias and direct two-input >= comparison. Do not restore the removed numerical tolerance, rounding or explicit state machine. Floating-point arithmetic remains approximate.
- Use referenceLowVolts/referenceHighVolts, not supply-rail names. Keep n/Fs sample times; no acquisition or bit-decision durations are currently modeled.
- Retain the instructor's cbwSarADC identifier; the source does not define the expansion of CBW.

## Analysis and display

- processAdcData converts codes to nominal volts, subtracts the mean, computes fft/N and forms a single-sided power spectrum by doubling interior bins only.
- The current coherent profile uses a power-of-two record and an odd prime cycle count. Defaults are 16384 samples, 997 cycles, -1 dBFS and harmonic orders 2-6. Document the assumption maximumHarmonicOrder * coherentCycleCount < sampleCount / 2; do not add alias folding, while loops or replacement validation.
- Preserve the full-scale sine power reference, noise and spur masks, totalPowerVoltsSquared, and zero-based FrequencyBin table values. MATLAB indices add 1.
- Keep amplitude-corrected enobBits and separate enobUncorrectedBits. Zero power gives -Inf dBFS; no realmin or artificial floor.
- plotFrequencySpectrum has no returned handle. Keep classic-blue stems [0, 0.447, 0.741], width 0.5, no markers, Frequency (kHz), Power (dBFS), a short title, grid and the five-metric Performance panel. Keep display limits [-160, 5] dBFS and x limits from Fs/2. No harmonic annotations, legend, analysis panel or plotting framework.

## Coding and verification

- Follow the maintained coding style: two-space indentation, spaced parentheses/operators, camelCase and clear structure-based configuration. Prefer names to excessive comments and avoid ellipsis continuations in ordinary calculations.
- Manually inspect every changed numeric result-buffer initializer. Pending results, including outputCodes, must start with NaN in double storage. Only the explicitly cleared SAR register starts at uint32(0). Known connection voltages and completed logical masks are not pending results.
- Do not hide missing data by integer-casting, replacing or omitting NaNs. Code Analyzer alone does not verify this rule.
- Avoid global, genpath, savepath and clear all. Converter functions have no file or plot side effects and do not depend on the testbench or FFT.
- Verify substantive changes with one normal MATLAB run and small focused checks; use temporary scripts, not a permanent test suite. MATLAB is installed at /Applications/MATLAB_R2026a.app/bin/matlab. Record evidence and limitations in README.md. No subagent delegation is required.

## Preservation and publication

- Maintain the two notebooks in documentation. Keep the coherent-sampling rationale and update its code links when paths change.
- The ADI testing chapter controls applicable methodology; distinguish its recommendations from project assumptions and unimplemented capabilities. Do not claim full manual compliance.
- Original books and instructor files are local-only under literature/source-documents/references. One-time migration archives and their integrity manifest are under literature/source-documents/project-history. Do not upload these or silently discard them.
- The remote remains Acstc9/analog-to-digital-converter-design, and the formal local folder remains ADC OCT 2026 version. Preserve Git history; do not reinitialize or force-replace it. The temporary adc-instructor-guided directory is retired by the final transition.
