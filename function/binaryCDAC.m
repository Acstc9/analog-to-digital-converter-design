function cdacOutputVolts = binaryCDAC( capacitorArray, p, inputVolts, switchPositions )
  sampledChargeFemtocoulombs = -capacitorArray.totalCapacitanceFemtofarads * inputVolts;
  bottomPlateVolts = [ switchPositions * p.vRef, 0 ];
  bottomPlateContributionFemtocoulombs = sum( capacitorArray.nominalCapacitanceFemtofarads .* bottomPlateVolts );
  cdacOutputVolts = ( sampledChargeFemtocoulombs + bottomPlateContributionFemtocoulombs ) / capacitorArray.totalCapacitanceFemtofarads;
end
