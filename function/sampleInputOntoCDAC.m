function samplingResult = sampleInputOntoCDAC( inputVoltageAtTime, sampleTimeSeconds, capacitorArray )
  %% Sample the continuous input at one instant
  sampledInputVolts = inputVoltageAtTime( sampleTimeSeconds );
  samplingResult.sampleTimeSeconds = sampleTimeSeconds;
  samplingResult.sampledInputVolts = sampledInputVolts;

  %% Capture total top-plate charge with the top plate clamped to ground
  samplingTopPlateVolts = 0;
  totalCapacitanceFemtofarads = sum( capacitorArray.nominalCapacitanceFemtofarads );
  samplingVoltageAcrossCapacitorsVolts = samplingTopPlateVolts - sampledInputVolts;
  topPlateChargeFemtocoulombs = totalCapacitanceFemtofarads * samplingVoltageAcrossCapacitorsVolts;
  samplingResult.topPlateChargeFemtocoulombs = topPlateChargeFemtocoulombs;

end
