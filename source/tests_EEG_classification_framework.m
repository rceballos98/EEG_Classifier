classdef tests_EEG_classification_framework < matlab.unittest.TestCase
    methods (Test)
        %%
        function testOutputFieldnames(testcase)
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
            % Load EEG data
            load('INFO');
            preProcessingUnit = frequencyBasedPreProcessing(INFO);
            EEG = preProcessingUnit.getData();
            
            % Check fieldnames
            for i = 1:size(req_fieldnames)
                assert(isfield(EEG,req_fieldnames(i)));
            end
        end
        %%
        function testNotEmptyData(testcase)
            disp('Running: testNotEmptyData');
            load('INFO');
            preProcessingUnit = frequencyBasedPreProcessing(INFO);
            EEG = preProcessingUnit.getData();
            assert(size(EEG.data,2) > 1)
        end
        %%
        function testEpoching(testcase)
            disp('Running: testEpoching');
            load('INFO');
            preProcessingUnit = frequencyBasedPreProcessing(INFO);
            preProcessingUnit.epoch();
            EEG = preProcessingUnit.getData();
            assert(size(EEG.data,3) > 1)
        end
    end
end