%% Make INFO script
INFO = struct();

%% directorynames
INFO.dir_names.info = '../INFO';
INFO.dir_names.pre_process.pre_pend = 'EmotionRecognition_';
INFO.dir_names.responses.post_pend = '-full_eeg2.log';
INFO.dir_names.pre_process.saved = '../Processed/EEG';
INFO.dir_names.responses.saved = '../Processed/Responses';
INFO.dir_names.rawData = '../RawData';

%% Pre-Process
INFO.min_freq = 0.5;
INFO.max_freq = 70;
INFO.notch_freq = 50;
INFO.notch_amp = 0.2;
INFO.resample_freq = 256;
INFO.epochs = 60;

%% Features
INFO.fs = 256;
INFO.bands.freq = [
    [1 3]
    [4 7]
    [8 13]
    [14 30]
    [31 50]
    ];
INFO.bands.names = {'delta' 'theta' 'alpha' 'beta' 'gamma'} ;
INFO.bands.n = 5;

%% Get files from dir
if(INFO.dir_names.info)
    dir_name = INFO.dir_names.info;
    files = dir('../INFO');
    for i = 1:size(files,1);
        filename = files(i).name;
        [pathstr,name,ext] = fileparts(filename);
        if(strcmp(ext, '.mat') && ~strcmp(name,'lastINFO'))
            warning('Found INFO/%s, loading...',name);
            temp = load(fullfile(dir_name,filename));
            myFieldnames = fieldnames(temp);
            for n = 1:size(myFieldnames,1);
                INFO.(myFieldnames{n}) = temp.(myFieldnames{n});
            end
        end
    end
end

%% Save
if(INFO.dir_names.info)
    lastINFO = INFO;
    save(fullfile(INFO.dir_names.info,'lastINFO.mat'),'lastINFO');
end
%%
save(fullfile(INFO.dir_names.info,'pairs.mat'),'pairs');