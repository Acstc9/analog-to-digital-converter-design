function binaryCodes = cbwSarADC( inputVoltageSamples, p )
  %% Build one device and prepare the sample record
  capacitorWeights = synthesizeBinaryCDAC( p );
  capacitorArray.nominalCapacitanceFemtofarads = p.unitCapacitanceFemtofarads * capacitorWeights;
  capacitorArray.totalCapacitanceFemtofarads = sum( capacitorArray.nominalCapacitanceFemtofarads );
  sampleCount = numel( inputVoltageSamples );
  binaryCodes = nan( sampleCount, p.resolutionBits );

  for iSample = 1 : sampleCount
    %% Read one sample and clear the switches
    inputVolts = inputVoltageSamples( iSample );
    switchPositions = zeros( 1, p.resolutionBits );

    %% SAR control: trial switch, solve, compare, retain or revert
    for iBit = 1 : p.resolutionBits
      switchPositions( iBit ) = 1;
      cdacOutputVolts = binaryCDAC( capacitorArray, p, inputVolts, switchPositions );
      keepBit = p.comparatorReferenceShiftVolts >= cdacOutputVolts;
      if ~keepBit
        switchPositions( iBit ) = 0;
      end
    end

    %% Store the completed conversion before taking the next sample
    binaryCodes( iSample, : ) = switchPositions;
  end
end
