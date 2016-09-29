%% Make Bands
INFO = struct();
INFO.fs = 256;
INFO.BANDS.freq = [
    [1 3] 
    [4 7]
    [8 13]
    [14 30]
    [31 50]
    ];
INFO.BANDS.names = {'delta' 'theta' 'alpha' 'beta' 'gamma'} ;

%% Subject ID
subID = '0002';

%% Make struct
subData = struct();
fprintf(1,'Making SUB Struct: %s\n',subID);
[subData.eeg, EEG] = getAndPreProcess(subID);

%% Get electrode mappings
INFO.mapping = getElectrodeMapping(EEG);
%%
subData.features = getFeaturesFromSubject(subData,INFO);

%% Save data (eeg and features)
save( strcat('..\data\s',subID),'subData');

%% Add to full data struct
features2D = make2DFeatureMatrix(subData.features,fieldnames(subData.features));


%% Get Labels
labels = getResponses(subID, trials2);

%% Make Table
ColNames = {'NumFeatures' 'Resolution' 'avgError' 'features' 'model'};
valClassifRes = cell2table(cell(0,5),'VariableNames', ColNames);
aroClassifRes = cell2table(cell(0,5),'VariableNames', ColNames);
%%
for res=[1 2 5 10 20]
    for f = [1,2,3,5:5:40]  
%       fprintf('\n NumFeature:    ');
%       fprintf(1,'\b\b\b%d',f); 
%       fprintf('\n Resolution:    ');
%       fprintf(1,'\b\b\b%d',res);
      valClassifRes = classifySVM(features2D, labels.user_norm(:,1), f, res, valClassifRes); % VALENCE = 1
      disp(valClassifRes(end,:));
   end
end
%%
save( strcat('..\results\val_',subID),'valClassifRes');

%%
for res=[1 2 5 10 20]
    for f = [1,2,3,5:5:40] 
%       fprintf('\n NumFeature:    ');
%       fprintf(1,'\b\b\b%d',f); 
%       fprintf('\n Resolution:    ');
%       fprintf(1,'\b\b\b%d',res);
      aroClassifRes = classifySVM(features2D, labels.data(:,2), f, res, aroClassifRes); % AROUSAL = 2
      disp(aroClassifRes(end,:));
   end
end
%%
save( strcat('..\results\aro_',subID),'aroClassifRes');
save( strcat('..\results\features_aro',subID),'features_aro_i');