p = createSimulationConfiguration( "bridge", 0.05 );
[inputVoltageSamples, stimulus] = generateSineSamples( p );
capacitorArray = synthesizeCDAC( p );

%% Convert and store one sample at a time
binaryCodes = nan( p.sampleCount, p.resolutionBits );
for iSample = 1 : p.sampleCount
  binaryCodes( iSample, : ) = cbwSarADC( capacitorArray, p, inputVoltageSamples( iSample ) );
end

%% Analyze the output
outputVolts = idealDAC( binaryCodes, p );
spectrum = processAdcData( outputVolts, p );
plotFrequencySpectrum( spectrum, p );
