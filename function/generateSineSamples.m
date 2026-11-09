function [inputVoltageSamples, stimulus] = generateSineSamples( p )
  sampleIndices = ( 0 : p.sampleCount - 1 )';
  cyclesPerSample = p.inputCycleCount / p.sampleCount;
  stimulus.frequencyHz = cyclesPerSample * p.sampleRateHz;
  stimulus.peakAmplitudeVolts = p.vRef / 2;
  stimulus.offsetVolts = p.vCM;
  inputVoltageSamples = stimulus.offsetVolts + stimulus.peakAmplitudeVolts * sin( 2 * pi * cyclesPerSample * sampleIndices );
end
