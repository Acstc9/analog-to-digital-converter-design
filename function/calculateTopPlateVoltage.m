function topPlateVolts = calculateTopPlateVoltage( samplingResult, capacitorArray )
  branchCapacitancesFemtofarads = capacitorArray.nominalCapacitanceFemtofarads;
  totalCapacitanceFemtofarads = sum( branchCapacitancesFemtofarads );
  bottomPlateContributionFemtocoulombs = sum( branchCapacitancesFemtofarads .* samplingResult.bottomPlateVolts );
  topPlateVolts = ( samplingResult.topPlateChargeFemtocoulombs + bottomPlateContributionFemtocoulombs ) / totalCapacitanceFemtofarads;
end
