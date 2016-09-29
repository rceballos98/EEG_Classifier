%% Software Engineering
% Rodrigo Ceballos

%% Run tests
% tests = tests_EEG_classification_framework;
% testResults = run(tests, 'testEpoching');
% table(testResults);
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
[features,names] = featureGenerationUnit.getClassic();

%[features,names] = featureGenerationUnit.getAll();
%[features,names] = featureGenerationUnit.getDE();
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

%% Extract Features
res = 0.4;
feaNum = 30;
featureExtractionUnit = mRMR(INFO,features,names,labels);
[selected_features, selected_names] = featureExtractionUnit.extract(res,feaNum);

%% Classify 

SVMModel = fitcsvm(selected_features, labels,'KernelFunction','linear','Standardize','on','CrossVal','on','KFold', 5);
%indGenError = kfoldLoss(SVMModelValence,'mode','individual')

avgGeneralizationError = kfoldLoss(SVMModel)

%CVSVMModelValence = crossval(SVMModelValence);
%[predicted_labels_train,scores] = predict(CVSVMModelValence, train_data);
%[predicted_labels,scores] = predict(SVMModelValence, test_data);

%newRow = {numFeatures res avgGeneralizationError num2cell(features_i) SVMModel};
%resTable = [resTable; cell2table(newRow, 'VariableNames',resTable.Properties.VariableNames)];
