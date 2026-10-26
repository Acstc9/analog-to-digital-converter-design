# Model and Analysis Definitions (schemaVersion 3)

Reference: ADI Testing Data Converters, Section 5.2, in the project's references/analog_devices directory. The root documentation/ANALOG_DEVICES_REFERENCE_ALIGNMENT.md maps measurement decisions to printed and file pages. The capacitor switching principle is additionally described in Analog Devices, [Successive-Approximation-Registers: SAR and Flash ADCs](https://www.analog.com/en/resources/technical-articles/successive-approximation-registers-sar-and-flash-adcs.html), DAC section and Figure 3. The explicit bias and circuit parameter values below are project assumptions.

## Capacitor array and charge conservation

The converter uses one single-ended, binary-weighted array with a common top plate and a unit dummy capacitor. For N bits, unitCapacitorCounts is [2^(N-1), ..., 2, 1, 1], with the dummy last. Ideal unit capacitors match; each weighted branch represents a parallel group of units. The implementation stores N+1 branch capacitances rather than allocating every unit separately. Default unitCapacitanceFarads is 10 fF, giving nominal total capacitance 2^N times the unit value. This is a project scale choice, not a sized transistor-level design.

createCapacitorArray runs once per simulated device. nominalCapacitanceFarads contains the intended weights and capacitanceFarads contains the actual values used in all charge calculations. These arrays are initially equal. The latter is the future mismatch entry point; no random generator or nonideal mismatch is currently present. Any future fixed mismatch must remain the same across all samples and bit decisions of that device. Changing actual capacitances must affect both the sampled charge and the switching denominator.

During sampling, every bottom plate, including the dummy, is connected to the input and the common top plate is clamped to samplingTopPlateVoltageVolts. At the sampling edge the input is evaluated once, the clamp is released, and the following charge is retained on the isolated common node:

```text
sampledTopPlateChargeCoulombs = sum(capacitanceFarads) *
    (samplingTopPlateVoltageVolts - sampledInputVolts)
```

All bottom plates then connect to minimumInputVolts. The top node is solved from charge conservation:

```text
topPlateVoltageVolts = (sampledTopPlateChargeCoulombs +
    sum(capacitanceFarads .* bottomPlateVoltageVolts)) / sum(capacitanceFarads)
```

It is the total charge on the floating common node that remains constant. Individual capacitor charges redistribute when switches change. No independent sample-and-hold buffer is assumed: this same capacitor array samples the input and produces the comparison residual. Its floating top-plate voltage changes during conversion, so it is not the constant sampled-input diagnostic stored in heldInputVolts.

## Successive decisions and comparator-reference bias

Each conversion starts with all decision bits clear and all bottom plates at minimumInputVolts. From the most significant bit to the least significant bit, the current branch switches to maximumInputVolts. The model solves the resulting top-plate voltage and compares it against an explicit ideal voltage-source reference:

```text
comparatorReferenceVolts = samplingTopPlateVoltageVolts + comparatorReferenceShiftVolts
keepTrialBit = comparatorReferenceVolts >= topPlateVoltageVolts
```

The reference drives the ideal comparator's positive input; the floating top node drives its negative input. Equality retains the bit. Rejected branches switch back to minimumInputVolts and the node voltage is solved again; accepted branches remain high. The dummy stays at minimumInputVolts throughout conversion. Digital output is N-bit straight binary stored in uint32, supporting resolutions from 1 to 24 bits.

Numerically, charge summation and division can leave a tiny residual at exact equality. The comparator treats differences within eight floating-point spacings at the largest absolute input/reference/clamp voltage as a tie. This roundoffToleranceVolts is a numerical guard, not physical noise or offset; differences below this guard are not resolved. It is recorded in optional traces and is distinct from the intentional half-LSB reference bias.

For matched capacitors, define LSB = (Vmax - Vmin)/2^N. The weighted bottom-plate voltage is Vmin + trialCode*LSB. Substituting the sampled charge into the node equation gives:

```text
topPlateVoltageVolts = samplingTopPlateVoltageVolts - Vin +
    Vmin + trialCode*LSB
```

Therefore the bit is retained when Vin >= Vmin + trialCode*LSB - comparatorReferenceShiftVolts. The default reference shift is nominal LSB/2. This explicitly assumed bias preserves the previous ideal transitions at Vmin + (k - 0.5)*LSB, following ADI Figures 5.26 and 5.29. It is an intentional circuit reference, not random comparator offset or an unexplained subtraction from a calculated threshold. A zero bias instead produces integer-LSB transitions. The testing chapter supplies the transfer convention, not this bias implementation.

main.m and createDefaultConfiguration compute the default bias from resolution and reference span. Programmatic changes to those fields after creating a configuration require deliberate bias updates if retaining the half-LSB convention. samplingTopPlateVoltageVolts defaults to 0 V. References, clamp sources and comparator common-mode range are idealized; the model does not check a transistor implementation's supply-rail feasibility.

