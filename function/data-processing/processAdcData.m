function spectrum = processAdcData( outputVolts, p )
  %% Full-scale-sine-normalized FFT
  centeredVolts = outputVolts - mean( outputVolts );
  normalizedTransform = fft( centeredVolts ) / p.sampleCount * 4 / p.vRef;

  %% Prepare one spectrum for metrics and plotting
  spectrum.singleSidedTransform = normalizedTransform( 1 : p.sampleCount / 2 + 1 );
  spectrum.singleSidedTransform( 1 ) = 0;
  spectrum.singleSidedTransform( end ) = spectrum.singleSidedTransform( end ) / sqrt( 2 );

  %% Measure the coherent fundamental and residual
  spectrum.sndrDb = calculateSNR( spectrum.singleSidedTransform, p.coherentCycleCount, 0 );
  spectrum.enobBits = ( spectrum.sndrDb - 1.76 ) / 6.02;
end
