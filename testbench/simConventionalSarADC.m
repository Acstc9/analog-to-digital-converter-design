%% Configure the experiment and generate sine samples
p = createSimulationConfiguration();
[inputVoltageSamples, stimulus] = generateSineSamples( p );

%% Build one capacitor array
capacitorWeights = synthesizeCDAC( p );
capacitorArray = struct();
switch p.cdacType
  case "binary"
    capacitorArray.capacitanceFemtofarads = p.unitCapacitanceFemtofarads * capacitorWeights;
    capacitorArray.totalCapacitanceFemtofarads = sum( capacitorArray.capacitanceFemtofarads );
  case "bridge"
    capacitorArray.msbCapacitanceFemtofarads = p.unitCapacitanceFemtofarads * capacitorWeights.msb;
    capacitorArray.lsbCapacitanceFemtofarads = p.unitCapacitanceFemtofarads * capacitorWeights.lsb;
    capacitorArray.bridgeCapacitanceFemtofarads = p.unitCapacitanceFemtofarads * capacitorWeights.bridge;
    capacitorArray.msbTotalCapacitanceFemtofarads = sum( capacitorArray.msbCapacitanceFemtofarads );
    capacitorArray.lsbTotalCapacitanceFemtofarads = sum( capacitorArray.lsbCapacitanceFemtofarads );
end

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
