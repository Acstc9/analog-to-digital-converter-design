%% Simulation parameters
resolutionBits = 12;
sampleRateHz = 1e6;
acquisitionDurationSeconds = 200e-9; % Project timing assumptions, not device specifications.
bitDecisionDurationSeconds = 25e-9;
minimumInputVolts = 0;
maximumInputVolts = 1;
unitCapacitanceFarads = 10e-15;
samplingTopPlateVoltageVolts = 0;
comparatorReferenceShiftVolts = (maximumInputVolts-minimumInputVolts)/2^(resolutionBits+1); % Intentional ideal reference bias.
sampleCount = 16384;
coherentCycleCount = 997; % Input frequency = coherentCycleCount * sampleRateHz / sampleCount.
amplitudeDbfs = -1; % 0 = full-scale sine; negative values reduce its amplitude.
maximumHarmonicOrder = 6;

%% Run and display
projectRoot = fileparts(mfilename('fullpath'));
addpath(projectRoot);
addpath(fullfile(projectRoot, 'testing'));

configuration = parameters.createDefaultConfiguration();
configuration.converter.resolutionBits = resolutionBits;
configuration.converter.minimumInputVolts = minimumInputVolts;
configuration.converter.maximumInputVolts = maximumInputVolts;
configuration.converter.unitCapacitanceFarads = unitCapacitanceFarads;
configuration.converter.samplingTopPlateVoltageVolts = samplingTopPlateVoltageVolts;
configuration.converter.comparatorReferenceShiftVolts = comparatorReferenceShiftVolts;
configuration.sampling.sampleRateHz = sampleRateHz;
configuration.sampling.acquisitionDurationSeconds = acquisitionDurationSeconds;
configuration.sampling.bitDecisionDurationSeconds = bitDecisionDurationSeconds;
configuration.stimulus.sampleCount = sampleCount;
configuration.stimulus.coherentCycleCount = coherentCycleCount;
configuration.stimulus.amplitudeDbfs = amplitudeDbfs;
configuration.analysis.maximumHarmonicOrder = maximumHarmonicOrder;

result = runCoherentSineWaveTest(configuration);
spectrumFigure = reporting.plotFrequencySpectrum(result);
drawnow;
