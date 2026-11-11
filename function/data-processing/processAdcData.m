function spectrum = processAdcData( outputVolts, p )
  %% Apply the periodic Hann window
  windowWeights = ds_hann( p.sampleCount );
  windowWeights = windowWeights.';
  windowedVolts = outputVolts .* windowWeights;

  %% Full-scale-sine-normalized FFT
  windowedTransform = fft( windowedVolts );
  spectrumVolts = windowedTransform / ( sum( windowWeights ) / 2 );
  fullScaleRelativeSpectrum = spectrumVolts / ( p.vRef / 2 );

  %% Exclude the first six bins and retain the one-sided spectrum
  spectrum.singleSidedTransform = fullScaleRelativeSpectrum( 7 : p.sampleCount / 2 + 1 );
  spectrum.singleSidedTransform( end ) = spectrum.singleSidedTransform( end ) / sqrt( 2 );
  spectrum.binMagnitudeDbfs = dbv( spectrum.singleSidedTransform );

  %% Calculate SNDR and ENOB
  spectrum.sndrDb = calculateSNR( spectrum.singleSidedTransform, round( p.inputCycleCount ) - 6, 25 );
  spectrum.enobBits = ( spectrum.sndrDb - 1.76 ) / 6.02;
end
