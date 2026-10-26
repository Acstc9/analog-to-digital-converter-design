function [outputDirectory, metadata] = saveSimulationResults(result, outputRoot)
if ~isfolder(outputRoot)
    mkdir(outputRoot);
end
rootPath = java.io.File(char(outputRoot));
if ~rootPath.isAbsolute()
    rootPath = java.io.File(char(fullfile(pwd,outputRoot)));
end
outputRoot = string(rootPath.getCanonicalPath());
[~,uniqueSuffix] = fileparts(tempname(outputRoot));
runTimestamp = string(datetime('now','TimeZone','UTC','Format','yyyyMMdd_HHmmss'));
outputDirectory = fullfile(outputRoot,"run_"+runTimestamp+"_"+string(uniqueSuffix));
[~,runName] = fileparts(outputDirectory);
workingDirectory = fullfile(outputRoot,".incomplete_"+runName);
mkdir(workingDirectory);
result.outputDirectory = outputDirectory;
result.metadata.sourceSnapshot = reporting.saveSourceSnapshot(workingDirectory);
metadata = result.metadata;
save(fullfile(workingDirectory,'run.mat'),'result');
summary.configuration = result.configuration;
summary.analysisReference = result.metadata.analysisReference;
summary.analysisSettings = result.spectrum.analysisSettings;
summary.metadata = result.metadata;
summary.metrics = result.spectrum.metrics;
summary.metricNonfiniteStatus = struct();
metricNames = fieldnames(summary.metrics);
for metricIndex = 1:numel(metricNames)
    metricName = metricNames{metricIndex};
    metricValue = summary.metrics.(metricName);
    if ~isfinite(metricValue)
        summary.metricNonfiniteStatus.(metricName) = describeNumericStatus(metricValue);
    end
end
summary.integratedPowerVoltsSquared = result.spectrum.integratedPowerVoltsSquared;
summary.harmonics = table2struct(result.spectrum.harmonics);
for harmonicIndex = 1:numel(summary.harmonics)
    summary.harmonics(harmonicIndex).LevelDbcStatus = describeNumericStatus(summary.harmonics(harmonicIndex).LevelDbc);
end
writetable(struct2table(result.spectrum.metrics),fullfile(workingDirectory,'metrics.csv'));
writetable(result.spectrum.harmonics,fullfile(workingDirectory,'harmonics.csv'));
spectrumTable = table(result.spectrum.frequencyHz,result.spectrum.binPowerDbfs, ...
    'VariableNames',{'FrequencyHz','BinPowerDbfs'});
writetable(spectrumTable,fullfile(workingDirectory,'spectrum.csv'));
figureHandle = reporting.plotFrequencySpectrum(result,"off");
figureCleanup = onCleanup(@() close(figureHandle));
exportgraphics(figureHandle,fullfile(workingDirectory,'frequency_spectrum.png'),'Resolution',180);
exportgraphics(figureHandle,fullfile(workingDirectory,'frequency_spectrum.pdf'),'ContentType','vector');
summary.status = 'complete';
summary.exportFormatVersion = 3;
fileIdentifier = fopen(fullfile(workingDirectory,'summary.json'),'w');
assert(fileIdentifier~=-1,'reporting:ReportWriteFailed','Cannot create summary.');
fileCleanup = onCleanup(@() fclose(fileIdentifier));
fprintf(fileIdentifier,'%s\n',jsonencode(summary,PrettyPrint=true));
clear fileCleanup;
[moveSucceeded,moveMessage] = movefile(workingDirectory,outputDirectory);
assert(moveSucceeded,'reporting:ReportFinalizeFailed','Cannot finalize the result directory: %s',moveMessage);
end

function status = describeNumericStatus(value)
if isnan(value)
    status = "NaN";
elseif value==Inf
    status = "+Inf";
elseif value==-Inf
    status = "-Inf";
else
    status = "finite";
end
end
