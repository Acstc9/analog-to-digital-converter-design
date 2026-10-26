function validateConverterParameters(converter)
validateattributes(converter.resolutionBits, {'double'}, {'scalar','integer','>=',1,'<=',24});
validateattributes(converter.minimumInputVolts, {'double'}, {'scalar','real','finite'});
validateattributes(converter.maximumInputVolts, {'double'}, {'scalar','real','finite','>',converter.minimumInputVolts});
validateattributes(converter.unitCapacitanceFarads, {'double'}, {'scalar','real','finite','positive'});
validateattributes(converter.samplingTopPlateVoltageVolts, {'double'}, {'scalar','real','finite'});
validateattributes(converter.comparatorReferenceShiftVolts, {'double'}, {'scalar','real','finite'});
inputSpanVolts = converter.maximumInputVolts-converter.minimumInputVolts;
halfLeastSignificantBitVolts = inputSpanVolts/2^(converter.resolutionBits+1);
largestMagnitudeVolts = max(abs([converter.minimumInputVolts,converter.maximumInputVolts]));
assert(isfinite(inputSpanVolts) && halfLeastSignificantBitVolts>0 ...
    && halfLeastSignificantBitVolts>=eps(largestMagnitudeVolts), ...
    'converterModel:UnresolvableConverterRange', 'The voltage range must have a finite span and representable half-step transitions at the selected resolution.');
end
