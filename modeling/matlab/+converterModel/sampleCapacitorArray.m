function capacitorState = sampleCapacitorArray(inputVoltageAtTime, sampleTimeSeconds, holdEndTimeSeconds, capacitorArray, converter)
capacitorState.sampleTimeSeconds = sampleTimeSeconds;
capacitorState.holdEndTimeSeconds = holdEndTimeSeconds;
capacitorState.sampledInputVolts = inputVoltageAtTime(sampleTimeSeconds);
validateattributes(capacitorState.sampledInputVolts, {'double'}, {'scalar','real','finite'});
capacitorState.sampledTopPlateChargeCoulombs = sum(capacitorArray.capacitanceFarads) ...
    * (converter.samplingTopPlateVoltageVolts-capacitorState.sampledInputVolts);
capacitorState.bottomPlateVoltageVolts = repmat(converter.minimumInputVolts, ...
    size(capacitorArray.capacitanceFarads));
capacitorState.topPlateVoltageVolts = converterModel.calculateTopPlateVoltage(capacitorState,capacitorArray);
end
