function [ resTable, features_i ] = classifySVM( features, labels, numFeatures, res, resTable )
%% Cheat
%features(:,1) = labels;

%% Normalize Features
temp = bsxfun(@minus,features,mean(features));
features = bsxfun(@rdivide,temp,std(features));

%% Discretize
features_res = round(features.*res);


%% Select Featuresres
features_i = feast('mrmr',numFeatures,features_res, labels);
features = features(:,features_i);


%% Cross Val
SVMModel = fitcsvm(features, labels,'KernelFunction','linear','Standardize','on','CrossVal','on','KFold', 10);
%indGenError = kfoldLoss(SVMModelValence,'mode','individual')
avgGeneralizationError = kfoldLoss(SVMModel);

%CVSVMModelValence = crossval(SVMModelValence);
%[predicted_labels_train,scores] = predict(CVSVMModelValence, train_data);
%[predicted_labels,scores] = predict(SVMModelValence, test_data);

newRow = {numFeatures res avgGeneralizationError num2cell(features_i) SVMModel};
resTable = [resTable; cell2table(newRow, 'VariableNames',resTable.Properties.VariableNames)];
end
