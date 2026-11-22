function plotEnobVsMismatch()
  mismatchValues = 0.0001 : 0.0001 : 0.1;

  %% Random capacitor mismatch
  arrayCount = 100;
  enobBits = nan( arrayCount, numel( mismatchValues ) );

  for iLevel = 1 : numel( mismatchValues )
    p = createSimulationConfiguration( "binary", mismatchValues( iLevel ) );
    inputVoltageSamples = generateSineSamples( p );
    for iArray = 1 : arrayCount
      capacitorArray = synthesizeCDAC( p );
      enobBits( iArray, iLevel ) = evaluateEnob( capacitorArray, p, inputVoltageSamples );
    end
  end
  medianEnobBits = median( enobBits, 1 );

  %% Worst-case MSB weight
  p = createSimulationConfiguration( "binary", 0 );
  nominalArray = synthesizeCDAC( p );
  inputVoltageSamples = generateSineSamples( p );
  msbHighEnobBits = nan( size( mismatchValues ) );

  for iLevel = 1 : numel( mismatchValues )
    mismatch = mismatchValues( iLevel );
    capacitorArray.capacitanceFemtofarads = nominalArray.capacitanceFemtofarads * ( 1 - mismatch );
    capacitorArray.capacitanceFemtofarads( 1 ) = nominalArray.capacitanceFemtofarads( 1 ) * ( 1 + mismatch );
    capacitorArray.totalCapacitanceFemtofarads = sum( capacitorArray.capacitanceFemtofarads );
    msbHighEnobBits( iLevel ) = evaluateEnob( capacitorArray, p, inputVoltageSamples );
  end

  %% Plot both ENOB curves
  figure( 'Color', 'w', 'Position', [ 100, 100, 1000, 620 ] );
  semilogx( mismatchValues, medianEnobBits, 'b-', mismatchValues, msbHighEnobBits, 'k--', 'LineWidth', 2.5 );
  xlabel( 'Relative unit-capacitor mismatch' );
  ylabel( 'ENOB (bits)' );
  xlim( [ mismatchValues( 1 ), mismatchValues( end ) ] );
  xticks( [ 0.0001, 0.001, 0.01, 0.1 ] );
  xticklabels( { '0.0001', '0.001', '0.01', '0.1' } );
  set( gca, 'FontSize', 12 );
  grid on;
  legend( 'Random mismatch (median, \sigma(C)/C)', 'MSB high, others low (|\Delta C|/C)', 'Location', 'southwest' );
end

function enobBits = evaluateEnob( capacitorArray, p, inputVoltageSamples )
  binaryCodes = nan( p.sampleCount, p.resolutionBits );
  for iSample = 1 : p.sampleCount
    binaryCodes( iSample, : ) = cbwSarADC( capacitorArray, p, inputVoltageSamples( iSample ) );
  end
  outputVolts = idealDAC( binaryCodes, p );
  spectrum = processAdcData( outputVolts, p );
  enobBits = spectrum.enobBits;
end
