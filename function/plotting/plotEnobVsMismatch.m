function plotEnobVsMismatch()
  mismatchStdValues = 0.0001 : 0.0001 : 0.1;
  arrayCount = 100;
  enobBits = nan( arrayCount, numel( mismatchStdValues ) );

  for iLevel = 1 : numel( mismatchStdValues )
    p = createSimulationConfiguration( "binary", mismatchStdValues( iLevel ) );
    inputVoltageSamples = generateSineSamples( p );
    for iArray = 1 : arrayCount
      capacitorArray = synthesizeCDAC( p );
      binaryCodes = nan( p.sampleCount, p.resolutionBits );
      for iSample = 1 : p.sampleCount
        binaryCodes( iSample, : ) = cbwSarADC( capacitorArray, p, inputVoltageSamples( iSample ) );
      end
      outputVolts = idealDAC( binaryCodes, p );
      spectrum = processAdcData( outputVolts, p );
      enobBits( iArray, iLevel ) = spectrum.enobBits;
    end
  end

  medianEnobBits = median( enobBits, 1 );
  figure( 'Color', 'w', 'Position', [ 100, 100, 1000, 620 ] );
  semilogx( mismatchStdValues, medianEnobBits, 'b-', 'LineWidth', 2.5 );
  xlabel( 'Std. Deviation \sigma(C)/C' );
  ylabel( 'ENOB (bits)' );
  xlim( [ mismatchStdValues( 1 ), mismatchStdValues( end ) ] );
  xticks( [ 0.0001, 0.001, 0.01, 0.1 ] );
  xticklabels( { '0.0001', '0.001', '0.01', '0.1' } );
  set( gca, 'FontSize', 12 );
  grid on;
end
