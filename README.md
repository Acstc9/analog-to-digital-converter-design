# SAR ADC MATLAB Model

Simulate a 12-bit SAR ADC and see how capacitor mismatch affects its effective number of bits (ENOB).

Add `sim-config`, `models`, `function` and `testbench` (including subfolders) to the MATLAB path.

- Run [simADC.m](testbench/simADC.m) to view the spectrum, SNDR and ENOB. Line 1 selects the binary or bridge DAC and the mismatch level.
- Run [plotEnobVsMismatch.m](function/plotting/plotEnobVsMismatch.m) to plot ENOB versus mismatch for the binary DAC.

Requires Communications Toolbox, Statistics and Machine Learning Toolbox, and Richard Schreier's Delta Sigma Toolbox.
