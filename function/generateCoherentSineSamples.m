function [inputVoltageSamples, stimulus] = generateCoherentSineSamples( p )
  sampleIndices = ( 0 : p.sampleCount - 1 )';
  cyclesPerSample = p.coherentCycleCount / p.sampleCount;
  stimulus.frequencyHz = cyclesPerSample * p.sampleRateHz;
  stimulus.peakAmplitudeVolts = p.vRef / 2 * 10 ^ ( p.amplitudeDbfs / 20 );
  stimulus.offsetVolts = p.vCM;
  inputVoltageSamples = stimulus.offsetVolts + stimulus.peakAmplitudeVolts * sin( 2 * pi * cyclesPerSample * sampleIndices );
end
