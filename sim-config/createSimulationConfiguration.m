function p = createSimulationConfiguration()
  %% Converter settings
  p.resolutionBits = 12;
  p.vRef = 1;
  p.vCM = p.vRef / 2;
  p.unitCapacitanceFemtofarads = 10;

  %% Sampling
  p.sampleRateHz = 1e6;

  %% Coherent sine-wave stimulus
  p.sampleCount = 2 ^ 10;
  p.coherentCycleCount = 61;
  p.amplitudeDbfs = -1;

  %% Ideal comparator-reference bias for the half-LSB convention
  nominalQuantizationStepVolts = p.vRef / 2 ^ p.resolutionBits;
  p.comparatorReferenceShiftVolts = nominalQuantizationStepVolts / 2;
end