At the default bias, the mathematical description remains clip(floor((Vin - Vmin)/LSB + 0.5), 0, 2^N - 1). This expression describes the ideal transfer; it is not used to implement conversion. The model performs capacitor switching and successive comparisons. Floating-point charge calculations need not reproduce the old direct-threshold arithmetic exactly at mathematical transition boundaries; inspect recorded execution evidence rather than claiming universal bit-exact equivalence.

Nominal reconstruction is Vmin + code*LSB, independently of physical capacitor values and comparator bias. Future capacitor errors affect conversion, not this digital interpretation of the output code. With the default bias, quantization error is within +/-0.5 LSB away from endpoint saturation; the bound does not hold throughout the entire nominal input range. overrangeMask indicates inputs outside [Vmin, Vmax), not merely endpoint output codes.

At 0 dBFS, a centered sine reaches Vmin and Vmax. An exact Vmax sample converts to the maximum code, reconstructs to Vmax - LSB, and sets overrangeMask under the existing half-open-range convention. FFT includes this sample; the flag neither rejects the run nor removes endpoint effects from the analysis.

Optional single-sample traces contain trialCodes, trialTopPlateVoltageVolts, bottomPlateVoltageVolts (one N+1-branch row per trial), comparatorReferenceVolts, roundoffToleranceVolts, keepTrialBit, trialUpdateTimeSeconds and decisionTimeSeconds. Trial snapshots precede rejection/retention updates. finalTopPlateVoltageVolts describes the final accepted switching state, not necessarily the last trial state.

## Source and chronological timing

The coherent continuous source is represented analytically as offset + peakAmplitude*sin(2*pi*frequency*time). It returns a function of time, not a precomputed converter record. The test selects frequency = coherentCycleCount*sampleRateHz/sampleCount.

amplitudeDbfs must be finite and at or below 0; the default remains -1 dBFS. The source midpoint is (Vmin + Vmax)/2 and its peak amplitude is (Vmax - Vmin)/2 * 10^(amplitudeDbfs/20). Set amplitudeDbfs to 0 in main.m for a full-scale sine. Rerunning the entire script updates dependent converter, source and analysis values. The plot reports these analytic sine bounds, not the minimum and maximum reconstructed output values.

simulateConverter creates the capacitor array, then processes one sample completely before starting the next. Sampling edges remain n/sampleRateHz for n = 0 through sampleCount-1. At each edge, sampleCapacitorArray evaluates the source and captures charge; convertSampledChargeToCode completes all N decisions; the scheduler stores the result and proceeds to the next edge.

The acquisition interval ends at each sampling edge and has duration acquisitionDurationSeconds. Switches and sources are ideal and settle instantaneously, so only the source value at the edge needs evaluation. The first acquisition starts before time zero. The common node floats from the sampling edge until the next acquisition begins at (n+1)/sampleRateHz - acquisitionDurationSeconds. During the hold interval, total top-node charge is conserved but switching changes its voltage. No continuous transient integration is performed.

For decision j = 1 through N, the trial update occurs at sampleTimeSeconds + (j-1)*bitDecisionDurationSeconds; comparison occurs one decision duration later. A rejected branch returns low at that decision. Output becomes available at sampleTimeSeconds + N*bitDecisionDurationSeconds. Fixed intervals are ideal scheduling assumptions, not settling or comparator-delay laws. A decision coincident with acquisition start uses the old sampled charge before acquisition resumes.

Defaults are 200 ns acquisition and 25 ns per bit. At 12 bits and 1 MS/s, conversion completes 300 ns after sampling; the next acquisition starts 800 ns after sampling. Acquisition duration + N*bit-decision duration must fit within 1/sampleRateHz. Simulated circuit time is independent of MATLAB execution time.

Saved sampling results retain timeSeconds and heldInputVolts (captured input voltage), adding sampledTopPlateChargeCoulombs. The legacy scalar holdEndTimeSeconds remains the record endpoint sampleCount/sampleRateHz. acquisitionStartTimeSeconds and holdIntervalEndTimeSeconds store per-sample boundaries. Conversion results include completionTimeSeconds and finalTopPlateVoltageVolts. result.capacitorArray records the device capacitances. Existing result.stimulus.timeSeconds and inputVolts remain sampled-input diagnostics. FFT uses sampleRateHz, not internal bit rate or latency.

## FFT

In the selected project profile following ADI Figure 5.66, record length is a power of two, cycle count is an odd prime, and Fin = cycles*Fs/M is strictly below Nyquist. A rectangular window is used, with each coherent fundamental or harmonic occupying one bin. After removing the mean, compute MATLAB fft/M. Double the single-sided powers except at DC and Nyquist. Their sum equals the mean square of the centered samples.

Zero dBFS is the mean-square power of a full-scale sine with peak amplitude (Vmax - Vmin)/2. The plot shows power per bin in dBFS, not dBFS/Hz. Defaults are M=16384, cycles=997, -1 dBFS, and maximum harmonic order 6.

