function spectrum = processAdcData( outputCodes, simulationConfiguration )
  %% Interpret digital codes in nominal volts for analysis
  sampleCount = simulationConfiguration.sampleCount;
  referenceSpanVolts = simulationConfiguration.referenceHighVolts - simulationConfiguration.referenceLowVolts;
  leastSignificantBitVolts = referenceSpanVolts / 2 ^ simulationConfiguration.resolutionBits;
  reconstructedVolts = simulationConfiguration.referenceLowVolts + outputCodes * leastSignificantBitVolts;

  %% Coherent single-sided power spectrum
  centeredVolts = reconstructedVolts - mean( reconstructedVolts );
  normalizedTransform = fft( centeredVolts ) / sampleCount;
  binPowerVoltsSquared = abs( normalizedTransform( 1 : sampleCount / 2 + 1 ) ) .^ 2;
  binPowerVoltsSquared( 2 : end - 1 ) = 2 * binPowerVoltsSquared( 2 : end - 1 );

  %% Fundamental, harmonics and residual noise bins
  fundamentalBin = simulationConfiguration.coherentCycleCount;
  harmonicOrders = ( 2 : simulationConfiguration.maximumHarmonicOrder )';
  harmonicBins = harmonicOrders * fundamentalBin;
  noiseMask = true( size( binPowerVoltsSquared ) );
  noiseMask( [ 1; fundamentalBin + 1; harmonicBins + 1 ] ) = false;
  spurMask = true( size( binPowerVoltsSquared ) );
  spurMask( [ 1, fundamentalBin + 1 ] ) = false;
  signalPower = binPowerVoltsSquared( fundamentalBin + 1 );
  noisePower = sum( binPowerVoltsSquared( noiseMask ) );
  distortionPower = sum( binPowerVoltsSquared( harmonicBins + 1 ) );
  fullScaleSinePower = ( referenceSpanVolts / 2 ) ^ 2 / 2;

  %% Preserve spectrum fields and measurement definitions
  spectrum.frequencyHz = ( 0 : sampleCount / 2 )' * simulationConfiguration.sampleRateHz / sampleCount;
  spectrum.binPowerVoltsSquared = binPowerVoltsSquared;
  powerRelativeToFullScale = binPowerVoltsSquared / fullScaleSinePower;
  spectrum.binPowerDbfs = 10 * log10( powerRelativeToFullScale );
  spectrum.fundamentalBin = fundamentalBin;
  spectrum.harmonicBins = harmonicBins;
  spectrum.noiseBinMask = noiseMask;
  spectrum.spurBinMask = spurMask;
  spectrum.totalPowerVoltsSquared.fundamental = signalPower;
  spectrum.totalPowerVoltsSquared.noise = noisePower;
  spectrum.totalPowerVoltsSquared.distortion = distortionPower;
  spectrum.totalPowerVoltsSquared.fullScaleSine = fullScaleSinePower;
  spectrum.metrics.snrDb = 10 * log10( signalPower / noisePower );
  spectrum.metrics.thdDb = 10 * log10( distortionPower / signalPower );
  spectrum.metrics.sinadDb = 10 * log10( signalPower / ( noisePower + distortionPower ) );
  spectrum.metrics.sfdrDb = 10 * log10( signalPower / max( binPowerVoltsSquared( spurMask ) ) );
  spectrum.metrics.enobUncorrectedBits = ( spectrum.metrics.sinadDb - 1.76 ) / 6.02;
  spectrum.metrics.fundamentalDbfs = 10 * log10( signalPower / fullScaleSinePower );
  spectrum.metrics.enobBits = ( spectrum.metrics.sinadDb - 1.76 - spectrum.metrics.fundamentalDbfs ) / 6.02;
  spectrum.metrics.snrFullScaleDb = 10 * log10( fullScaleSinePower / noisePower );
  spectrum.metrics.worstNonharmonicSpurDbc = 10 * log10( max( binPowerVoltsSquared( noiseMask ) ) / signalPower );
  spectrum.metrics.noiseFloorDbfsPerBin = 10 * log10( mean( binPowerVoltsSquared( noiseMask ) ) / fullScaleSinePower );
  harmonicLevelsDbc = 10 * log10( binPowerVoltsSquared( harmonicBins + 1 ) / signalPower );
  spectrum.harmonics = table( harmonicOrders, harmonicBins, harmonicLevelsDbc, 'VariableNames', {'Order', 'FrequencyBin', 'LevelDbc'} );
  spectrum.metrics.idealQuantizationSnrDb = 6.02 * simulationConfiguration.resolutionBits + 1.76 + simulationConfiguration.amplitudeDbfs;
end
