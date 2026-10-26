function conversion = convertSampledChargeToCode(capacitorState, capacitorArray, converter, bitDecisionDurationSeconds, captureTrace)
arguments
    capacitorState (1,1) struct
    capacitorArray (1,1) struct
    converter (1,1) struct
    bitDecisionDurationSeconds (1,1) double {mustBePositive,mustBeFinite}
    captureTrace (1,1) logical = false
end
leastSignificantBitVolts = (converter.maximumInputVolts-converter.minimumInputVolts)/2^converter.resolutionBits;
comparatorReferenceVolts = converter.samplingTopPlateVoltageVolts+converter.comparatorReferenceShiftVolts;
roundoffToleranceVolts = 8*eps(max(abs([comparatorReferenceVolts,capacitorState.sampledInputVolts, ...
    converter.samplingTopPlateVoltageVolts,converter.minimumInputVolts,converter.maximumInputVolts])));
conversion.completionTimeSeconds = capacitorState.sampleTimeSeconds+converter.resolutionBits*bitDecisionDurationSeconds;
assert(conversion.completionTimeSeconds<=capacitorState.holdEndTimeSeconds, ...
    'converterModel:InsufficientHoldTime', 'All bit decisions must finish within the hold interval.');
acceptedCode = uint32(0);
if captureTrace
    conversion.trace.trialCodes = zeros(1,converter.resolutionBits,'uint32');
    conversion.trace.trialTopPlateVoltageVolts = zeros(1,converter.resolutionBits);
    conversion.trace.bottomPlateVoltageVolts = zeros(converter.resolutionBits,converter.resolutionBits+1);
    conversion.trace.comparatorReferenceVolts = comparatorReferenceVolts;
    conversion.trace.roundoffToleranceVolts = roundoffToleranceVolts;
    conversion.trace.keepTrialBit = false(1,converter.resolutionBits);
    conversion.trace.trialUpdateTimeSeconds = zeros(1,converter.resolutionBits);
    conversion.trace.decisionTimeSeconds = zeros(1,converter.resolutionBits);
end
for decisionIndex = 1:converter.resolutionBits
    trialUpdateTimeSeconds = capacitorState.sampleTimeSeconds+(decisionIndex-1)*bitDecisionDurationSeconds;
    decisionTimeSeconds = capacitorState.sampleTimeSeconds+decisionIndex*bitDecisionDurationSeconds;
    bitWeight = bitshift(uint32(1),converter.resolutionBits-decisionIndex);
    trialCode = bitor(acceptedCode,bitWeight);
    capacitorState.bottomPlateVoltageVolts(decisionIndex) = converter.maximumInputVolts;
    capacitorState.topPlateVoltageVolts = converterModel.calculateTopPlateVoltage(capacitorState,capacitorArray);
    keepTrialBit = converterModel.compareComparatorInputs(comparatorReferenceVolts,capacitorState.topPlateVoltageVolts,roundoffToleranceVolts);
    if captureTrace
        conversion.trace.trialCodes(decisionIndex) = trialCode;
        conversion.trace.trialTopPlateVoltageVolts(decisionIndex) = capacitorState.topPlateVoltageVolts;
        conversion.trace.bottomPlateVoltageVolts(decisionIndex,:) = capacitorState.bottomPlateVoltageVolts;
        conversion.trace.keepTrialBit(decisionIndex) = keepTrialBit;
        conversion.trace.trialUpdateTimeSeconds(decisionIndex) = trialUpdateTimeSeconds;
        conversion.trace.decisionTimeSeconds(decisionIndex) = decisionTimeSeconds;
    end
    if keepTrialBit
        acceptedCode = trialCode;
    else
        capacitorState.bottomPlateVoltageVolts(decisionIndex) = converter.minimumInputVolts;
        capacitorState.topPlateVoltageVolts = converterModel.calculateTopPlateVoltage(capacitorState,capacitorArray);
    end
end
conversion.code = acceptedCode;
conversion.leastSignificantBitVolts = leastSignificantBitVolts;
conversion.reconstructedVolts = converter.minimumInputVolts+double(acceptedCode)*leastSignificantBitVolts;
conversion.overrangeMask = capacitorState.sampledInputVolts<converter.minimumInputVolts ...
    | capacitorState.sampledInputVolts>=converter.maximumInputVolts;
conversion.finalTopPlateVoltageVolts = capacitorState.topPlateVoltageVolts;
end
