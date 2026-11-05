# Reference Index and Alignment

The Analog Devices testing chapter is the controlling methodological reference where applicable. This project implements an ideal SAR converter and a coherent single-tone FFT experiment, not every method in the chapter. Recommendations, project choices and unimplemented features are distinguished below.

## Analog Devices: Testing Data Converters

Source: Analog Devices, Analog-Digital Conversion, Chapter 5, Testing Data Converters (94 pages). Printed page 5.x corresponds to PDF file page x+2; file pages below start at 1.

SHA-256: `cbf160d61d7dd6fea6b880010c41cd7c229e8f5ff80cda592cf038c6203b6207`.

| Topic | Source | Current implementation |
|---|---|---|
| Ideal code transitions | Figure 5.29, printed 5.31 / PDF 33 | Half-LSB transitions with nominal code-times-LSB interpretation; an explicit comparator bias is the project's circuit realization assumption |
| Below-full-scale ENOB | Equation 5.23, printed 5.51 / PDF 53 | Amplitude-corrected ENOB using the measured fundamental level |
| FFT record length | Figure 5.65, printed 5.62 / PDF 64 | The ADI example uses 16384 points. This project uses 1024 for the full-band single-tone test. |
| Coherent sampling | Equation 5.29 and Figure 5.66, printed 5.62-5.63 / PDF 64-65 | Integer cycles, power-of-two baseline record and an odd prime cycle choice; no runtime validator |
| Dynamic metrics | Figure 5.68, printed 5.65 / PDF 67 | SNDR (SINAD) includes noise and distortion. Individual harmonics and SFDR are not reported. |
| Spectral reference | Figure 5.64, printed 5.62 / PDF 64 | Full-scale-sine-referenced dBFS normalization and individual positive-frequency bins, without smoothing. |

The 1 MS/s rate, 61 cycles, 10 fF unit capacitance and explicit comparator bias are project choices. The test uses a -1 dBFS coherent sine centered at half the reference voltage to leave headroom at both ends of the input range. See [ADI Data Conversion Handbook, section 2.5, printed page 2.113](https://www.analog.com/media/en/training-seminars/design-handbooks/Data-Conversion-Handbook/Chapter2.pdf) for the SINAD test level. A single-tone test characterizes the converter at the selected amplitude and frequency.

The coherent FFT is normalized as fft/N * 4/p.vRef so a full-scale sine below Nyquist has unit positive-frequency peak magnitude. processAdcData prepares singleSidedTransform once, from DC through Nyquist, with DC set to zero and 1/sqrt(2) amplitude weighting at Nyquist. Both metrics and plotting use this shared complex spectrum. The display follows the raw-spectrum approach in the toolbox examples, using dbv with MATLAB stem on a linear frequency axis. It omits DC and shows individual bins without the averaging in plotSpectrum or another Nyquist correction. calculateSNR uses nsig = 0 for the coherent tone. Its result is reported as SNDR (SINAD) because harmonics remain in the denominator. This toolbox adaptation does not imply that the ADI chapter requires this software. The panel reports SNDR and amplitude-corrected ENOB. The correction accounts for the -1 dBFS input and does not establish measured full-scale performance. The fundamental level used for correction is calculated with dbv from the shared spectrum.

Static DNL/INL, code-density tests, laboratory source/clock quality, jitter and two-tone tests require their own procedures. The empty codeDensityTest.m does not implement them. Full manual compliance or real-device performance is not claimed.

## Physical CDAC principle

Analog Devices, [Successive-Approximation-Registers: SAR and Flash ADCs](https://www.analog.com/en/resources/technical-articles/successive-approximation-registers-sar-and-flash-adcs.html), DAC discussion and Figure 3, describes capacitor switching and charge redistribution. The present model uses a single-ended binary-weighted array with a unit dummy. The 0 V sampling clamp, unit capacitance and intentional half-LSB comparator-reference source are explicit project assumptions, not requirements of that article.

## Additional references

- Richard Schreier, Shanthi Pavan and Gabor C. Temes, Understanding Delta-Sigma Data Converters, second edition: Appendix A, printed pages 489-491 / PDF pages 495-497, discusses full-scale-sine normalization and FFT noise-bandwidth interpretation. The current raw-bin dBFS display is not a noise density in dBFS/Hz; SNDR uses the combined non-DC residual power.
- Franco Maloberti, Data Converters: a broader converter reference. This project does not claim chapter-by-chapter implementation coverage.
- Richard Schreier, Delta Sigma Toolbox: calculateSNR operates on the selected FFT band; dbv converts linear magnitudes to decibels. The current coherent test uses single-bin signal selection.

Reference books and toolbox source are not bundled with this repository. The [MATLAB coding style](../coding-style/matlab-coding-style.md) documents the project's implementation conventions.
