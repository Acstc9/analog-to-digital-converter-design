function binaryCode = cbwSarADC( capacitorArray, p, inputVolts )
  switchPositions = zeros( 1, p.resolutionBits );

  %% SAR control: trial switch, solve, compare, retain or revert
  for iBit = 1 : p.resolutionBits
    switchPositions( iBit ) = 1;
    switch p.cdacType
      case "binary"
        cdacOutputVolts = binaryCDAC( capacitorArray, p, inputVolts, switchPositions );
      case "bridge"
        cdacOutputVolts = bridgeCDAC( capacitorArray, p, inputVolts, switchPositions );
    end
    keepBit = p.comparatorReferenceShiftVolts >= cdacOutputVolts;
    if ~keepBit
      switchPositions( iBit ) = 0;
    end
  end

  binaryCode = switchPositions;
end
