%% Configure the experiment and generate coherent sine samples
p = createSimulationConfiguration();
[inputVoltageSamples, stimulus] = generateCoherentSineSamples( p );

%% Run the complete converter, then analyze its output
binaryCodes = cbwSarADC( inputVoltageSamples, p );
outputVolts = idealDAC( binaryCodes, p );
spectrum = processAdcData( outputVolts, p );

%% Display the results
plotFrequencySpectrum( spectrum, p );
