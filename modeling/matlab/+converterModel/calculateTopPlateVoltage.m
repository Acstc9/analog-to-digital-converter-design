function topPlateVoltageVolts = calculateTopPlateVoltage(capacitorState, capacitorArray)
bottomPlateWeightedChargeCoulombs = sum(capacitorArray.capacitanceFarads .* capacitorState.bottomPlateVoltageVolts);
topPlateVoltageVolts = (capacitorState.sampledTopPlateChargeCoulombs+bottomPlateWeightedChargeCoulombs) ...
    / sum(capacitorArray.capacitanceFarads);
end
