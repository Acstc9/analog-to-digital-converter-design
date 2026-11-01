function simulationConfiguration = createSimulationConfiguration()
  %% Converter settings
  simulationConfiguration.resolutionBits = 12;
  simulationConfiguration.referenceLowVolts = 0;
  simulationConfiguration.referenceHighVolts = 1;
  simulationConfiguration.unitCapacitanceFemtofarads = 10;

  %% Sampling
  simulationConfiguration.sampleRateHz = 1e6;

  %% Coherent sine-wave stimulus
  simulationConfiguration.sampleCount = 16384;
  simulationConfiguration.coherentCycleCount = 997;
  simulationConfiguration.amplitudeDbfs = -1;

  %% Spectrum analysis
  % Keep maximumHarmonicOrder * coherentCycleCount < sampleCount / 2.
  simulationConfiguration.maximumHarmonicOrder = 6;

  %% Ideal comparator-reference bias for the half-LSB convention
  referenceSpanVolts = simulationConfiguration.referenceHighVolts - simulationConfiguration.referenceLowVolts;
  nominalQuantizationStepVolts = referenceSpanVolts / 2 ^ simulationConfiguration.resolutionBits;
  simulationConfiguration.comparatorReferenceShiftVolts = nominalQuantizationStepVolts / 2;
end
