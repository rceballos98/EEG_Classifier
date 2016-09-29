%% Make INFO
try
    load(fullfile('..','INFO','lastINFO.mat'));
    INFO = lastINFO;
catch
    makeINFOscript;
end
INFO.subjectID = '0006';
INFO.param = 'valence';
%% Preprocess and return data

preProcessingUnit = frequencyBasedPreProcessing(INFO);
[EEG, INFO] = preProcessingUnit.preProcess();

%% Generate Features

featureGenerationUnit = asymmetryFeatures(EEG, INFO);
[HA_features,HA_names] = featureGenerationUnit.getClassic();

%% Generate Features

featureGenerationUnit = asymmetryFeatures(EEG, INFO);
[FA_features,FA_names] = featureGenerationUnit.getAll();

%% Params
dim = 'valence';
res = 1;
feaNum = 150;
channels = 1:32;

%% Get Labels
labels = getResponses(INFO);
if(strcmp(INFO.param,'valence'))
    labels = labels.data(:,1);
else if(strcmp(INFO.param,'arousal'))
        labels = labels.data(:,2);
    else
        error('Unrecognized INFO.param');
    end
end
% Select Features

featureExtractionUnit = mRMR(INFO,HA_features,HA_names,labels);
[selected_HA_features, selected_HA_names] = featureExtractionUnit.extract(res,feaNum);

featureExtractionUnit = mRMR(INFO,FA_features,FA_names,labels);
[selected_FA_features, selected_FA_names] = featureExtractionUnit.extract(res,feaNum);

%%
keySet = {'delta' 'theta' 'alpha' 'beta' 'gamma'};
valueSet = [1 2 3 4 5];
bandMap = containers.Map(keySet,valueSet);
%%
pairNames = arrayfun(@(x) strsplit(selected_HA_names{x},'-'),[1:size(selected_HA_names,1)],'UniformOutput',false);
count = 0;
pairsHA = zeros(size(pairNames,2),3);
for i = 1:size(pairNames,2)
    if size(pairNames{i},2) > 3
        pairsHA(i,:) = [INFO.channelMap(pairNames{i}{1})...
            INFO.channelMap(pairNames{i}{2})...
            bandMap(pairNames{i}{3})];
    else
        pairsHA(i,:) = [INFO.channelMap(pairNames{i}{1})...
            INFO.channelMap(pairNames{i}{1})...
            bandMap(pairNames{i}{2})];
    end
end

%%
pairNames = arrayfun(@(x) strsplit(selected_FA_names{x},'-'),[1:size(selected_FA_names,1)],'UniformOutput',false);
count = 0;
pairsFA = zeros(size(pairNames,2),3);
for i = 1:size(pairNames,2)
    if size(pairNames{i},2) > 3
        pairsFA(i,:) = [INFO.channelMap(pairNames{i}{1})...
            INFO.channelMap(pairNames{i}{2})...
            bandMap(pairNames{i}{3})];
    else
        pairsFA(i,:) = [INFO.channelMap(pairNames{i}{1})...
            INFO.channelMap(pairNames{i}{1})...
            bandMap(pairNames{i}{2})];
    end
end

%%
avgPSD = mean(permute([featureGenerationUnit.de(:,:,labels==0)],[3,1,2]));
avgPSD = [avgPSD;mean(permute([featureGenerationUnit.de(:,:,labels==1)],[3,1,2]))];
avgPSD = permute(avgPSD,[2,3,1]);

%%
% temp = bsxfun(@minus,avgPSD,mean(avgPSD));
% avgPSD =  round(bsxfun(@rdivide,temp,std(avgPSD)).*res);
        
%%
tempPSD = featureGenerationUnit.de;
allPSD = zeros(size(tempPSD));
%%
for i = 1:INFO.epochs
data = tempPSD(:,:,i);
temp = bsxfun(@minus,data,mean(data));
allPSD(:,:,i) =  round(bsxfun(@rdivide,temp,std(data)).*res);
end
%%
pairs = pairsFA;
algo = 'FA';
data = featureGenerationUnit.de;
data = allPSD;
%data = avgPSD;
firstN = 60;
firstNforBand = 20;
ds = struct();
ds.chanPairs = pairs(1:firstN,1:2);
%ds.connectStrength = 1:firstN;
k = 0;
e = 23;
b = 3;
maxE = size(data,3);
ending = 'all';
maxFeaN = size(pairs,1);
state = 0;

while k ~= 27
    % Saving
    if(k == 115) %s
        filename = strcat('s',INFO.subjectID,'-e',int2str(e),'-b',...
            int2str(b),'-f',int2str(firstN),'-',dim,'-',algo,'-',ending);
        
        fprintf('Saving figure to: %s\n',filename);
        savefig(filename);
    end
    
    % Moving
    if(k == 30)
        e = e + 1;
        if(e > maxE)
            e = 1;
        end
    end
    if(k == 31)
        e = e - 1;
        if(e < 1)
            e = maxE;
        end
    end
    if(k == 29)
        b = b + 1;
        if(b > INFO.bands.n)
            b = 1;
        end
    end
    if(k == 28)
        b = b - 1;
        if(b < 1)
            b = INFO.bands.n;
        end
    end
    
    
    % Param
     if(k == 61) %+
        firstN = firstN + 1;
        if(firstN > maxFeaN)
            firstN = maxFeaN;
        end
     end
    
    if(k == 45) %-
        firstN = firstN - 1;
        if(firstN < 1)
            firstN = 1;
        end
    end
    if(k == 46) %>
        firstN = firstN + 10;
        if(firstN > maxFeaN)
            firstN = maxFeaN;
        end
     end
    
    if(k == 44) %<
        firstN = firstN - 10;
        if(firstN < 1)
            firstN = 1;
        end
    end
    
    if(k == 102)
        if(pairs == pairsHA) 
            pairs = pairsFA;
            algo = 'FA';
        else
            pairs = pairsHA;
            algo = 'HA';
        end
    end
    
    % State
    if(k == 116) %t
        state = -1; %only topo
        ending = 'topo';
    end
    if(k == 99) %c
        state = 1; %only connect
        ending = 'connect';
    end
    if(k == 97) %a
        state = 0; %all
        ending = 'all';
    end
    
    % Plotting
    clf;
    clf('reset');

    hold on
    if (state >= 0)
        colormap(blackColorMap)
        nPairs = pairs(1:firstN,:);
        pairsByBand = nPairs(nPairs(:,3) == b,1:2);
        maxFeaNforBand = size(pairsByBand,1);
        
        if(firstN >  maxFeaNforBand)
            firstNforBand =  maxFeaNforBand;
        else
            firstNforBand = firstN;
        end
        
        ds.chanPairs = pairsByBand;
        %ds.connectStrength = -100;
        topoplot_connect(ds,INFO.chanlocs(channels));
        %colorbar;
    end
    if (state <= 0)
        topoplot(data(:,b,e), INFO.chanlocs(channels));
    end
    hold off
    shg
    fprintf('e:%d b:%d f:%d/%d algo:%s\n',e,b,firstNforBand,firstN, algo);
    % Get key
    warning('off','all');
    k = getkey;
end
