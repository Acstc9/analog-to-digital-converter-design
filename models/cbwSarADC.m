function outputCodes = cbwSarADC( inputVoltageAtTime, simulationConfiguration )
  %% Build one device and prepare the sample record
  capacitorArray = synthesizeBinaryCDAC( simulationConfiguration );
  resolutionBits = simulationConfiguration.resolutionBits;
  sampleCount = simulationConfiguration.sampleCount;
  referenceLowVolts = simulationConfiguration.referenceLowVolts;
  referenceHighVolts = simulationConfiguration.referenceHighVolts;
  comparatorReferenceVolts = simulationConfiguration.comparatorReferenceShiftVolts;
  outputCodes = nan( sampleCount, 1 );

  for iSample = 1 : sampleCount
    %% Capture the input sample and its stored charge
    sampleTimeSeconds = ( iSample - 1 ) / simulationConfiguration.sampleRateHz;
    samplingResult = sampleInputOntoCDAC( inputVoltageAtTime, sampleTimeSeconds, capacitorArray );

    %% Begin conversion with the top plate floating and all bottom plates low
    numberOfBranches = numel( capacitorArray.nominalCapacitanceFemtofarads );
    bottomPlateVolts = repmat( referenceLowVolts, 1, numberOfBranches );
    samplingResult.bottomPlateVolts = bottomPlateVolts;
    topPlateVolts = calculateTopPlateVoltage( samplingResult, capacitorArray );
    samplingResult.topPlateVolts = topPlateVolts;

    outputCode = uint32( 0 );

    %% SAR control: trial switch, solve, compare, retain or revert
    for iBit = 1 : resolutionBits
      samplingResult.bottomPlateVolts( iBit ) = referenceHighVolts;
      topPlateVolts = calculateTopPlateVoltage( samplingResult, capacitorArray );
      samplingResult.topPlateVolts = topPlateVolts;
      keepBit = compareVoltages( comparatorReferenceVolts, topPlateVolts );
      if keepBit
        bitWeight = bitshift( uint32( 1 ), resolutionBits - iBit );
        outputCode = bitor( outputCode, bitWeight );
      else
        samplingResult.bottomPlateVolts( iBit ) = referenceLowVolts;
        topPlateVolts = calculateTopPlateVoltage( samplingResult, capacitorArray );
        samplingResult.topPlateVolts = topPlateVolts;
      end
    end

    %% Store the completed conversion before taking the next sample
    outputCodes( iSample ) = double( outputCode );
  end
end
