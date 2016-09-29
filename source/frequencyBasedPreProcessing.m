classdef frequencyBasedPreProcessing < preProcessingUnit
    
    methods
        % Constructor calls super
        function obj = frequencyBasedPreProcessing(INFO)
            obj@preProcessingUnit(INFO);
        end
        
        function load(obj)
            dir_names = obj.INFO.dir_names;
            subjectID = obj.INFO.subjectID;
            try
                filepath = fullfile(dir_names.pre_process.saved,...
                    strcat('s',subjectID,'.mat'));
                load(filepath);
                obj.EEG = EEG;
                 warning('PreProcessing:foundPreExisting',...
                    'Found and preloaded from %s',filepath);
                obj.status = [obj.status ; {'loadedPreProcessed'}];
                obj.status = [obj.status ; {'resampled'}];
                obj.status = [obj.status ; {'filtered'}];
                obj.status = [obj.status ; {'epoched'}];
                obj.status = [obj.status ; {'rmBaseline'}];
                %turn off warnings for repeated procedures;
                warning('off','PreProcessing:repeatedProcedure')
            catch
                filepath = fullfile(dir_names.rawData,subjectID);
                filename = strcat(dir_names.pre_process.pre_pend, subjectID,'.vhdr');
                
                disp(strcat('loading data from: ',filepath,'/',filename))
                [obj.EEG, ~] = pop_loadbv(filepath, filename);
                obj.status = [obj.status ; {'loadedRaw'}];
            end
            obj.INFO.filepath = filepath;
        end
        
        function resample(obj)
            if ~isempty(strmatch('resampled', obj.status))
                warning('PreProcessing:repeatedProcedure',...
                    'Data has already been resampled');
            else
                obj.EEG = pop_resample(obj.EEG, obj.INFO.resample_freq);
                obj.status = [obj.status ; {'resampled'}];
            end
        end
        
        function filter(obj)
            % Band pass filter from 0.5 - 70 hz
            if ~isempty(strmatch('filtered', obj.status))
                warning('PreProcessing:repeatedProcedure',...
                    'Data has already been resampled');
            else
                disp(strcat('filtering bandpass [',...
                    int2str(obj.INFO.min_freq),' ', int2str(obj.INFO.max_freq),']'));
                obj.EEG = pop_eegfiltnew(...
                    obj.EEG, obj.INFO.min_freq, obj.INFO.max_freq, 1690, 0, [], 0 ...
                    );
                % Notch filter to remove 50 Hz noise
                disp(strcat('filtering notch at ',int2str(obj.INFO.notch_freq),' Hz'));
                obj.EEG = pop_eegfiltnew(...
                    obj.EEG, obj.INFO.notch_freq - obj.INFO.notch_amp, ...
                    obj.INFO.notch_freq + obj.INFO.notch_amp, 4224, 1, [], 0 ...
                    );
                obj.status = [obj.status ; {'filtered'}];
            end
        end
        
        function epoch(obj)
            if ~isempty(strmatch('epoched', obj.status))
                warning('PreProcessing:repeatedProcedure',...
                    'Data has already been resampled');
            else
                obj.EEG = pop_epoch(obj.EEG, obj.INFO.trigger_names, ...
                    [-5  31], 'newname', strcat(obj.INFO.subjectID,'_epochs'), 'epochINFO', 'yes');
                obj.INFO.epochs = size(obj.EEG.data,3); % records epoch number
                obj.status = [obj.status ; {'epoched'}];
            end
        end
        
        function removeBaseline(obj)
            if ~isempty(strmatch('rmBaseline', obj.status))
                warning('PreProcessing:repeatedProcedure',...
                    'Baseline has already been removed');
            else
                obj.EEG = pop_rmbase( obj.EEG, [-5000     0]);
                obj.status = [obj.status ; {'rmBaseline'}];
            end
        end
        
        function EEG = getData(obj)
            EEG = obj.EEG;
        end
        
        function [EEG, INFO] = preProcess(obj)
            obj.resample();
            obj.filter();
            obj.epoch();
            obj.removeBaseline();
            EEG = obj.getData();
            INFO = obj.INFO;
            if obj.INFO.dir_names.pre_process.saved
                dir_name = obj.INFO.dir_names.pre_process.saved;
                if ~isempty(strmatch('loadedRaw', obj.status))
                    filepath = fullfile(dir_name,strcat('s',obj.INFO.subjectID,'.mat'));
                    warning('PreProcessing:savingData',...
                        'Saving EEG struct to %s',filepath);
                    if ~exist(filepath, 'dir')
                         warning('PreProcessing:savingData',...
                             'Folder: %s was not found, creating folder',...
                             dir_name);
                         mkdir(dir_name);
                    end
                    save(filepath,...
                        'EEG');
                end
            end
            warning('on','PreProcessing:repeatedProcedure')
        end
        
    end
    
end