function plotFrequencySpectrum( result )
  spectrum = result.spectrum;
  metrics = spectrum.metrics;
  frequencyKilohertz = spectrum.frequencyHz / 1e3;
  positivePowerBins = spectrum.binPowerVoltsSquared > 0;

  figure( 'Color', 'w', 'Position', [100, 100, 1000, 600] );
  axes( 'Position', [0.08, 0.15, 0.63, 0.75] );
  stem( frequencyKilohertz( positivePowerBins ), spectrum.binPowerDbfs( positivePowerBins ), 'Color', [0, 0.447, 0.741], 'Marker', 'none', 'LineWidth', 0.5, 'BaseValue', -160 );
  xlabel( 'Frequency (kHz)' );
  ylabel( 'Power (dBFS)' );
  title( 'ADC Frequency Spectrum' );
  xlim( [0, result.configuration.sampleRateHz / 2] / 1e3 );
  ylim( [-160, 5] );
  grid on;

  performanceLines = {
    'Performance'
    sprintf( 'SNR: %.2f dB', metrics.snrDb )
    sprintf( 'SINAD: %.2f dB', metrics.sinadDb )
    sprintf( 'THD: %.2f dBc', metrics.thdDb )
    sprintf( 'SFDR: %.2f dBc', metrics.sfdrDb )
    sprintf( 'ENOB: %.3f bits', metrics.enobBits )
    '(amplitude corrected)'
  };
  annotation( 'textbox', [0.75, 0.35, 0.24, 0.5], 'String', performanceLines, 'EdgeColor', 'none', 'FontSize', 11 );
end
