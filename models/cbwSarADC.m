function binaryCode = cbwSarADC( capacitorArray, p, inputVolts )
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

  binaryCode = switchPositions;
end
