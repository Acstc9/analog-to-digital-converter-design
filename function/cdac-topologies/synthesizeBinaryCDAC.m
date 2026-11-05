function capacitorWeights = synthesizeBinaryCDAC( p )
  %% Binary-weighted branches followed by one unit dummy
  bitExponents = [ ( p.resolutionBits - 1 ) : -1 : 0, 0 ];
  capacitorWeights = 2 .^ bitExponents;
end
