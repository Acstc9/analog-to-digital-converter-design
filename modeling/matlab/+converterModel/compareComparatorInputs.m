function keepTrialBit = compareComparatorInputs(positiveInputVolts, negativeInputVolts, roundoffToleranceVolts)
keepTrialBit = positiveInputVolts >= negativeInputVolts ...
    | abs(positiveInputVolts-negativeInputVolts)<=roundoffToleranceVolts;
end
