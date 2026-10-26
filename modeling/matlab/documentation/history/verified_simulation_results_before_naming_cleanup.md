# Verified Baseline: Implementation 2.1.0

Date: 2026-10-25 (Europe/London). MATLAB R2026a Update 4, configuration schemaVersion 2, implementationVersion 2.1.0. The default numerical metrics remain consistent with the 2026-10-24 ADI-aligned baseline.

In a MATLAB session with default search paths restored, execution changed to modeling/matlab and ran main. The script set its paths, created a Visible=on FFT figure, printed metrics, and exported data. The editor's green Run button was not clicked through UI automation; the same complete script was executed.

## Configuration and metrics

12 bits, 1 MS/s, 0-1 V, 16384 samples, 997 cycles, Fin=60.85205078125 kHz, -1 dBFS, and harmonics 2-6.

| Metric | Executed result |
|---|---:|
| SNR | 73.043654 dB |
| SNRFS | 74.043666 dB |
| SINAD | 73.039112 dB |
| THD | -102.847274 dBc |
| SFDR | 96.876367 dBc |
| ENOB, ADI amplitude correction | 12.006499 bits |
| ENOB, uncorrected diagnostic | 11.840384 bits |
| Fundamental | -1.000012 dBFS |
| Noise floor | -113.174383 dBFS/bin |

ENOB is close to 12 bits. Its small excess above 12 reflects a finite record and the theoretical approximation, not additional physical resolution. Relative to the historical pre-ADI version, the default input frequency, thresholds, harmonic selection, and ENOB definitions changed during ADI alignment. Those definitions are unchanged by this review; differences from the pre-ADI baseline should not be interpreted as a design improvement.

## Executed checks

- Checked all 4095 internal thresholds just below, exactly at, and just above each transition across four voltage ranges: 0-1 V, 0-3.3 V, -1.65 to 1.65 V, and -0.7 to 1.3 V. All 49140 conversion inputs matched the ADI half-LSB convention, including floating-point boundary equality. Adjacent values were generated using eps at each threshold.
- Checked the known 3-bit decision trace, endpoint saturation at 1 and 24 bits, unsupported/missing configuration schemas, and numerically unresolvable voltage ranges.
- Confirmed that changing Fs alone preserves the normalized ideal stimulus sequence exactly.
- An independent synthetic signal with a ninth harmonic and a Nyquist component verified alias folding to bin 7411, THD=-40 dBc within 1e-8 dB, fundamental power 0.08 V^2, and residual noise power 1e-6 V^2 within 1e-12 V^2. Total FFT power matched time-domain mean square within 1e-14 V^2.
- Constant output and a -100 dBFS sine that quantized to a constant code both failed with adc:MissingFundamental, rather than generating invalid metrics.
- Following the approach on ADI printed pages 5.65-5.66, checked multiple resolutions. All SINAD values were within 0.5 dB of the theoretical approximation:

| Resolution in bits | Measured SINAD, dB | Theoretical, dB | Corrected ENOB |
|---|---:|---:|---:|
| 8 | 49.058494 | 48.920000 | 8.022951 |
| 10 | 61.011651 | 60.960000 | 10.008611 |
| 12 | 73.039112 | 73.000000 | 12.006499 |
| 24 | 145.301633 | 145.240000 | 24.010238 |

- MATLAB Code Analyzer: zero diagnostics.
- The default and 24-bit FFT PNGs were visually inspected. The 24-bit plot now extends to -210 dBFS, exposing the noise floor that the former -160 dBFS limit clipped.
- Raw simulation data, MAT/JSON, metric and harmonic CSV files, PNG, and PDF were generated.
- Snapshot checksums match all copied sources and the current on-disk source. Saved MAT and returned result contain the same source metadata.
- A constructed reporting fixture verified separate JSON status entries for +Inf, -Inf, and NaN, including harmonic status. This is an export-format check, not a physical ADC measurement.
- A deliberately broken export was retained as an incomplete directory in a temporary location; no completed run directory was published.
- All 47 pre-existing result files matched their pre-review SHA-256 checksums. The two notes were verified: device note title-only, testing note content preserved apart from heading nesting. Local documentation links and English-only text checks passed.
- No startup, run_tests, or tests directory was restored. These were one-off checks for the implementation change, not additional daily operating steps.

## Evidence location

Run: `results/sar_ideal/run_20261025_101333_tpe1dcbecf_2c5f_493b_8023_e6c7362b7d87/`, relative to the MATLAB subproject. review_resolution_checks.csv and review_verification.mat preserve the check table, threshold-input count, diagnostic count, and high-resolution plot limits. review_24bit_fft.png preserves the high-resolution plotting check. Source and model-contract snapshots are listed in summary.json.

The previous baseline document is retained at docs/history/baseline_before_adi_alignment.md. Old runs are unchanged; use the root migration table to resolve stale internal absolute paths.

Other MATLAB versions, Octave, circuit-level simulation, random nonidealities, noncoherent FFT, and laboratory instrument chains have not been verified and are outside the completed scope.

## Review changes and limits

The review corrected direct threshold evaluation for nonbinary voltage ranges, separated nominal output reconstruction from the internal DAC, enforced the declared configuration schema, added representability and missing-fundamental checks, exposed integrated FFT powers and masks, expanded plot limits when needed, preserved nonfinite JSON meaning, and made exports traceable and distinguishable from incomplete runs. Command-window metrics are displayed vertically for readability.

The original default transfer and metric definitions remain schema 2. The prime/power-of-two restrictions remain the selected project profile; their error wording no longer describes them as a universal mathematical requirement. The source snapshot is captured from disk at export time, so do not edit source during a run. The analyzer still assumes a known coherent tone and does not establish coherence for arbitrary imported data.

Normal-permission MATLAB execution emitted Java AWT package warnings but completed the numerical, graphics, and file checks successfully. No new nonidealities, startup script, or permanent testing framework was introduced.