The spectrum's analysisSettings structure records windowName (Rectangular), frequencyBinWidthHz (Fs/M), equivalentNoiseBandwidthHz (Fs/M for this window), analysisBandLimitsHz ([0, Fs/2]), excludedDirectCurrent (true), minimumHarmonicOrder (2), maximumHarmonicOrder (configured), and spectralReference (Full-scale sine mean-square power). The exported summary includes the same settings. The analysis band includes Nyquist; DC is excluded from metric integration. Default bin width and equivalent noise bandwidth are both 61.03515625 Hz. These settings describe the existing calculation, not a new window or bandwidth filter.

The spectrum plot marks the fundamental, selected harmonics and largest spur used by SFDR, and presents analysis conditions and metrics with amplitude-corrected ENOB identified explicitly. These annotations do not change frequency-bin powers or metric calculations. There is no additional time-domain plot or toolbox dependency.

| Output | Definition |
|---|---|
| snrDb | Fundamental power divided by noise power excluding DC, fundamental, and harmonics 2-6; reported as positive dB for the baseline. |
| snrFullScaleDb | Full-scale sine power divided by the same noise power, in dB. |
| sinadDb | Fundamental divided by all non-DC, nonfundamental power, in dB. |
| thdDb | Sum of harmonic powers 2-6 divided by fundamental power, normally negative dBc. |
| sfdrDb | Fundamental divided by the largest non-DC, nonfundamental bin, normally positive dBc. |
| worstNonharmonicSpurDbc | Largest bin excluding DC, fundamental, and selected harmonics divided by fundamental power, normally negative dBc. |
| fundamentalDbfs | Fundamental divided by full-scale sine power, expressed in dBFS. |
| noiseFloorDbfsPerBin | Mean linear power of noise bins divided by full-scale sine power, expressed in dBFS; do not average dB values. |
| enobBits | (SINAD - 1.76 - fundamentalDbfs)/6.02, following ADI Equation 5.23. |
| enobUncorrectedBits | (SINAD - 1.76)/6.02, retained only as a diagnostic comparison with previous reports. |

Harmonics are folded into the first Nyquist zone. Configurations with coincident harmonics or harmonics overlapping DC or the fundamental are rejected to avoid double-counting. Distortion above the selected maximum order remains in the residual power used for SNR. The harmonics table reports each order's bin and dBc level. An absent fundamental is rejected with an explicit error rather than returning meaningless ratios. Exact zero residual or harmonic power can still produce infinite ratios for a valid signal; metrics are not artificially capped. Nonfinite intermediate power is rejected. The returned spectrum includes the bin masks and integrated component powers for inspection. Figure limits extend below the finite noise-floor estimate when needed, including at 24-bit resolution.

Finite-record quantization error can be correlated with the input. The expression 6.02N + 1.76 + amplitudeDbfs is an approximation, not an exact requirement for every record. The current experiment uses one deterministic record; repeating it does not provide random-noise averaging benefits. Noncoherent windows, random multi-record averaging, two-tone testing, DC noise, and DNL/INL are not implemented. Their manual settings must not be applied directly to this analyzer.

## Scope

The model is an ideal switched-capacitor circuit model with charge conservation, ideal voltage references and clamp source, and an ideal comparator with an explicitly configured reference voltage. No jitter, thermal noise, mismatch, unintended comparator offset, regeneration time, capacitor nonlinearity, settling, reference impedance/noise, parasitic capacitance, switch charge injection, leakage, supply limits or transistor equations are included. Quantization error in the FFT is not an additional injected noise source. Absolute capacitance controls charge scale; without these nonidealities the ideal transfer depends on capacitance ratios.

## Numerical validity and provenance

Only configuration schemaVersion 3 is accepted. ImplementationVersion 3.0.0 introduces the capacitor topology, charge state, switching, and explicit comparator-reference assumptions. Default ideal transfer and spectral measurement conventions are retained, but schema 2 configurations do not specify this circuit. Replay historical snapshots or deliberately migrate their settings with capacitance, clamp, bias and timing values. Keep exportFormatVersion 3 and historical outputs intact.

Implementation 3.0.1 adds spectrum annotations and analysisSettings metadata without changing the converter, FFT normalization, default settings or metric definitions. Configuration schemaVersion and exportFormatVersion remain 3; existing field meanings are preserved.

Implementation 3.0.2 permits 0 dBFS input and displays configured amplitude and analytic sine voltage bounds. The -1 dBFS default, converter transfer, overrangeMask convention, FFT normalization and metric definitions remain unchanged. Configuration schemaVersion and exportFormatVersion remain 3.

Converter values, sample times, charge calculations and source amplitude must be representable in double precision. The analyzer remains a known-tone coherent analyzer, not an automatic detector of arbitrary input coherence. A sine with no measurable fundamental at its configured bin fails explicitly.

Source handles are runtime-only. Saved runs contain numeric source parameters, configuration, device capacitances, sampled input and charge, timing, output codes and analysis. Each exported run captures MATLAB sources and this contract with SHA-256 checksums. See results/README.md for replay, completion and JSON conventions.
