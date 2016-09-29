function [features] = getFeaturesFromSubject(sub, info)

% Iterate over each video
FS = info.fs;
BANDS = info.BANDS;
eMAP = info.mapping;

for trial = 1:size(sub.eeg,3) 
  % add freq analysis
  fb = freqBands(sub.eeg(:,:,trial), FS, BANDS);
  
  % get features
  features(trial) = extractFeaturesFromPSD(fb.f.pbc,eMAP);
end

