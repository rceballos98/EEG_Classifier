% Shared Variables
INFO = struct();
INFO.subjectID = '0001_test';
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
INFO.fs = 256;
INFO.BANDS.freq = [
    [1 3]
    [4 7]
    [8 13]
    [14 30]
    [31 50]
    ];
INFO.BANDS.names = {'delta' 'theta' 'alpha' 'beta' 'gamma'} ;

% Init preprocessing
preProcessingUnit = frequencyBasedPreProcessing(INFO);
EEG = preProcessingUnit.getData();

%% Check fieldnames
disp('Running: testOutputFieldnames');
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

for i = 1:size(req_fieldnames)
    assert(isfield(EEG,req_fieldnames(i)));
end

%% Check size
disp('Running: tesSize');
assert(size(EEG.data,2) > 1)

%% Check epoching
disp('Running: testEpoching');
preProcessingUnit.epoch(preProcessingUnit);
EEG = preProcessingUnit.getData();
assert(size(EEG.data,3) > 1)