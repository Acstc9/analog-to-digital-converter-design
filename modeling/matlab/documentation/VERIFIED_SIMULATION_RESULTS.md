# Verified Simulation Results

## Main-script amplitude and range control: implementation 3.0.2

Date: 2026-10-26. Executed the complete main.m script twice with MATLAB R2026a. The default 12-bit, 0-1 V, 1 million samples/s, -1 dBFS run matched the implementation 3.0.1 conversion and spectrum structures exactly. Default settings were restored after verification.

For the second run, only main.m settings changed: 10-bit resolution, -1 to 1 V converter range, 500000 samples/s, and 0 dBFS sine amplitude. The record retained 16384 samples and 997 coherent cycles. Checks confirmed the derived half-LSB comparator bias, LSB size, sine midpoint and peak amplitude, coherent input frequency, FFT frequency axis, and full-scale sine power reference. Every output code matched the expected ideal rounded-and-saturated transfer function for this record. The sampled lower and upper endpoints produced codes 0 and 1023. The existing overrange flag included the single sample exactly at the upper endpoint; that sample remained in the FFT.

The full-scale run produced SINAD of 61.567651 dB and amplitude-corrected ENOB of 9.934890 bits. Its exported spectrum was visually inspected, including the added input amplitude and analytic sine voltage bounds. MATLAB Code Analyzer returned zero diagnostics for the four changed MATLAB files. These are two focused end-to-end checks, not an exhaustive parameter sweep; no permanent test suite was added.

[Default run and source snapshot](../results/coherent_sine_wave/run_20261026_000733_tpbee5f8eb_f899_48ab_9fab_569a104d4ee2/) and [full-scale run and source snapshot](../results/coherent_sine_wave/run_20261026_000739_tp2d56cf7e_9806_44b2_a5c8_5b0b2f3e68de/).

## Spectrum reporting: implementation 3.0.1

Date: 2026-10-25. Executed main.m once with MATLAB R2026a Update 4. The default conversion structure and every pre-existing spectrum field, including all metrics and frequency-bin powers, matched the implementation 3.0.0 baseline exactly. SINAD remains 73.039112 dB and amplitude-corrected ENOB remains 12.006499 bits. The four changed MATLAB files returned zero Code Analyzer diagnostics.

The additive analysisSettings metadata records bin width and rectangular-window equivalent noise bandwidth of 61.03515625 Hz, the 0-500 kHz analysis band with DC excluded, harmonics 2-6, and the full-scale sine power reference. The saved summary was checked for the expected bandwidth values. No converter, normalization, metric, or default-parameter changes were made; no toolbox or additional analysis mode was introduced.

The exported figure was visually inspected. One long label was split to avoid clipping, then the same verified numerical result was re-exported with the final source snapshot, without rerunning conversion. Nonzero selected harmonics are marked; exactly zero-power harmonics are omitted from the logarithmic plot and remain recorded in the harmonics table. No parameter sweep or permanent test suite was added.

[Numerical check run](../results/coherent_sine_wave/run_20261025_230850_tpaf0af990_3708_42cc_bdb2_035739da4f4d/) and [final report and source snapshot](../results/coherent_sine_wave/run_20261025_230948_tp4ec4eaff_9600_416e_9a4b_a63077b40506/).

## Capacitor charge redistribution: implementation 3.0.0

Date: 2026-10-25. Executed main.m once with MATLAB R2026a Update 4, using configuration schema 3 and export format 3. The model uses the selected single-ended binary capacitor array and dummy, sampled common-node charge, physical bottom-plate switching, and an explicit ideal comparator-reference bias of half a nominal LSB. No random mismatch or other nonideal effect was enabled.

Every default output code and the full spectrum structure matched implementation 2.4.0 exactly. SINAD remains 73.039112 dB and corrected ENOB remains 12.006499 bits. This is evidence for the default run, not a claim of bit-exact equivalence for every floating-point input or configuration.

One 3-bit example with branch weights [4, 2, 1, 1] and input 0.7 V produced trial codes 4, 6, 7 and top-node voltages -0.2, 0.05, 0.175 V. Compared with the explicit 0.0625 V reference, decisions were true, true, false; the final code was 6 and the rejected last branch returned the node to 0.05 V. Total floating-node charge agreed across the three trials within 6.31e-30 C of roundoff. A boundary input of 0.4375 V retained code 4 using the documented numerical tie guard. Code Analyzer returned zero diagnostics for the eleven changed or added source files.

