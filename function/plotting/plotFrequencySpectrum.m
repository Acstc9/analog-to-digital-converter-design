function plotFrequencySpectrum( spectrum, p )
  frequencyKilohertz = ( 1 : p.sampleCount / 2 )' * p.sampleRateHz / p.sampleCount / 1e3;
  binPowerDbfs = dbv( spectrum.singleSidedTransform( 2 : end ) );
  positivePowerBins = binPowerDbfs > -Inf;

  figure( 'Color', 'w', 'Position', [100, 100, 1000, 600] );
  axes( 'Position', [0.08, 0.15, 0.63, 0.75] );
  stem( frequencyKilohertz( positivePowerBins ), binPowerDbfs( positivePowerBins ), 'Color', [0, 0.447, 0.741], 'Marker', 'none', 'LineWidth', 0.5, 'BaseValue', -160 );
  xlabel( 'Frequency (kHz)' );
  ylabel( 'Power (dBFS)' );
  title( 'ADC Frequency Spectrum' );
  xlim( [0, p.sampleRateHz / 2] / 1e3 );
  ylim( [-160, 5] );
  grid on;

  performanceLines = {
    'Performance'
    sprintf( 'SNDR: %.2f dB', spectrum.metrics.sndrDb )
    sprintf( 'ENOB: %.3f bits', spectrum.metrics.enobBits )
    '(amplitude corrected)'
  };
  annotation( 'textbox', [0.75, 0.35, 0.24, 0.5], 'String', performanceLines, 'EdgeColor', 'none', 'FontSize', 11 );
end
