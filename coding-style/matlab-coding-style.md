# MATLAB Coding Style

## Scope and source

This is the project-local style reference for new and deliberately revised MATLAB code, adopted on 2026-10-28. Read it before changing MATLAB code. It summarizes the instructor's supplied coding-style document and distinguishes interpretations from explicit requirements. The original attachment remains unchanged under literature/source-documents/references/coding style requirements/.

These rules supersede the earlier folder/document naming and formatting conventions for future work. Existing paths, MATLAB package folders, saved fields and historical snapshots are not renamed automatically. Follow the agreed learning steps when migrating the implementation; this document does not itself authorize a project-wide rewrite.

## Naming

- Choose names that communicate meaning. Keep the user's preference for descriptive words; established engineering acronyms are appropriate.
- Use lowercase folder and document names with hyphens between words, for example `coding-style` and `matlab-coding-style.md`. Keep conventional required names such as `README.md` and `AGENTS.md`.
- Use camelCase for MATLAB functions and variables. Function filenames must match their functions; do not apply hyphenated document naming to MATLAB function names.
- Prefer verb + noun for operations, such as `synthesizeCDAC` and `plotPSD`.
- Name model wrappers for the modeled circuit, such as `conventionalSarADC`.
- Name testbenches for the simulation they run, such as `simulateConventionalSarADC`.
- Use `i` followed by the loop object for indices, such as `iSample` or `iBit`; do not use bare `i` or `j`.

Interpretation: the instructor describes camelCase with an uppercase final word, but the examples include `conventionalSarADC`, `fftLen` and `nCap`. Follow these examples: capitalize internal word initials and retain uppercase terminal engineering acronyms such as ADC, CDAC and PSD. Do not infer that every ordinary final word must be entirely uppercase. The scope of the wording beyond these examples remains ambiguous. Preserve the conventional case of units such as Hz and fF.

## Formatting and comments

- Indent each nested level by two spaces. Use spaces, not tabs.
- Put spaces inside parentheses and around assignment and binary operators: `samples = nan( 1024, 1 );` and `( a + b )`.
- Keep matching block terminators aligned with their opening statements.
- Write comments in English and use `%%` sections where they improve navigation.
- Prefer readable names over many explanatory comments.
- User preference: express physical actions as separate named steps. Separate reading inputs, calculating quantities and storing state when combining them would obscure the sequence; avoid dense nested calls.
- User preference: avoid ellipsis line continuations in ordinary calculations. Prefer a complete statement on each line and descriptive intermediate quantities where they improve readability; do not split a straightforward statement merely to meet an arbitrary line-length limit.

Interpretation: the source has a wording typo in its parentheses rule. Its `( a + b )` example establishes that the intended rule is spacing inside parentheses.

## Parameters and array initialization

- Pass configuration between functions in a structure, as demonstrated by the supplied configuration file. Meaningful signal, result and device-state arguments can remain separate; the rule does not require packing every argument into one structure.
- Keep experiment settings in sim-config/createSimulationConfiguration.m. Change that configuration rather than model equations, then run the complete testbench/simConventionalSarADC.m script to recalculate derived settings.
- Initialize every pending numeric result array with `nan`, including arrays of ADC digital codes. Use double storage for these buffers so an unwritten entry remains distinguishable from a valid zero code. Do not choose an integer type as a reason to use zero placeholders.
- NaN means a missing or invalid numeric value, not random noise. Do not hide unwritten entries with automatic replacement or omission before FFT processing.

Implementation distinction: the current SAR register starts at zero because this is its defined circuit state, not an unwritten measurement. It may use uint32 for bit operations; assign each completed code as double into the NaN-initialized output array. Likewise, a complete logical inclusion mask or an array of known bottom-plate connection voltages already has defined values. These are not exemptions for pending numeric results. Never cast a pending buffer to an integer type or replace/omit NaNs. On 2026-10-29 the user removed the initial digital-code attribute validation from processAdcData; do not reinstate type, shape, integer or range checks there. The model is responsible for producing its documented code vector. The subsequent teaching-stage simplification also removes downstream assertions and defensive error wrappers from analysis, plotting and saving. Do not restore these checks. Keep ordinary arithmetic and the operations needed to display results. No file exporter remains.

## Loops and component responsibilities

- Avoid unnecessary `for` loops where clear array operations suffice; retain loops that express the model's own sequence, including successive bit decisions.
- Avoid `while` loops where practical.
- Keep reusable component functions separate from model wrappers. A wrapper assembles component behavior into a particular ADC model.
- A testbench loads configuration, supplies stimulus, runs the model, and invokes data processing and plotting. It is the performance experiment, not an additional software-test framework.

## Plotting

- Use pure blue (`'b'`) and line width 2.5 for data curves, as specified by the instructor. Use markers to distinguish curves when needed.
- User-approved appearance and simplicity exception on 2026-11-01 for the active rebuild: use a basic spectrum with classic-blue stems [0, 0.447, 0.741], width 0.5 and no markers. Include Frequency (kHz), Power (dBFS), a short title, grid and a right-side Performance panel with SNR, SINAD, THD, SFDR and amplitude-corrected ENOB. Keep the y display range [-160, 5] dBFS; x limits follow Fs/2. No component annotations, legend, input-settings panel, subtitle, adaptive display limits or duplicate console report are needed. This user request supersedes the original pure-blue/2.5 and earlier colored-marker requirements for this plot. Keep all numerical analysis unchanged.
- Include grid, title, x-axis label and y-axis label, with English text and units where applicable.
- Set axis limits deliberately: avoid unnecessary horizontal whitespace and provide useful vertical margins without concealing relevant data.
- Keep metric calculation separate from presentation. Plot functions consume processed results rather than recalculate ADC metrics or alter samples to fit the display.
- Keep presentation in a dedicated plotting file. The active rebuild uses one basic plotFrequencySpectrum function, without a local report helper, separate style helper or generic plotting framework.

The active rebuild has no file-export helper. Its current plot is deliberately minimal; do not restore removed reporting features solely to match an older implementation.

## Learning and review workflow

The instructor's 2026-10-28 reply calls for repeated write, review and revise cycles. Explain each small step and help the user develop the implementation; do not replace that process with a complete generated rewrite. The supplied archive is a scaffold with empty files and incomplete examples, not a runnable reference model. Placeholder values, spelling errors and mismatched example interfaces are not requirements to copy into working code. No nonidealities are requested by the presence of a mismatch parameter in that scaffold.

## Required review before completing a MATLAB change

- Read this document and the active project's AGENTS.md before editing. If the instructor source and a local interpretation differ, identify the difference; do not invent a convenience exception.
- Inspect every changed array initializer: pending numeric results must use NaN; identify any retained zero/false initialization as a defined state or completed logical value. A Code Analyzer pass does not verify this rule.
- Check meaningful names, two-space indentation, spacing, English text, structure-based configuration and purposeful loops. Review model/analysis/plot responsibilities and plotting conventions when affected.
- Prefer direct structure-field access for simple expressions. Create aliases or grouped arrays only where they clarify repeated use or an actual calculation; keep numerical guard bookkeeping near its use.
- Use focused temporary verification appropriate to the change. Keep pending samples as NaN rather than silently converting them to zero. The user removed explicit downstream validation; do not add rejection tests or guards merely to restore that former policy. Do not add a permanent verification framework.