[Saved run](../results/coherent_sine_wave/run_20261025_222154_tp67c654a7_522d_48d8_84d0_5f552af212e0/) and [verification record](../results/coherent_sine_wave/run_20261025_222154_tp67c654a7_522d_48d8_84d0_5f552af212e0/charge_redistribution_verification.json). The script remained temporary; no broad sweep or permanent test suite was added. This checks the ideal baseline, charge conservation, switching and one boundary, not transistor-level operation, random mismatch, settling or supply feasibility.

## Chronological ideal conversion: implementation 2.4.0

Date: 2026-10-25. Executed main.m once with MATLAB R2026a Update 4. The converter now captures one sample, completes its bit decisions, and stores the output before capturing the next sample. Default acquisition duration is 200 ns and bit-decision duration is 25 ns; these are ideal project timing assumptions. No nonidealities were added.

Every default output code and the entire spectrum structure matched implementation 2.3.0 exactly. SINAD is 73.039112 dB and corrected ENOB is 12.006499 bits. The main script completed in approximately 6.5 seconds on this machine, including reporting and plotting; this is one observation, not a performance benchmark.

A two-sample, 3-bit check converted 0.7 V and 0.3 V to codes 6 and 2. The first conversion completed before the next acquisition began. A trace of the first sample retained trial codes 4, 6, and 7 with decisions true, true, and false, at 25, 50, and 75 ns. MATLAB Code Analyzer reported zero diagnostics for the eight changed or added source files. No broad parameter sweep or permanent test suite was added.

[Saved run](../results/coherent_sine_wave/run_20261025_213631_tpd186fc90_6858_47df_b8f9_9a14c8dc7d4b/) and [verification record](../results/coherent_sine_wave/run_20261025_213631_tpd186fc90_6858_47df_b8f9_9a14c8dc7d4b/sequential_conversion_verification.json). The verification script remained temporary. MATLAB required normal local permissions to start; the sandbox attempt failed before simulation with its existing processor-feature error.

This check verifies the ideal numerical baseline and a small sequential example. Acquisition and holding remain ideal; physical settling, memory effects, and transistor-level timing are not validated. Configuration schemaVersion 2 and exportFormatVersion 3 retain their existing meanings, with explicit new timing parameters and numeric timing results documented in MODEL_DEFINITIONS.md.

## Ideal source and sampling separation: implementation 2.3.0

Date: 2026-10-25. Executed main.m once with MATLAB R2026a Update 4 and the default configuration. The generator retains Coherent in its name and supplies a continuous-time sine function; the sample-and-hold now owns sampling times and held values. Configuration schemaVersion 2, exportFormatVersion 3, SAR decisions, and spectrum definitions are unchanged.

The default output codes and entire spectrum structure matched implementation 2.2.0 exactly. SINAD remains 73.039112 dB and corrected ENOB remains 12.006499 bits. Changing the sine evaluation from sample index to physical time produced a maximum input-voltage rounding difference of 8.105738302788268e-13 V, without changing the default quantized output.

A short check confirmed equal held voltages within each interval, an update at the next sampling boundary, and NaN outside the recorded interval. Code Analyzer returned no diagnostics for the four changed source files. The verification script remained temporary; no new verification framework was added.

[Saved run](../results/coherent_sine_wave/run_20261025_203725_tp3f266608_065d_41eb_853a_8cd48f46587c/) and [continuous input versus held output](../results/coherent_sine_wave/run_20261025_203725_tp3f266608_065d_41eb_853a_8cd48f46587c/sample_and_hold.png). The source evaluator exists only during execution; run.mat saves numeric source parameters and sampling data. This check covers the default run and basic ideal holding, not a new exhaustive parameter sweep.

## Earlier naming migration: implementation 2.2.0

Date: 2026-10-25 (Europe/London). Executed with MATLAB R2026a Update 4. Configuration schemaVersion remains 2; implementationVersion is 2.2.0 and exportFormatVersion is 3.

This revision reorganizes and renames the implementation, clarifies display wording, and updates saved source and plot paths. It does not change converter equations, default settings, or metric definitions.

### Default configuration and results

12-bit resolution, 1 million samples/s, 0-1 V input range, 16384 samples, 997 coherent cycles, input frequency 60.85205078125 kHz, -1 dBFS amplitude, and harmonics 2-6.

