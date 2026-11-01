%% Project paths
projectRoot = fileparts( fileparts( mfilename( 'fullpath' ) ) );
addpath( fullfile( projectRoot, 'sim-config' ) );
addpath( fullfile( projectRoot, 'models' ) );
addpath( fullfile( projectRoot, 'function' ) );
addpath( fullfile( projectRoot, 'function', 'cdac-topologies' ) );
addpath( fullfile( projectRoot, 'function', 'data-processing' ) );
addpath( fullfile( projectRoot, 'function', 'plotting' ) );

%% Configure the experiment and generate the continuous input
simulationConfiguration = createSimulationConfiguration();
[inputVoltageAtTime, stimulus] = generateCoherentContinuousSineWave( simulationConfiguration );

%% Run the complete converter, then analyze its output
outputCodes = cbwSarADC( inputVoltageAtTime, simulationConfiguration );
spectrum = processAdcData( outputCodes, simulationConfiguration );

%% Assemble the simulation record
result = struct();
result.configuration = simulationConfiguration;
result.stimulus = stimulus;
result.conversion.codes = outputCodes;
result.spectrum = spectrum;

%% Display the results
plotFrequencySpectrum( result );
