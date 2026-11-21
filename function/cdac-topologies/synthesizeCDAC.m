function capacitorWeights = synthesizeCDAC( p )
  switch p.cdacType
    case "binary"
      %% Binary-weighted branches followed by one unit dummy
      bitExponents = [ ( p.resolutionBits - 1 ) : -1 : 0, 0 ];
      capacitorWeights = 2 .^ bitExponents;
    case "bridge"
      %% MSB array
      msbExponents = ( p.msbBitCount - 1 ) : -1 : 0;
      capacitorWeights.msb = 2 .^ msbExponents;

      %% LSB array followed by one unit dummy
      lsbExponents = [ ( p.lsbBitCount - 1 ) : -1 : 0, 0 ];
      capacitorWeights.lsb = 2 .^ lsbExponents;

      %% Bridge capacitor
      capacitorWeights.bridge = 2 ^ p.lsbBitCount / ( 2 ^ p.lsbBitCount - 1 );
  end
end