| Metric | Executed result |
|---|---:|
| Signal-to-noise ratio | 73.043654 dB |
| Full-scale signal-to-noise ratio | 74.043666 dB |
| Signal-to-noise-and-distortion ratio | 73.039112 dB |
| Total harmonic distortion | -102.847274 dBc |
| Spurious-free dynamic range | 96.876367 dBc |
| Effective number of bits, amplitude corrected | 12.006499 bits |
| Effective number of bits, uncorrected | 11.840384 bits |
| Fundamental level | -1.000012 dBFS |
| Mean noise power per frequency bin | -113.174383 dBFS/bin |

The slight excess above 12 effective bits reflects a finite deterministic record and the theoretical approximation, not additional physical resolution.

### Checks executed for the naming migration

- Restored MATLAB's default search path, changed to modeling/matlab, and executed the complete main.m script. It created a visible spectrum, printed full metric descriptions and units, and saved the renamed artifacts. The editor's green Run button was not clicked through UI automation; the complete script behind that workflow was executed.
- Compared the entire configuration, stimulus, conversion, and spectrum structures against the previously verified implementation 2.1.0 run using exact equality including nonfinite values. All four structures matched exactly, including every output code and frequency-bin power.
- Removed the testing directory from the search path and executed the converter model independently. The known 3-bit, 0.70 V example retained trial codes 4, 6, and 7, decisions true, true, and false, and final code 6. This verifies the renamed converter helpers and their independence from performance-test tools.
- Exercised the renamed configuration-validation and missing-fundamental error paths.
- Executed a custom 8-bit, 1024-sample, 31-cycle configuration with a separate temporary output directory. The call produced 1024 output codes, its signal-to-noise-and-distortion ratio was within 0.5 dB of the theoretical approximation, and it did not create an additional visible figure.
- Rendered and visually inspected the default and 24-bit spectrum plots with full English descriptions. The high-resolution plot retained its adaptive lower limit of -210 dBFS.
- Verified all standard exported files, exportFormatVersion 3, completion status, and equality of the saved and returned result structures.
- Verified that the source snapshot contains exactly the 15 current MATLAB source files and MODEL_DEFINITIONS.md. Every copied file matched both its recorded SHA-256 checksum and the current file on disk.
- Started an independent MATLAB process with default search paths and loaded only the saved source snapshot. Replayed the saved configuration into a temporary output directory; configuration, stimulus, conversion, and spectrum matched exactly again.
- MATLAB Code Analyzer inspected all 15 current source files and returned zero diagnostics.
- All 95 pre-existing result files remained byte-identical. The reference manual's content and checksum are unchanged. The testing notebook retained its existing lesson content with updated title and links; the device notebook remains title-only.

These checks used temporary verification scripts. They did not add a permanent self-test suite or another daily entry point.

### Evidence

Implementation 2.2.0 run: [run_20261025_175425_tp4925fc9b_7ad2_44eb_a2d5_7b353fb2e52b](../results/coherent_sine_wave/run_20261025_175425_tp4925fc9b_7ad2_44eb_a2d5_7b353fb2e52b/).

- [Numerical verification record](../results/coherent_sine_wave/run_20261025_175425_tp4925fc9b_7ad2_44eb_a2d5_7b353fb2e52b/naming_migration_verification.mat)
- [Migration and preservation record](../results/coherent_sine_wave/run_20261025_175425_tp4925fc9b_7ad2_44eb_a2d5_7b353fb2e52b/naming_migration_verification.json)
- [Default frequency spectrum](../results/coherent_sine_wave/run_20261025_175425_tp4925fc9b_7ad2_44eb_a2d5_7b353fb2e52b/frequency_spectrum.png)
- [24-bit plotting check](../results/coherent_sine_wave/run_20261025_175425_tp4925fc9b_7ad2_44eb_a2d5_7b353fb2e52b/frequency_spectrum_24_bit_verification.png)
- [Saved summary and source checksums](../results/coherent_sine_wave/run_20261025_175425_tp4925fc9b_7ad2_44eb_a2d5_7b353fb2e52b/summary.json)

The previous full audit, including 49140 transition-boundary inputs and the 8/10/12/24-bit numerical checks, is preserved in [the pre-migration verification report](history/verified_simulation_results_before_naming_cleanup.md). Those earlier checks are not presented as newly executed migration checks. The [pre-Analog-Devices-alignment report](history/baseline_before_adi_alignment.md) remains historical evidence for a different mathematical convention.

### Scope and limits

The implementation remains ideal and assumes a known coherent sine-wave input. Nonideal circuit effects, noncoherent analysis, laboratory hardware, other MATLAB versions, and Octave were not verified in this migration. The source snapshot captures on-disk files during export, so avoid source edits during a run. MATLAB emitted its existing Java AWT package warnings, but both execution processes completed successfully.
