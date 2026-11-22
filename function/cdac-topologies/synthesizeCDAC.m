function capacitorArray = synthesizeCDAC( p )
  switch p.cdacType
    case "binary"
      %% Binary-weighted branches followed by one unit dummy
      bitExponents = [ ( p.resolutionBits - 1 ) : -1 : 0, 0 ];
      capacitorWeights = 2 .^ bitExponents;
      capacitorWeights = normrnd( capacitorWeights, p.mismatchStd .* sqrt( capacitorWeights ) );
      capacitorArray.capacitanceFemtofarads = p.unitCapacitanceFemtofarads * capacitorWeights;
      capacitorArray.totalCapacitanceFemtofarads = sum( capacitorArray.capacitanceFemtofarads );
    case "bridge"
      %% MSB array
      msbExponents = ( p.msbBitCount - 1 ) : -1 : 0;
      msbWeights = 2 .^ msbExponents;
      msbWeights = normrnd( msbWeights, p.mismatchStd .* sqrt( msbWeights ) );
      capacitorArray.msbCapacitanceFemtofarads = p.unitCapacitanceFemtofarads * msbWeights;

      %% LSB array followed by one unit dummy
      lsbExponents = [ ( p.lsbBitCount - 1 ) : -1 : 0, 0 ];
      lsbWeights = 2 .^ lsbExponents;
      lsbWeights = normrnd( lsbWeights, p.mismatchStd .* sqrt( lsbWeights ) );
      capacitorArray.lsbCapacitanceFemtofarads = p.unitCapacitanceFemtofarads * lsbWeights;

      %% Bridge capacitor
      bridgeWeight = 2 ^ p.lsbBitCount / ( 2 ^ p.lsbBitCount - 1 );
      bridgeWeight = normrnd( bridgeWeight, p.mismatchStd * sqrt( bridgeWeight ) );
      capacitorArray.bridgeCapacitanceFemtofarads = p.unitCapacitanceFemtofarads * bridgeWeight;

      capacitorArray.msbTotalCapacitanceFemtofarads = sum( capacitorArray.msbCapacitanceFemtofarads );
      capacitorArray.lsbTotalCapacitanceFemtofarads = sum( capacitorArray.lsbCapacitanceFemtofarads );
  end
end
