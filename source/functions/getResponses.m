function [responses] = getResponses(INFO)
subjectID = INFO.subjectID;
trials = INFO.trials2;
raw_dir_name = INFO.dir_names.rawData;
resp_dir_name = INFO.dir_names.responses.saved;
log_post_pend = INFO.dir_names.responses.post_pend;
responseData = importLogFile(...
    fullfile(raw_dir_name,subjectID,strcat(subjectID,log_post_pend)));
save(fullfile(resp_dir_name,strcat('r',subjectID)),'responseData');
iVal = ismember(responseData.Trial,trials.val);
iAro = ismember(responseData.Trial,trials.aro);
iPic = iVal(2:end);
valResp = responseData.Code(iVal);
aroResp = responseData.Code(iAro);
picLabels = ceil(responseData.Code(iPic)/75);
picVal = 1 - mod(picLabels,2);
picAro = picLabels > 2;

responses = struct();
responses.data = [picVal, picAro];
responses.user = [valResp, aroResp];
responses.user_norm = round(normalize_median(responses.user));
end