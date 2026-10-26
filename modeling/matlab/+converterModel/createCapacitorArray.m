function capacitorArray = createCapacitorArray(converter)
capacitorArray.unitCapacitorCounts = [2.^(converter.resolutionBits-1:-1:0), 1];
capacitorArray.nominalCapacitanceFarads = converter.unitCapacitanceFarads*capacitorArray.unitCapacitorCounts;
capacitorArray.capacitanceFarads = capacitorArray.nominalCapacitanceFarads;
validateattributes(capacitorArray.capacitanceFarads, {'double'}, {'row','real','finite','positive'});
validateattributes(sum(capacitorArray.capacitanceFarads), {'double'}, {'scalar','finite','positive'});
end
