function p = createSimulationConfiguration()
  %% Converter settings
  p.resolutionBits = 12;
  p.vRef = 1;
  p.vCM = p.vRef / 2;
  p.unitCapacitanceFemtofarads = 10;

  %% Sampling
  p.sampleRateHz = 1e6;

  %% Sine-wave stimulus
  p.sampleCount = 2 ^ 10;
  p.inputCycleCount = 61.25;

  %% Ideal comparator-reference bias for the half-LSB convention
  nominalQuantizationStepVolts = p.vRef / 2 ^ p.resolutionBits;
  p.comparatorReferenceShiftVolts = nominalQuantizationStepVolts / 2;
end
