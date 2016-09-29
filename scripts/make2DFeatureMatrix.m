function [ trial_matrix ] = make2DFeatureMatrix( subject_features, feature_names )
    feature_num = length(feature_names);
    trial_matrix = [];
    for i = 1:size(subject_features,2)
        trial_col = [];
        for f = 1:feature_num
            trial_col = vertcat(...
                trial_col, ...
                subject_features(i).(char(feature_names(f)))(:)...
                );
        end
       trial_matrix = horzcat(trial_matrix, trial_col);
    end
    trial_matrix = trial_matrix';
end
