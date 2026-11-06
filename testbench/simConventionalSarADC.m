%% Configure the experiment and generate coherent sine samples
p = createSimulationConfiguration();
[inputVoltageSamples, stimulus] = generateCoherentSineSamples( p );

%% Build one capacitor array
capacitorWeights = synthesizeBinaryCDAC( p );
capacitorArray.nominalCapacitanceFemtofarads = p.unitCapacitanceFemtofarads * capacitorWeights;
capacitorArray.totalCapacitanceFemtofarads = sum( capacitorArray.nominalCapacitanceFemtofarads );

%% Convert and store one sample at a time
binaryCodes = nan( p.sampleCount, p.resolutionBits );
for iSample = 1 : p.sampleCount
  binaryCodes( iSample, : ) = cbwSarADC( capacitorArray, p, inputVoltageSamples( iSample ) );
end

%% Analyze the output
outputVolts = idealDAC( binaryCodes, p );
spectrum = processAdcData( outputVolts, p );

%% Display the results
plotFrequencySpectrum( spectrum, p );
