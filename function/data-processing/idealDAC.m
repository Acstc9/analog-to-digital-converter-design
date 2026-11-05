function outputVolts = idealDAC( binaryCodes, p )
  decimalCodes = bi2de( binaryCodes, 'left-msb' );
  leastSignificantBitVolts = p.vRef / 2 ^ p.resolutionBits;
  outputVolts = decimalCodes * leastSignificantBitVolts;
end
