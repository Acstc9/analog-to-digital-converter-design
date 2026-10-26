# Circuit and Layout Implementation

This directory is reserved for the physical ADC implementation. It currently contains no circuit or layout files.

When circuit work begins, create `circuit/<block>/`. When layout work begins, create `layout/<block>/`. Keep testbenches, simulation settings, and results with the corresponding design. Schematics, netlists, process-model dependencies, layouts, and extracted results should be traceable to the same design revision. Do not place them in MATLAB source or behavioral-model results directories.

Shared specifications belong in the root documentation directory. External process and device references belong in references. Do not copy process libraries or access credentials directly into this project.
