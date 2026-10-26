# Verified Baseline Before ADI Alignment

Verification date: 2026-10-24 (Europe/London).
Environment: MATLAB 26.1.0.3312084 (R2026a) Update 4.

Executed in a MATLAB batch session after restoring default search paths: main set its paths, created a visible FFT figure, and printed metrics. MATLAB Code Analyzer also inspected every MATLAB source file. The editor's green Run button was not clicked through UI automation; the same complete script was executed.

## Configuration and results

12 bits, Fs=1 MHz, input range [0, 1) V, 65536 samples, 997 cycles, Fin=15213.0126953125 Hz, -1 dBFS input, and harmonic analysis through order 10.

| Metric | Executed result |
|---|---:|
| SNR | 72.994777 dB |
| SINAD | 72.993102 dB |
| THD | -107.131788 dBc |
| SFDR | 98.206370 dBc |
| ENOB | 11.832741 bits |
| Fundamental power | -0.999985 dBFS |
| Approximate theoretical quantization SNR | 73.000000 dB |

This historical ENOB did not compensate for the -1 dBFS input backoff, so a value below 12 bits was consistent with the convention used at that time.

## Verification record

- The new entry point ran successfully. FFT figure Visible was on, a PNG was generated, and default SINAD was within 0.5 dB of the 73 dB approximation.
- startup.m, run_tests.m, and the tests directory were removed at the user's request.
- MATLAB Code Analyzer: zero diagnostics.
- The spectrum reused the previously inspected plotting logic and was exported again.
- JSON, CSV, MAT, PNG, and PDF files were generated.
- No circuit-level or transistor-level simulation was performed. Other MATLAB versions and Octave were not verified.

Historical run directory, relative to the MATLAB subproject after migration:

`results/sar_ideal/run_20261024_124051_tpc3ccdeb1_a2f0_4147_8db6_795812fd863a/`

Previous run directories and their verification.mat files were preserved. They document the old verification workflow, not a current entry point. The directory above corresponds to execution of main at that stage.

## Historical handoff status

The entry point ran successfully. The baseline had no random nonidealities and required no random seed. Further work depended on design goals such as input topology, CDAC switching, bit timing, or individual nonideality studies. The original diagram's optional nonideal blocks were not all implemented. Static code-density experiments could be added separately while reusing the successive-approximation converter.

This is a historical record. Use ../BASELINE.md for the ADI-aligned baseline.
