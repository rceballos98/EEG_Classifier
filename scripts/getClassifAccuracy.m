% % create and initialize classification results table
% subjectVector = cell(1,32);
% for i = 1:32
%     subjectVector{i} = strcat('s',int2str(i));
% end
% ColNames = ['NumFeatures' 'Resolution' 'avgError' subjectVector];
% classifRes = cell2table(cell(0,35),'VariableNames', ColNames)
%
% % Call as classifRes = getClassifAccuracy(featureMatrix, subLabels, 'valence', 60, 100, classifRes)
%
function [valClassifRes] = getClassifAccuracy(featureMatrix, subLabels, dim, numFeatures, res, valClassifRes)%, preSelect, featureCount
    subNum = 17;
    genErrors = zeros(1,subNum);
    fprintf('\n Classifying Subjects:  ');
    for subject = 1:subNum
        
        if(subject < 10)
        fprintf(1,'\b%d',subject); 
        else
        fprintf(1,'\b\b%d',subject);
        end
    
        subjectName = strcat('s',int2str(subject));
        features = featureMatrix.(char(subjectName));
        
        %% featurePreselection 
        %features = features(:,featureCount(1:preSelect,1));

        %% Lables Subject Dependant
        if strcmp(dim, 'valence')
            labels = subLabels(subject,:,3)';
        end
        if strcmp(dim, 'arousal')
           labels = subLabels(subject,:,4)'; 
        end
        
        %% Cheat
        %features(:,1) = labels;

        %% Normalize Features
        temp = bsxfun(@minus,features,mean(features));
        features = bsxfun(@rdivide,temp,std(features));
        
        %% Discretize
        %res = 100;
        features_res = round(features.*res);

        %% Select Features
        features_i = feast('mrmr',numFeatures,features_res, labels);
        features = features(:,features_i);

        %% Cross Val
        SVMModelValence = fitcsvm(features, labels,'KernelFunction','linear','Standardize','on','CrossVal','on','KFold', 40);
        %indGenError = kfoldLoss(SVMModelValence,'mode','individual');
        avgGeneralizationError = kfoldLoss(SVMModelValence);

        %% 
        genErrors(subject) = avgGeneralizationError; 
    end
    
    % Update classifRes table by adding a new row
    newRow = [numFeatures res mean(genErrors) std(genErrors) genErrors];
    valClassifRes = [valClassifRes; array2table(newRow, 'VariableNames',valClassifRes.Properties.VariableNames)];
    
    fprintf('\n done!\n'); 
end