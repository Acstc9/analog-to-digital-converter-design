# Reference Index and Alignment

The supplied Analog Devices testing chapter is the controlling methodological reference where applicable. This project implements an ideal SAR converter and a coherent single-tone FFT experiment, not every method in the chapter. Recommendations, project choices and unimplemented features are distinguished below.

## Analog Devices: Testing Data Converters

Local source: `source-documents/references/analog_devices/analog_devices_testing_data_converters.pdf` (94 pages). It is Chapter 5 of Analog-Digital Conversion, supplied for study. Printed page 5.x corresponds to PDF file page x+2; file pages below start at 1.

SHA-256: `cbf160d61d7dd6fea6b880010c41cd7c229e8f5ff80cda592cf038c6203b6207`.

| Topic | Source | Current implementation |
|---|---|---|
| Ideal code transitions | Figure 5.29, printed 5.31 / PDF 33 | Half-LSB transitions with nominal code-times-LSB interpretation; an explicit comparator bias is the project's circuit realization assumption |
| Below-full-scale ENOB | Equation 5.23, printed 5.51 / PDF 53 | Amplitude-corrected ENOB plus a separately retained uncorrected value |
| FFT record length | Figure 5.65, printed 5.62 / PDF 64 | 16384 points follows the analyzer example, not a unique required length |
| Coherent sampling | Equation 5.29 and Figure 5.66, printed 5.62-5.63 / PDF 64-65 | Integer cycles, power-of-two baseline record and an odd prime cycle choice; no runtime validator |
| Dynamic metrics | Figure 5.68, printed 5.65 / PDF 67 | Harmonics 2-6 by default; SNR excludes those harmonics, SINAD includes their distortion, SFDR includes harmonics among possible spurs |
| Spectral reference | Figure 5.64, printed 5.62 / PDF 64 | The plot uses full-scale-sine-referenced power per bin in dBFS; harmonic levels and THD use dBc |

The 1 MS/s rate, 997 cycles, 10 fF unit capacitance and explicit comparator bias are project choices. The -1 dBFS default provides modest headroom; it is adjustable and is not a universal optimum. A full-scale sine test characterizes that amplitude and frequency, not static linearity or all operating conditions.

Keeping selected harmonics below Fs/2 is the current project's deliberate simplification. Alias folding, noncoherent window processing and a time-domain display are not implemented. The rectangular coherent FFT uses fft/N and single-sided power; its ordinate is power per bin, not a power spectral density per hertz. A fixed display range does not floor the stored powers.

Static DNL/INL, code-density tests, laboratory source/clock quality, jitter and two-tone tests require their own procedures. The empty codeDensityTest.m does not implement them. Full manual compliance or real-device performance is not claimed.

## Physical CDAC principle

Analog Devices, [Successive-Approximation-Registers: SAR and Flash ADCs](https://www.analog.com/en/resources/technical-articles/successive-approximation-registers-sar-and-flash-adcs.html), DAC discussion and Figure 3, describes capacitor switching and charge redistribution. The present model uses a single-ended binary-weighted array with a unit dummy. The 0 V sampling clamp, unit capacitance and intentional half-LSB comparator-reference source are explicit project assumptions, not requirements of that article.

## Additional supplied books

- Understanding Delta-Sigma Data Converters, second edition: `source-documents/references/about fft/eetop.cn_Understanding Delta-Sigma Data Converters, 2nd edition.pdf`. Appendix A, printed 489-491 / PDF 495-497, discusses FFT noise-bandwidth interpretation. The current minimal plot omits bandwidth metadata; its power definitions are unchanged.
- Franco Maloberti, Data Converters: `source-documents/references/books on converters/book-data-converters-maloberti.pdf`. Retained as a broader converter reference; this project does not claim chapter-by-chapter implementation coverage.

## Instructor materials and local preservation

The original archive and extracted scaffold are retained under `source-documents/references/coding style requirements/`, including the original coding-style document. They are unchanged local source materials. The public maintained interpretation is [MATLAB coding style](../coding-style/matlab-coding-style.md); the current simple stem display is an explicitly approved user exception to the original plot styling.

`source-documents/project-history/` contains the one-time pre-transition source/documentation archives and a SHA-256 preservation manifest. Generated run files are excluded. The entire `source-documents/` directory is ignored by Git; fresh clones contain this reference index, not the supplied books or local archives. None of these documents is needed to execute the MATLAB testbench.
