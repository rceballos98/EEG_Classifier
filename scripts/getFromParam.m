subjects = 6:22;
dim = 'arousal';
res = 0.8;
feaNum = 5;
crossVal = 5;

genErr = zeros(size(subjects,2),1);
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
    [features,names] = featureGenerationUnit.getClassic();
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

    
    %% Extract Features
    featureExtractionUnit = mRMR(INFO,features,names,labels);
    [selected_features, selected_names] = featureExtractionUnit.extract(res,feaNum);
    
    %% Classify
    SVMModel = fitcsvm(selected_features, labels,'KernelFunction','linear','Standardize','on','CrossVal','on','KFold', crossVal);
    genErr(countSub) = kfoldLoss(SVMModel)
    
    %If table is empty or row doesn't exists, add row
  
end

genErrDE = genErr;