function p = createSimulationConfiguration()
  %% Converter settings
  p.cdacType = "bridge";
  p.msbBitCount = 6;
  p.lsbBitCount = 6;
  p.resolutionBits = p.msbBitCount + p.lsbBitCount;
  p.vRef = 1;
  p.vCM = p.vRef / 2;
  p.unitCapacitanceFemtofarads = 10;
  p.mismatchStd = 0.05;  % Relative standard deviation of a unit capacitor

  %% Sampling
  p.sampleRateHz = 1e6;

  %% Sine-wave stimulus
  p.sampleCount = 2 ^ 10;
  p.inputCycleCount = 61;

  %% Ideal comparator-reference bias for the half-LSB convention
  nominalQuantizationStepVolts = p.vRef / 2 ^ p.resolutionBits;
  p.comparatorReferenceShiftVolts = nominalQuantizationStepVolts / 2;
end
