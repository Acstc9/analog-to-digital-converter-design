function result = runCoherentSineWaveTest(configuration, outputRoot)
arguments
    configuration (1,1) struct = parameters.createDefaultConfiguration()
    outputRoot (1,1) string = ""
end
parameters.validateConfiguration(configuration);
projectRoot = fileparts(fileparts(mfilename('fullpath')));
if strlength(outputRoot)==0
    outputRoot = fullfile(projectRoot,'results','coherent_sine_wave');
end
[inputVoltageAtTime, stimulus] = inputSignals.generateCoherentContinuousSineWave(configuration);
[sampling, conversion, capacitorArray] = converterModel.simulateConverter(inputVoltageAtTime, ...
    configuration.converter,configuration.sampling,configuration.stimulus.sampleCount);
spectrum = spectrumAnalysis.analyzeCoherentSpectrum(conversion.reconstructedVolts,configuration);
result.configuration = configuration;
result.stimulus = stimulus;
result.stimulus.timeSeconds = sampling.timeSeconds;
result.stimulus.inputVolts = sampling.heldInputVolts;
result.sampling = sampling;
result.capacitorArray = capacitorArray;
result.conversion = conversion;
result.spectrum = spectrum;
result.metadata.createdAt = char(datetime('now','TimeZone','UTC','Format',"yyyy-MM-dd'T'HH:mm:ssXXX"));
result.metadata.matlabVersion = version;
result.metadata.implementationVersion = '3.0.2';
result.metadata.circuitReference = 'Analog Devices, Understanding SAR ADCs: Their Architecture and Comparison with Other ADCs, Figure 3; explicit ideal comparator-reference bias added by project choice';
result.metadata.analysisReference = 'Analog Devices, Testing Data Converters, section 5.2; Figure 5.29, Equation 5.23, Figures 5.65-5.68';
[result.outputDirectory,result.metadata] = reporting.saveSimulationResults(result,outputRoot);
reporting.displayPerformanceMetrics(spectrum);
fprintf('Results: %s\n',result.outputDirectory);
end
