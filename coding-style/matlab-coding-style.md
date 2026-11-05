# MATLAB Coding Style

## Scope

These conventions apply to MATLAB source in this project. Keep functions focused on the converter model, stimulus generation, data processing or plotting.

## Naming

- Use descriptive camelCase names for functions and variables. Function filenames match their functions.
- Retain established engineering acronyms such as ADC, CDAC and PSD. Preserve conventional unit names such as Hz and fF.
- Name operations with a verb and object, such as synthesizeBinaryCDAC or createSimulationConfiguration. Name circuit models for the circuit, such as cbwSarADC.
- Use `i` followed by the loop object for indices, such as iSample or iBit; do not use bare i or j.
- Use lowercase folder and document names with hyphens between words. Keep conventional filenames such as README.md.

## Formatting and comments

- Use two spaces for indentation, with block terminators aligned with their opening statements.
- Put spaces inside parentheses and around assignment and binary operators: `samples = nan( 1024, 1 );`.
- Write comments in English. Use descriptive names instead of repeating the code in comments, and use `%%` sections for major steps.
- Separate physical actions into readable statements. Avoid dense nested expressions and unnecessary aliases of structure fields.
- Avoid ellipsis continuations in ordinary calculations. Do not split a straightforward statement solely to meet an arbitrary line-length limit.

## Configuration and initialization

- Keep experiment settings in sim-config/createSimulationConfiguration.m. Pass configuration as the structure p, using descriptive fields directly where needed.
- Meaningful signal, result and device-state arguments may remain separate from p.
- Run the complete testbench after changing settings so derived values are recalculated.
- Initialize pending numeric result buffers with NaN in double storage. An unwritten entry must remain distinguishable from a valid zero result.
- Use zero for a defined physical state: switchPositions starts at zero because the switches initially connect to ground. Store the completed MSB-first switch row in binaryCodes.
- Do not replace, omit or integer-cast NaNs to conceal missing results.

## Component responsibilities

- cbwSarADC creates the capacitor array, controls successive bit trials and returns binary output codes.
- binaryCDAC calculates the floating top-node voltage from sampled charge and switch connections.
- idealDAC decodes output bits into nominal voltages for analysis; it is separate from the physical CDAC.
- processAdcData prepares the shared single-sided spectrum and calculates metrics. plotFrequencySpectrum consumes that spectrum without repeating its weighting or changing the metrics.
- The testbench loads configuration, generates stimulus, runs conversion, and invokes analysis and plotting.
- Keep converter functions independent of files, plots and the testbench. Configure MATLAB search paths outside model code.
- Use array operations where clear. Retain loops for sequential conversion and successive bit decisions; avoid unnecessary while loops.
- Keep the ideal model minimal. Add validation, nonideal behavior or extra result fields only for a concrete requirement.

## Plotting

- Use raw positive-frequency bins with toolbox dbv and MATLAB stem. Do not smooth or average bins.
- Use color [0, 0.447, 0.741], line width 0.5 and no markers.
- Include Frequency (kHz), Power (dBFS), a short title, grid and the SNDR/amplitude-corrected-ENOB Performance panel.
- Use a linear frequency axis from 0 to Fs/2 and vertical limits from -160 to 5 dBFS.
- Omit DC and zero-power bins from the drawing without adding an artificial data floor.
- Keep plotting in one dedicated function. Normal runs open a figure without saving files or printing a duplicate report.

## Verification

- Inspect changed result-buffer initializers; Code Analyzer alone does not establish correct NaN initialization.
- Check names, indentation, units, array orientation and function responsibilities.
- Verify substantive numerical changes with a complete testbench run and small focused checks. Use temporary verification scripts rather than adding a separate test framework.
- Record verified results and relevant limitations in README.md.
