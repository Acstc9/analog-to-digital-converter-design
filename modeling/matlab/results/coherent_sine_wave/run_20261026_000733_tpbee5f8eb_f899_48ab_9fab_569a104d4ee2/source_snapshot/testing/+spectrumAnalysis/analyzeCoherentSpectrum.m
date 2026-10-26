function spectrum = analyzeCoherentSpectrum(reconstructedVolts, configuration)
parameters.validateConfiguration(configuration);
sampleCount = configuration.stimulus.sampleCount;
validateattributes(reconstructedVolts, {'double'}, {'column','real','finite','numel',sampleCount});
centeredVolts = reconstructedVolts-mean(reconstructedVolts);
normalizedTransform = fft(centeredVolts)/sampleCount;
binPowerVoltsSquared = abs(normalizedTransform(1:sampleCount/2+1)).^2;
binPowerVoltsSquared(2:end-1) = 2*binPowerVoltsSquared(2:end-1);
assert(all(isfinite(binPowerVoltsSquared)), ...
    'spectrumAnalysis:NonfiniteSpectrumPower', ...
    'Spectrum power is not finite. Check the voltage scale and the reconstructed samples.');
fundamentalBin = configuration.stimulus.coherentCycleCount;
harmonicOrders = (2:configuration.analysis.maximumHarmonicOrder)';
wrappedHarmonicBins = mod(harmonicOrders*fundamentalBin,sampleCount);
harmonicBins = unique(min(wrappedHarmonicBins,sampleCount-wrappedHarmonicBins));
harmonicBins = harmonicBins(harmonicBins~=0 & harmonicBins~=fundamentalBin);
noiseMask = true(size(binPowerVoltsSquared));
noiseMask([1; fundamentalBin+1; harmonicBins+1]) = false;
spurMask = true(size(binPowerVoltsSquared));
spurMask([1 fundamentalBin+1]) = false;
signalPower = binPowerVoltsSquared(fundamentalBin+1);
assert(signalPower>0, 'spectrumAnalysis:MissingFundamental', ...
    ['No measurable fundamental exists at the configured coherent bin. ' ...
    'Check the input amplitude, output code variation, and configured cycle count.']);
noisePower = sum(binPowerVoltsSquared(noiseMask));
distortionPower = sum(binPowerVoltsSquared(harmonicBins+1));
fullScaleSinePower = ((configuration.converter.maximumInputVolts-configuration.converter.minimumInputVolts)/2)^2/2;
assert(isfinite(noisePower+distortionPower) && isfinite(fullScaleSinePower) && fullScaleSinePower>0, ...
    'spectrumAnalysis:InvalidSpectrumPowerScale', ...
    'The integrated or full-scale power is not representable. Use a numerically supported voltage range.');
spectrum.frequencyHz = (0:sampleCount/2)'*configuration.sampling.sampleRateHz/sampleCount;
spectrum.binPowerVoltsSquared = binPowerVoltsSquared;
spectrum.binPowerDbfs = 10*log10(max(binPowerVoltsSquared,realmin)/fullScaleSinePower);
spectrum.fundamentalBin = fundamentalBin;
spectrum.harmonicBins = harmonicBins;
spectrum.noiseBinMask = noiseMask;
spectrum.spurBinMask = spurMask;
spectrum.integratedPowerVoltsSquared.fundamental = signalPower;
spectrum.integratedPowerVoltsSquared.noise = noisePower;
spectrum.integratedPowerVoltsSquared.distortion = distortionPower;
spectrum.integratedPowerVoltsSquared.fullScaleSine = fullScaleSinePower;
spectrum.metrics.snrDb = 10*log10(signalPower/noisePower);
spectrum.metrics.thdDb = 10*log10(distortionPower/signalPower);
spectrum.metrics.sinadDb = 10*log10(signalPower/(noisePower+distortionPower));
spectrum.metrics.sfdrDb = 10*log10(signalPower/max(binPowerVoltsSquared(spurMask)));
spectrum.metrics.enobUncorrectedBits = (spectrum.metrics.sinadDb-1.76)/6.02;
spectrum.metrics.fundamentalDbfs = 10*log10(signalPower/fullScaleSinePower);
spectrum.metrics.enobBits = (spectrum.metrics.sinadDb-1.76-spectrum.metrics.fundamentalDbfs)/6.02;
spectrum.metrics.snrFullScaleDb = 10*log10(fullScaleSinePower/noisePower);
spectrum.metrics.worstNonharmonicSpurDbc = 10*log10(max(binPowerVoltsSquared(noiseMask))/signalPower);
spectrum.metrics.noiseFloorDbfsPerBin = 10*log10(mean(binPowerVoltsSquared(noiseMask))/fullScaleSinePower);
spectrum.harmonics = table(harmonicOrders, ...
    min(wrappedHarmonicBins,sampleCount-wrappedHarmonicBins), ...
    10*log10(binPowerVoltsSquared(min(wrappedHarmonicBins,sampleCount-wrappedHarmonicBins)+1)/signalPower), ...
    'VariableNames',{'Order','BinIndexZeroBased','LevelDbc'});
spectrum.metrics.idealQuantizationSnrDb = 6.02*configuration.converter.resolutionBits+1.76+configuration.stimulus.amplitudeDbfs;
spectrum.analysisSettings.windowName = 'Rectangular';
spectrum.analysisSettings.frequencyBinWidthHz = configuration.sampling.sampleRateHz / sampleCount;
spectrum.analysisSettings.equivalentNoiseBandwidthHz = spectrum.analysisSettings.frequencyBinWidthHz;
spectrum.analysisSettings.analysisBandLimitsHz = [0 configuration.sampling.sampleRateHz / 2];
spectrum.analysisSettings.excludedDirectCurrent = true;
spectrum.analysisSettings.minimumHarmonicOrder = 2;
spectrum.analysisSettings.maximumHarmonicOrder = configuration.analysis.maximumHarmonicOrder;
spectrum.analysisSettings.spectralReference = 'Full-scale sine mean-square power';
end
