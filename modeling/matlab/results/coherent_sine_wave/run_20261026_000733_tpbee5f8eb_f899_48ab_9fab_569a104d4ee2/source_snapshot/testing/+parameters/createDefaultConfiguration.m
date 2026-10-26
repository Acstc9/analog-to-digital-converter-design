function configuration = createDefaultConfiguration()
configuration.schemaVersion = 3;
configuration.converter.resolutionBits = 12;
configuration.converter.minimumInputVolts = 0;
configuration.converter.maximumInputVolts = 1;
configuration.converter.unitCapacitanceFarads = 10e-15;
configuration.converter.samplingTopPlateVoltageVolts = 0;
configuration.converter.comparatorReferenceShiftVolts = ...
    (configuration.converter.maximumInputVolts-configuration.converter.minimumInputVolts) ...
    / 2^(configuration.converter.resolutionBits+1);
configuration.sampling.sampleRateHz = 1e6;
configuration.sampling.acquisitionDurationSeconds = 200e-9;
configuration.sampling.bitDecisionDurationSeconds = 25e-9;
configuration.stimulus.sampleCount = 16384;
configuration.stimulus.coherentCycleCount = 997;
configuration.stimulus.amplitudeDbfs = -1;
configuration.analysis.maximumHarmonicOrder = 6;
end
