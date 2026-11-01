function capacitorArray = synthesizeBinaryCDAC( simulationConfiguration )
  %% Binary-weighted branches followed by one unit dummy
  bitExponents = ( simulationConfiguration.resolutionBits - 1 ) : -1 : 0;
  bitCapacitorWeights = 2 .^ bitExponents;
  capacitorArray.unitCapacitorCounts = [ bitCapacitorWeights, 1 ];

  %% Nominal branch capacitances
  capacitorArray.nominalCapacitanceFemtofarads = simulationConfiguration.unitCapacitanceFemtofarads * capacitorArray.unitCapacitorCounts;
end
