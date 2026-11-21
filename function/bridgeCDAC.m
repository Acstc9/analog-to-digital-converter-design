function cdacOutputVolts = bridgeCDAC( capacitorArray, p, inputVolts, switchPositions )
  msbSampledChargeFemtocoulombs = -capacitorArray.msbTotalCapacitanceFemtofarads * inputVolts;
  lsbSampledChargeFemtocoulombs = -capacitorArray.lsbTotalCapacitanceFemtofarads * inputVolts;

  msbBottomPlateVolts = switchPositions( 1 : p.msbBitCount ) * p.vRef;
  lsbBottomPlateVolts = [ switchPositions( p.msbBitCount + 1 : end ) * p.vRef, 0 ];

  msbBottomPlateContributionFemtocoulombs = sum( capacitorArray.msbCapacitanceFemtofarads .* msbBottomPlateVolts );
  lsbBottomPlateContributionFemtocoulombs = sum( capacitorArray.lsbCapacitanceFemtofarads .* lsbBottomPlateVolts );

  msbChargeTermFemtocoulombs = msbSampledChargeFemtocoulombs + msbBottomPlateContributionFemtocoulombs;
  lsbChargeTermFemtocoulombs = lsbSampledChargeFemtocoulombs + lsbBottomPlateContributionFemtocoulombs;

  effectiveCapacitanceFemtofarads = capacitorArray.msbTotalCapacitanceFemtofarads + capacitorArray.bridgeCapacitanceFemtofarads * capacitorArray.lsbTotalCapacitanceFemtofarads / ( capacitorArray.lsbTotalCapacitanceFemtofarads + capacitorArray.bridgeCapacitanceFemtofarads );
  cdacOutputVolts = ( msbChargeTermFemtocoulombs + capacitorArray.bridgeCapacitanceFemtofarads * lsbChargeTermFemtocoulombs / ( capacitorArray.lsbTotalCapacitanceFemtofarads + capacitorArray.bridgeCapacitanceFemtofarads ) ) / effectiveCapacitanceFemtofarads;
end
