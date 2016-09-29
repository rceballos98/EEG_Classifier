for i = size(ALLCOM,2):-1:1
    disp(char(ALLCOM(i)));
end
%% load struct
load('ourData')

%% subject_ID
subID = '0001_test';
%%
%[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
setname = 'test_0001.set';
EEG = pop_loadset('filename','test_0001.set','filepath','Z:\\CRB\\experimentEEG\\RawEEGData\\');
EEG = eeg_checkset( EEG );
EEG = pop_resample( EEG, 256);
EEG = pop_eegfiltnew(EEG, 0.5, 70, 1690, 0, [], 0);
EEG = pop_eegfiltnew(EEG, 49.8, 50.2, 4224, 1, [], 0);
EEG = pop_epoch( EEG, {  'S  1'  'S  2'  'S  3'  'S  4'  'S  5'  'S  6'  'S  7'  'S  8'  'S  9'  'S 10'  'S 11'  'S 12'  'S 13'  'S 14'  'S 15'  'S 16'  'S 17'  'S 18'  'S 19'  'S 20'  'S 21'  'S 22'  'S 23'  'S 24'  'S 25'  'S 26'  'S 27'  'S 28'  'S 29'  'S 30'  'S 31'  'S 32'  'S 33'  'S 34'  'S 35'  'S 36'  'S 37'  'S 38'  'S 39'  'S 40'  'S 41'  'S 42'  'S 43'  'S 44'  'S 45'  'S 46'  'S 47'  'S 48'  'S 49'  'S 50'  'S 51'  'S 52'  'S 53'  'S 54'  'S 55'  'S 56'  'S 57'  'S 58'  'S 59'  'S 60'  }, ...
    [-5  31], 'newname', strcat(setname,'_epochs'), 'epochinfo', 'yes');
EEG = pop_rmbase( EEG, [-5000     0]);

%% Plot freq
figure; 
pop_spectopo(EEG, 1, [0      2978199.2188],...
    'EEG' , 'percent', 80, 'freqrange',[1 100],'electrodes','off');
%%
eeg_0001 = EEG.data;

%%
BANDS = struct();
BANDS.freq = [
    [1 3] 
    [4 7]
    [8 13]
    [14 30]
    [31 50]
    ];

BANDS.names = {'delta' 'theta' 'alpha' 'beta' 'gamma'};
ourData.info.bands = BANDS;

