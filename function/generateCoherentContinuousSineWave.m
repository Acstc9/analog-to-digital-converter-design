function [inputVoltageAtTime, stimulus] = generateCoherentContinuousSineWave( simulationConfiguration )
  referenceSpanVolts = simulationConfiguration.referenceHighVolts - simulationConfiguration.referenceLowVolts;
  cyclesPerSample = simulationConfiguration.coherentCycleCount / simulationConfiguration.sampleCount;
  stimulus.frequencyHz = cyclesPerSample * simulationConfiguration.sampleRateHz;
  stimulus.peakAmplitudeVolts = referenceSpanVolts / 2 * 10 ^ ( simulationConfiguration.amplitudeDbfs / 20 );
  stimulus.offsetVolts = simulationConfiguration.referenceLowVolts + referenceSpanVolts / 2;
  inputVoltageAtTime = @( timeSeconds ) stimulus.offsetVolts + stimulus.peakAmplitudeVolts * sin( 2 * pi * stimulus.frequencyHz * timeSeconds );
end
