function  [features] = extractFeaturesFromPSD(psdVal, mappings)
% input is a power spectrum density (PSD) array - one value per channel and
% per frequency band

channelMap = mappings.channels;
assymPairs = mappings.assymPairs;
caudPairs = mappings.caudPairs;
nChannels = size(psdVal, 1);
nBands = size(psdVal, 2);
nAssymPairs = size(assymPairs,1);
nCaudPairs = size(caudPairs,1);


% 1. power spectral density (PSD)
features.psd = psdVal;

% 2. differential entropy (DE)
% in a certain band, DE is equivalent to the logarithmic PSD for a
% fixed length EEG sequence.
features.de = log(psdVal); % not sure what base we should use here...

% 3. differential asymmetry (DASM)
features.dasm = zeros(nAssymPairs, nBands);
for i=1:nAssymPairs
    %disp(assymPairs{i,1})
    left = channelMap(assymPairs{i,1});
    right = channelMap(assymPairs{i,2});
    features.dasm(i,:) = features.de(left,:) - features.de(right,:);
end
% 4. rational asymmetry (RASM)
features.rasm = zeros(nAssymPairs, nBands);
for i=1:nAssymPairs
    %disp(assymPairs{i,1})
    left = channelMap(assymPairs{i,1});
    right = channelMap(assymPairs{i,2});
    features.rasm(i,:) = features.de(left,:) / features.de(right,:);
end

% 5. asymmetry (ASM)
features.asm = zeros(nAssymPairs, nBands);
nTotal = nAssymPairs * nBands;
temp = arrayfun(@(x) [features.dasm(x) features.rasm(x)],1:nTotal,'un',0);
temp = cell2mat(temp);
features.asm = reshape(temp,[nAssymPairs,nBands,2]);

% 6.differential caudality (DCAU)
features.dcau = zeros(nCaudPairs, nBands);
for i=1:nCaudPairs
    %disp(caudPairs{i,1})
    front = channelMap(caudPairs{i,1});
    back = channelMap(caudPairs{i,2});
    features.dcau(i,:) = features.de(front,:) - features.de(back,:);
end

end
