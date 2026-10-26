# Converter Testing Notes

## Sampling Parameter Rationale

Recorded: 2026-10-25 under configuration schemaVersion 2. The sampling rationale also applies to the current schemaVersion 3 coherent single-tone experiment.

This note preserves the reasoning behind the sampling parameters in main.m. Read it in order when revisiting coherent sampling. Intuition comes first; compact equations are collected near the end. This is a design rationale, not an additional execution step.

### 1. Start with a finite record

An input sine wave can continue indefinitely, but one FFT receives a finite list of samples. Two settings determine the record length:

- sampleRateHz: how many samples are taken per second.
- sampleCount: how many samples are included in this record.

For example, 100 samples at 1000 samples per second represent a 0.1-second record. The current 16384 samples at 1000000 samples per second represent 0.016384 seconds, or 16.384 ms.

The record period includes the interval from the last sample to the start of the next record. The elapsed time from sample 0 to sample M-1 is one sampling interval shorter. Do not confuse these two durations.

### 2. Why the ends of the record matter

The DFT, computed using an FFT algorithm, describes the samples through a periodic extension. Imagine repeating the same record:

```text
record -> identical record -> identical record -> ...
```

A record containing three complete sine-wave cycles can join naturally to its next copy. A record containing three and a quarter cycles generally resets from a different point on the sine wave when the next copy begins. The periodic extension then has a seam and is no longer the original pure sine wave.

Additional frequency components are needed to represent that periodic extension. The resulting spread across FFT bins is spectral leakage. It is an analysis effect, not proof that the original input or ADC generated those components.

The requirement is that the next theoretical sample, x[M], reconnects to x[0] with the same sine-wave phase. It does not require the last stored sample x[M-1] to equal the first sample. A special phase can also hide a value jump in a noncoherent record without making the tone coherent.

### 3. Choose an integer cycle count

A record containing an integer number of input cycles satisfies the coherent condition. With a fixed record duration, select an integer cycle count and calculate the required frequency.

For example, fitting three cycles into 0.1 seconds requires 30 cycles per second, or 30 Hz. The current experiment fits 997 cycles into 0.016384 seconds, requiring 60852.05078125 Hz.

This is why main.m specifies coherentCycleCount rather than an independent arbitrary input frequency. In the frequency-domain description, the tone lands on an exact FFT bin. The current fundamental is at zero-based bin 997.

Coherent sampling avoids the leakage caused by an off-bin ideal tone. It does not remove quantization error, harmonic distortion, or physical noise. Noncoherent testing is also possible, but requires a different treatment of windows and leakage than the current single-bin analyzer.

### 4. A separate question: does the record repeat too early?

Integer cycles solve the record-boundary problem. They do not guarantee that the samples visit many distinct phases before repeating.

Imagine a circle with 12 positions numbered 0 through 11. One full turn represents one sine-wave cycle. Record the starting position, then advance a fixed number of positions per sampling interval.

With a 12-sample record and three cycles, advance three positions at each step:

```text
0 -> 3 -> 6 -> 9 -> 0 -> 3 -> 6 -> 9 -> ...
```

Only four phase positions are visited. The same phase pattern appears three times in the record.

With a 12-sample record and five cycles, advance five positions at each step:

```text
0 -> 5 -> 10 -> 3 -> 8 -> 1 -> 6 -> 11 -> 4 -> 9 -> 2 -> 7 -> 0
```

All 12 positions are visited before returning to the start. The final return to zero is the next record's starting boundary, not an extra sample in the 12-point record. Twelve advances complete five full turns.

Both examples are coherent. Their internal phase repetition differs.

### 5. Coprime is a relationship between two numbers

A common divisor divides both numbers exactly. Two numbers are coprime when their only positive common divisor is 1.

| Record length | Cycle count | Greatest common divisor | Phase pattern repeats after |
|---:|---:|---:|---:|
| 12 | 3 | 3 | 4 sampling intervals |
| 12 | 5 | 1 | 12 sampling intervals |
| 12 | 1 | 1 | 12 sampling intervals |

Coprime length and cycle count avoid early repetition of the sampled phase sequence. Distinct phases do not necessarily mean distinct voltages: a sine wave has symmetry, and quantization can map different voltages to the same code.

Prime and coprime are different terms. Prime describes one integer; coprime describes a pair. Neither member of a coprime pair needs to be prime: 8 and 9 are coprime, although both are composite.

### 6. Why phase repetition matters to ADC measurements

Ideal quantization error is determined by the input sample; it is not an independently generated random number. Repeating a short input-sample pattern also repeats its error pattern. Such errors can concentrate into prominent discrete spectral lines.

Avoiding short phase repetition prevents this particular sampling artifact. It does not guarantee independent white quantization noise. The ideal converter remains deterministic, and finite-record metrics can differ slightly from theoretical noise approximations.

An analog sine repeats each cycle, but its sampled values need not repeat each cycle. If one cycle spans a noninteger number of sampling intervals, the sampling instants occur at different positions on successive cycles. The model evaluates the sine at each sample time; it does not generate one digital cycle and copy it 997 times.

### 7. Why not use just one cycle?

One cycle is mathematically valid. It is an integer cycle count and is coprime with any positive record length. In the circle example, advancing one position per sample visits every position before returning to the start.

Keeping the current sample rate and record length fixed:

| Cycle count | Input frequency | Phase coverage before repetition |
|---:|---:|---|
| 1 | 61.03515625 Hz | Full 16384-position phase grid |
| 997 | 60852.05078125 Hz | Full 16384-position phase grid, in a different order |

More cycles are not automatically more accurate. These two choices test different input frequencies. For an ideal sine, normalized fundamental amplitude can be the same, but its FFT location differs. Quantized metrics need not be exactly identical. A future nonideal ADC may respond differently at the two frequencies because of bandwidth, settling, or jitter.

If noiseless sampled data really is an identical short sequence copied repeatedly, those copies do not create independent new information. New records containing random noise are a different situation.

The present validator rejects a cycle count of 1 because the selected project profile requires an odd prime greater than 2. This is an implementation policy, not a mathematical failure of one-cycle coherent sampling. This note does not change that policy.

### 8. Why use a power-of-two record length?

A classic radix-2 FFT repeatedly splits a computation into halves:

```text
16 points -> 8-point subproblems -> 4-point subproblems -> 2-point subproblems
```

Power-of-two lengths make this decomposition straightforward and are conventional FFT choices. Other FFT algorithms handle other lengths. A power of two is not a mathematical requirement for coherence or for computing a DFT; it is not guaranteed to be the fastest choice in every implementation either.

It also simplifies coprime selection. A power of two has only the prime factor 2, so every odd cycle count is coprime with it. Choosing an odd prime follows the additional ADI recommendation adopted by this project; it is stricter than the mathematical coprime condition.

For example, 10000 samples and 997 cycles are coprime and coherent. At 1 MS/s, they give a 10 ms record and a 99.7 kHz tone. This example is mathematically valid but is rejected by the current power-of-two validator. Supporting it would require reviewing the configuration policy; the SAR conversion algorithm itself does not require a power-of-two record.

### 9. Why these particular baseline values?

| Setting | Current value | Actual rationale | What it does not establish |
|---|---:|---|---|
| sampleRateHz | 1000000 | Convenient initial simulation baseline; no target circuit speed was supplied. | Does not demonstrate that a physical ADC meets 1 MS/s timing. |
| sampleCount | 16384 | Matches the ADI ADC Analyzer example default and is a conventional power-of-two FFT length. | Not the only coherent length and not an optimized requirement for every future experiment. |
| coherentCycleCount | 997 | An odd prime coprime with 16384; places the input around 60.85 kHz. Harmonics 2-6 remain below the 500 kHz Nyquist limit, making the initial spectrum easier to inspect. | Not a unique or optimized frequency choice; more cycles do not inherently improve accuracy. |

The physical repetition pattern is determined by the ratio of input frequency to sampling rate. In the current ideal model, keeping M and K fixed while changing Fs preserves the normalized sampled sine sequence, apart from numerical roundoff, and changes the time and frequency labels. There is no modeled speed-dependent circuit degradation yet.

### 10. Equations for later reference

Use these after the intuition above is clear:

```text
Fs = sampleRateHz
M  = sampleCount
K  = coherentCycleCount

Record period                  T = M / Fs
Input frequency              Fin = K / T = K * Fs / M
FFT frequency spacing    delta_f = Fs / M
Fundamental bin                k = K                 (zero-based)
Phase repetition interval      L = M / gcd(M, K)      (sampling intervals)
```

For the current baseline, T = 16.384 ms, delta_f = 61.03515625 Hz, Fin = 60.85205078125 kHz, and L = 16384 sampling intervals.

### 11. Choosing a future experiment

1. Decide which input-frequency region matters to the design question.
2. Select the sampling rate and record length for that experiment.
3. Estimate the cycle count from target frequency times record duration.
4. Choose a nearby permitted cycle count and use its exact resulting frequency. Under the current profile, use an odd prime below M/2 and a power-of-two M of at least 32.
5. Check for harmonic overlaps and record the actual configuration and frequency. Harmonics above Nyquist can be folded by the analyzer; keeping them below Nyquist is a convenience, not a universal requirement.

Changing M while keeping K and Fs fixed changes the input frequency as well as FFT spacing. A longer FFT can lower the power per noise bin without improving total noise or SNR. Do not interpret a lower plotted floor alone as better ADC performance.

### References and implementation locations

- ADI Testing Data Converters, Figure 5.65, printed page 5.62 / PDF page 64: ADC Analyzer example settings, including the 16384-point default.
- ADI Equation 5.29 and Figure 5.66, printed pages 5.62-5.63 / PDF pages 64-65: coherent ratio, power-of-two record, and prime-cycle recommendation.
- [Analog Devices reference alignment](../../../documentation/ANALOG_DEVICES_REFERENCE_ALIGNMENT.md): applicability, exceptions, and source location.
- [main.m](../main.m): user-facing settings.
- [Configuration validation](../testing/+parameters/validateConfiguration.m): current enforced policy.
- [Sine stimulus](../testing/+inputSignals/generateCoherentContinuousSineWave.m): coherent frequency selection and continuous-time sine evaluation.
- [Converter simulation](../+converterModel/simulateConverter.m): sampling times and sequential conversion.
- [Capacitor-array sampling](../+converterModel/sampleCapacitorArray.m): captured input voltage and charge.
- [Model definitions](MODEL_DEFINITIONS.md): mathematical behavior and metric definitions.

This rationale records the discussion on 2026-10-25. No code, validation constraints, or numerical baseline was changed when this document was added.
