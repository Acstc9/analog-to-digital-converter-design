function [sampling, conversion, capacitorArray] = simulateConverter(inputVoltageAtTime, converter, samplingConfiguration, sampleCount)
converterModel.validateConverterParameters(converter);
capacitorArray = converterModel.createCapacitorArray(converter);
samplePeriodSeconds = 1/samplingConfiguration.sampleRateHz;
acquisitionDurationSeconds = samplingConfiguration.acquisitionDurationSeconds;
bitDecisionDurationSeconds = samplingConfiguration.bitDecisionDurationSeconds;
validateattributes(sampleCount, {'double'}, {'scalar','integer','positive'});
validateattributes(samplePeriodSeconds, {'double'}, {'scalar','real','finite','positive'});
validateattributes(acquisitionDurationSeconds, {'double'}, {'scalar','real','finite','positive'});
validateattributes(bitDecisionDurationSeconds, {'double'}, {'scalar','real','finite','positive'});
holdDurationSeconds = samplePeriodSeconds-acquisitionDurationSeconds;
assert(converter.resolutionBits*bitDecisionDurationSeconds<=holdDurationSeconds, ...
    'converterModel:InsufficientCycleTime', 'Acquisition and all bit decisions must fit within one sampling period.');

sampling.timeSeconds = (0:sampleCount-1)'/samplingConfiguration.sampleRateHz;
sampling.acquisitionStartTimeSeconds = sampling.timeSeconds-acquisitionDurationSeconds;
sampling.holdIntervalEndTimeSeconds = sampling.timeSeconds+holdDurationSeconds;
sampling.holdEndTimeSeconds = sampleCount/samplingConfiguration.sampleRateHz;
assert(all(isfinite([sampling.timeSeconds; sampling.holdEndTimeSeconds])) ...
    && all(diff(sampling.timeSeconds)>0), ...
    'converterModel:UnrepresentableSampling', 'Sample times must be finite and strictly increasing.');
sampling.heldInputVolts = zeros(sampleCount,1);
sampling.sampledTopPlateChargeCoulombs = zeros(sampleCount,1);
conversion.codes = zeros(sampleCount,1,'uint32');
conversion.reconstructedVolts = zeros(sampleCount,1);
conversion.overrangeMask = false(sampleCount,1);
conversion.completionTimeSeconds = zeros(sampleCount,1);
conversion.finalTopPlateVoltageVolts = zeros(sampleCount,1);
conversion.leastSignificantBitVolts = (converter.maximumInputVolts-converter.minimumInputVolts)/2^converter.resolutionBits;

for sampleIndex = 1:sampleCount
    capacitorState = converterModel.sampleCapacitorArray(inputVoltageAtTime, ...
        sampling.timeSeconds(sampleIndex),sampling.holdIntervalEndTimeSeconds(sampleIndex),capacitorArray,converter);
    sampleConversion = converterModel.convertSampledChargeToCode( ...
        capacitorState,capacitorArray,converter,bitDecisionDurationSeconds);
    sampling.heldInputVolts(sampleIndex) = capacitorState.sampledInputVolts;
    sampling.sampledTopPlateChargeCoulombs(sampleIndex) = capacitorState.sampledTopPlateChargeCoulombs;
    conversion.codes(sampleIndex) = sampleConversion.code;
    conversion.reconstructedVolts(sampleIndex) = sampleConversion.reconstructedVolts;
    conversion.overrangeMask(sampleIndex) = sampleConversion.overrangeMask;
    conversion.completionTimeSeconds(sampleIndex) = sampleConversion.completionTimeSeconds;
    conversion.finalTopPlateVoltageVolts(sampleIndex) = sampleConversion.finalTopPlateVoltageVolts;
end
end
