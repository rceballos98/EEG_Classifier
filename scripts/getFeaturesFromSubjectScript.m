% Iterate over each video
sub = subData;
FS = INFO.Fs;
BANDS = INFO.BANDS;
eMAP = INFO.mapping;

trial_num = size(sub.eeg,3);
%features = empty(trial_num,1);

for trial = 1:size(sub.eeg,3)
  
  % add freq analysis
  fb = freqBands(sub.eeg(:,:,trial), FS, BANDS);
  
  % get features
  features(trial) = extractFeaturesFromPSD(fb.f.pbc,eMAP);
end