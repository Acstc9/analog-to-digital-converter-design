function snapshot = saveSourceSnapshot(runDirectory)
sourceRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
snapshot.directory = 'source_snapshot';
snapshotRoot = fullfile(runDirectory,snapshot.directory);
sourceFiles = [dir(fullfile(sourceRoot,'+converterModel','**','*.m')); ...
    dir(fullfile(sourceRoot,'testing','**','*.m')); ...
    dir(fullfile(sourceRoot,'main.m')); ...
    dir(fullfile(sourceRoot,'documentation','MODEL_DEFINITIONS.md'))];
snapshot.files = repmat(struct('path','','sha256',''),numel(sourceFiles),1);
for fileIndex = 1:numel(sourceFiles)
    sourcePath = fullfile(sourceFiles(fileIndex).folder,sourceFiles(fileIndex).name);
    relativePath = sourcePath(numel(sourceRoot)+2:end);
    destinationPath = fullfile(snapshotRoot,relativePath);
    destinationFolder = fileparts(destinationPath);
    if ~isfolder(destinationFolder)
        mkdir(destinationFolder);
    end
    copyfile(sourcePath,destinationPath);
    fileIdentifier = fopen(destinationPath,'rb');
    assert(fileIdentifier~=-1,'reporting:SourceSnapshotFailed','Cannot read a copied source file.');
    fileCleanup = onCleanup(@() fclose(fileIdentifier));
    fileBytes = fread(fileIdentifier,Inf,'*uint8');
    clear fileCleanup;
    digest = java.security.MessageDigest.getInstance('SHA-256');
    digest.update(fileBytes);
    snapshot.files(fileIndex).path = strrep(relativePath,filesep,'/');
    snapshot.files(fileIndex).sha256 = lower(reshape(dec2hex(typecast(digest.digest(),'uint8'),2).',1,[]));
end
end
