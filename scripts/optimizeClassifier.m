%% Software Engineering
% Rodrigo Ceballos

%% Make INFO

% Pre-Process
INFO.subjectID = '0006';
INFO.name_pre_append = 'EmotionRecognition_';
INFO.min_freq = 0.5;
INFO.max_freq = 70;
INFO.notch_freq = 50;
INFO.notch_amp = 0.2;
INFO.resample_freq = 256;
INFO.trigger_names = {  'S  1'  'S  2'  'S  3'  'S  4'  'S  5'...
    'S  6'  'S  7'  'S  8'  'S  9'  'S 10'  'S 11'  'S 12'...
    'S 13'  'S 14'  'S 15'  'S 16'  'S 17'  'S 18'  'S 19'...
    'S 20'  'S 21'  'S 22'  'S 23'  'S 24'  'S 25'  'S 26'...
    'S 27'  'S 28'  'S 29'  'S 30'  'S 31'  'S 32'  'S 33'...
    'S 34'  'S 35'  'S 36'  'S 37'  'S 38'  'S 39'  'S 40'...
    'S 41'  'S 42'  'S 43'  'S 44'  'S 45'  'S 46'  'S 47'...
    'S 48'  'S 49'  'S 50'  'S 51'  'S 52'  'S 53'  'S 54'...
    'S 55'  'S 56'  'S 57'  'S 58'  'S 59'  'S 60' 'S 61'...
    'S 62' 'S 63' 'S 64' 'S 65' };

% Features
INFO.fs = 256;

INFO.bands.freq = [
    [1 3]
    [4 7]
    [8 13]
    [14 30]
    [31 50]
    ];
INFO.bands.n = size(INFO.bands.freq,1);
INFO.bands.names = {'delta' 'theta' 'alpha' 'beta' 'gamma'} ;

INFO.pairs.lateral ={'Fp1' 'Fp2'; 'F7' 'F8'; 'F3' 'F4'; ...
    'T7' 'T8'; 'P7' 'P8'; 'C3' 'C4'; 'P3' 'P4'; ...
    'O1' 'O2'; 'F7' 'F8'; 'FC5' 'FC6'; 'FC1' 'FC2'; ...
    'CP5' 'CP6'; 'CP1' 'CP2'; 'PO9' 'PO10'; 'TP9' 'TP10'};

INFO.pairs.caudal = {'FC5' 'CP5'; 'FC1' 'CP1'; 'FC2' 'CP2'; 'FC6' 'CP6'; ...
    'F7' 'P7'; 'F3' 'P3'; 'Fz' 'Pz'; 'F4' 'P4'; 'F8' 'P8'; ...
    'Fp1' 'O1'; 'Fp2' 'O2'};
INFO.epochs = 60;
%%
feaNums = [[110:10:200]];
resSpan = [[0.1:0.2:0.9],[1:5]];
subjects = 6:22;
subjectNum = size(subjects,2);
dim = 'valence';

% %% MAKE TABLE
subjectVector = cell(1,subjectNum);
count = 1;
for i = subjects
    subjectVector{count} = strcat('s',int2str(i));
    count = count + 1;
end
% 
 ColNames = ['NumFeatures' 'Resolution' 'avgError' 'SD' subjectVector];
% %% CAREFUL
% aroAccuracyMatrixAllSubAllFea = cell2table(cell(0,4+subjectNum),'VariableNames', ColNames);
% %% CAREFUL
%valAccuracyMatrixAllSubAllFea = cell2table(cell(0,4+subjectNum),'VariableNames', ColNames);
% 
valAccuracyMatrixAllSubALL = cell2table(cell(0,4+subjectNum),'VariableNames', ColNames);
%% OPTIMIZE
accuracyTable = valAccuracyMatrixAllSubALL;
featureNamesMatrix = cell(subjectNum,size(resSpan,2));
%% Pre stuff
% preProcessingUnit = frequencyBasedPreProcessing(INFO);
% [EEG, INFO] = preProcessingUnit.preProcess();
% INFO.channelMap = containers.Map({EEG.chanlocs.labels} , {1, 2, 3, 4, ...
%     5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, ...
%     23, 24, 25, 26, 27, 28, 29, 30, 31, 32});
% INFO.reverseMap = containers.Map({1, 2, 3, 4, ...
%     5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, ...
%     23, 24, 25, 26, 27, 28, 29, 30, 31, 32},{EEG.chanlocs.labels});
% load(fullfile('..','data','trials2'));
%%
countSub = 0;
for subI = subjects
    countSub = countSub + 1;
    %% print and make correct subjectID
    if(subI < 10)     
        INFO.subjectID = strcat('000',int2str(subI));
    else
        INFO.subjectID = strcat('00',int2str(subI));
    end
    
    fprintf(1,'\nSubject: %s\n',INFO.subjectID);
    
    %% Preprocess and return data
    preProcessingUnit = frequencyBasedPreProcessing(INFO);
    [EEG, INFO] = preProcessingUnit.preProcess();
    %% Generate Features
    featureGenerationUnit = asymmetryFeatures(EEG, INFO);
    [features,names] = featureGenerationUnit.getAll();
    %% Get Labels  
    labels = getResponses(INFO.subjectID, trials2);
    %% Arousal or Valence
    if strcmp(dim, 'valence')
        labels = labels.data(:,1);
    else
        if strcmp(dim, 'arousal')
            labels = labels.data(:,2);
        else
            error('%s is not recognized as a valid argument',dim);
        end
    end
    %% Make feature extrction
    
    
    %% Set up for loop
    totalOperations = size(feaNums,2)*size(resSpan,2);
    countOp = 0;
    countRes = 0;
    fprintf('\nProgress:     ');
    for res = resSpan
        %% Extract Features
        featureExtractionUnit = mRMR(INFO,features,names,labels);
        [selected_features, selected_names] = featureExtractionUnit.extract(res,max(feaNums));
        countRes = countRes + 1;
        featureNamesMatrix{countSub,countRes} = selected_names;
        for feaNum = feaNums                         
            %% Classify
            SVMModel = fitcsvm(selected_features(:,1:feaNum), labels,'KernelFunction','linear','Standardize','on','CrossVal','on','KFold', 60);       
            
            tablePos = (accuracyTable.NumFeatures == feaNum)&...
                (accuracyTable.Resolution == res);
            countCopies = sum(tablePos);
            
            %If table is empty or row doesn't exists, add row
            if(isempty(tablePos) || countCopies == 0)
                newRow = [feaNum res NaN(1,subjectNum + 2)];
                accuracyTable = [accuracyTable; array2table(newRow, 'VariableNames',accuracyTable.Properties.VariableNames)];
                tablePos = size(accuracyTable,1);
            end
            %If not a repeat, t
            if isnan(accuracyTable(tablePos,:).( strcat('s',int2str(subI))))
                accuracyTable(tablePos,:).( strcat('s',int2str(subI))) =...
                    kfoldLoss(SVMModel); 
                rowData = table2array(accuracyTable(tablePos,5:subjectNum));
                accuracyTable(tablePos,:).avgError = nanmean(rowData);
                accuracyTable(tablePos,:).SD = nanstd(rowData);
            else
                warning('Found duplicate, did NOT update');
            end
            countOp = countOp + 1;
            fprintf('\b\b\b\b%.2f',countOp/totalOperations);
        end
        save('lastAccuracyTable','accuracyTable');
    end
end

valAccuracyMatrixAllSubAll = accuracyTable;
valFeatureNamesMatrixAll = featureNamesMatrix;
save('lastAccuracyTable','accuracyTable');
save('lastFeatureNamesMatrix','featureNamesMatrix');