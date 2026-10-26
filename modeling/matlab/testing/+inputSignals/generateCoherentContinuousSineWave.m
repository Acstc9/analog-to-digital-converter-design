function [inputVoltageAtTime, stimulus] = generateCoherentContinuousSineWave(configuration)
parameters.validateConfiguration(configuration);
converter = configuration.converter;
cyclesPerSample = configuration.stimulus.coherentCycleCount/configuration.stimulus.sampleCount;
inputSpanVolts = converter.maximumInputVolts-converter.minimumInputVolts;
stimulus.frequencyHz = cyclesPerSample*configuration.sampling.sampleRateHz;
stimulus.peakAmplitudeVolts = inputSpanVolts/2 * 10^(configuration.stimulus.amplitudeDbfs/20);
stimulus.offsetVolts = converter.minimumInputVolts+inputSpanVolts/2;
assert(isfinite(stimulus.frequencyHz) && stimulus.frequencyHz>0, ...
    'inputSignals:UnrepresentableFrequency', 'The input frequency must be positive and finite.');
assert(isfinite(stimulus.peakAmplitudeVolts) && stimulus.peakAmplitudeVolts>0 ...
    && stimulus.offsetVolts+stimulus.peakAmplitudeVolts>stimulus.offsetVolts ...
    && stimulus.offsetVolts-stimulus.peakAmplitudeVolts<stimulus.offsetVolts, ...
    'inputSignals:UnrepresentableStimulus', 'The sine amplitude must be positive, finite, and representable around its DC level.');
inputVoltageAtTime = @(timeSeconds) stimulus.offsetVolts + ...
    stimulus.peakAmplitudeVolts * sin(2*pi*stimulus.frequencyHz*timeSeconds);
end
