req_fieldnames = {
    'setname'
    'filename'
    'filepath'
    'subject'
    'group'
    'condition'
    'session'
    'comments'
    'nbchan'
    'trials'
    'pnts'
    'srate'
    'xmin'
    'xmax'
    'times'
    'data'
    'icaact'
    'icawinv'
    'icasphere'
    'icaweights'
    'icachansind'
    'chanlocs'
    'urchanlocs'
    'chaninfo'
    'ref'
    'event'
    'urevent'
    'eventdescription'
    'epoch'
    'epochdescription'
    'reject'
    'stats'
    'specdata'
    'specicaact'
    'splinefile'
    'icasplinefile'
    'dipfit'
    'history'
    'saved'
    'etc'
    };
% Load EEG data
subjectID = '0001_test';
preProcessingUnit = frequencyBasedPreProcessing(subjectID);
EEG = preProcessingUnit.preProcess();
%%
for i = 1:size(req_fieldnames,1)
    isfield(EEG,req_fieldnames(i))
end