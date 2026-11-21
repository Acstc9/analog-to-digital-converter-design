function plotFrequencySpectrum( spectrum, p )
  frequencyKilohertz = ( 2 : p.sampleCount / 2 )' * p.sampleRateHz / p.sampleCount / 1e3;

  figure( 'Color', 'w', 'Position', [100, 100, 1000, 600] );
  plot( frequencyKilohertz, spectrum.binMagnitudeDbfs, 'b-', 'LineWidth', 2.5 );
  xlabel( 'Frequency (kHz)' );
  ylabel( 'Magnitude (dBFS)' );
  title( 'ADC Frequency Spectrum' );
  xlim( [0, p.sampleRateHz / 2] / 1e3 );
  ylim( [-120, 5] );
  grid on;

  performanceLines = {
    sprintf( 'SNDR: %.2f dB', spectrum.sndrDb )
    sprintf( 'ENOB: %.3f bits', spectrum.enobBits )
  };
  text( 0.97, 0.93, performanceLines, 'Units', 'normalized', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top' );
end
