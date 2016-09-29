classdef asymmetryFeaturesCopy < featureGenerationUnit
    properties
        psd;
        de;
    end
    methods
        
        % Constructor calls super
        function obj = asymmetryFeaturesCopy(EEG, INFO)
            obj@featureGenerationUnit(EEG, INFO);
            obj.addDE();
        end
        
        %%Takes in a 2D matrix of channels versus raw EEG and computes
        %%the psd over given frequency bands in the INFO datafile
        function [psdPerBand] = getPSD(obj, data)
            %get data dimensions
            [nChannels, N] = size(data);
            %psd = zeros(nChannels,size(obj.INFO.bands.names,2));
            
            %compute raw power sprectral density (psd)
            xdft = fft(data, N, 2);
            xdft = xdft(:,1:N/2+1);
            psd = (1/(obj.INFO.fs*N)) * abs(xdft).^2;
            
            %take away mirrored data and save
            psd(:,2:end-1) = 2*psd(:,2:end-1);
            
            %Get indexes for frequency band cutoffs
            INFO.bands.i = obj.INFO.bands.freq.*(size(psd,2)-1)/(obj.INFO.fs/2);
            
            nBands = size(obj.INFO.bands.freq,1);
            psdPerBand = zeros(nChannels,nBands);
            for band = 1:nBands
                %Get indexes of interest
                name = char(obj.INFO.bands.names(band));
                i1 = obj.INFO.bands.freq(band,1);
                i2 = obj.INFO.bands.freq(band,2);
                %number of points used in calculation
                point_num = abs(i2 - i1);
                
                %compute mid freq for each band (plotting)
                INFO.bands.med(band) = i1 + (i2-i1)/2;
                
                %index PSD matrix for given band
                band_data = psd(:,i1:i2);
                
                %Calculate average power over band for each channel
                psdPerBand(:,band) = sum(band_data,2)./point_num;
            end
            
        end
        
        function addPSD(obj)
            obj.psd = zeros(obj.EEG.nbchan,obj.INFO.bands.n,obj.INFO.epochs);
            for epoch = 1:obj.INFO.epochs
                obj.psd(:,:,epoch) = obj.getPSD(obj.EEG.data(:,:,epoch));
            end
        end
        
        function addDE(obj)
            if(size(obj.psd)>0)
                obj.de = log(obj.psd);
            else
                obj.addPSD()
                obj.de = log(obj.psd);
            end
        end
        
        
        function [features, names]  = doOnPairsByBands(obj, data, operation, pairs, operationName)
            % if string pairs, map to numbers
            if(iscell(pairs))
                pairs = arrayfun(@(x) obj.INFO.channelMap(x{1}),[pairs(:,1),pairs(:,2)]);
            end
            
            nPairs = size(pairs,1);
            [~, nBands] = size(data);
            nFeatures = nPairs*nBands;
            features = zeros(nFeatures,1);
            names = cell(nFeatures,1);
            count = 0;
            for i=1:nPairs
                %disp(assymPairs{i,1})
                for band = 1:nBands
                    count = count + 1;
                    left = pairs(i,1);
                    right = pairs(i,2);
                    features(count,:) = operation(data(left,band), data(right,band));
                    mapChan = @(x) obj.INFO.reverseMap(x);
                    bandMap = @(x) obj.INFO.bands.names{x};
                    names{count} = strcat(mapChan(left),'-',mapChan(right),'-',bandMap(band),'-',operationName);
                end
            end
        end
        
        function [features, sampleNames] = forAllEpochs(obj,func,data,operation,pairs,operationName)
            %get size
            epochs = obj.INFO.epochs;
            [sampleFeature,sampleNames] = func(data(:,:,1), operation,pairs,operationName);
            features = zeros([epochs size(sampleFeature)]);
            
            for epoch = 1:epochs
                [features(epoch,:),~] = func(data(:,:,epoch), operation,pairs,operationName);
            end
            
        end
        
        function processPairs(obj,data, operation, pairs, operationName)
            [features,names] = obj.forAllEpochs(@obj.doOnPairsByBands,data,operation,pairs,operationName);
            obj.addFeaturesAndNames(features,names);
        end
        
        
        function addPSDfeatures(obj)
            if(size(obj.psd) == 0)
                obj.addPSD();
            end
            [nChannels,nBands, epochs] = size(obj.psd);
            names = (strcat(...
                (arrayfun(@(x) obj.INFO.reverseMap(x),repmat([1:nChannels],1,nBands),'UniformOutput',false)),'-',...
                arrayfun(@(x) obj.INFO.bands.names{x},reshape(repmat([1:nBands],1,nChannels),1,[]),'UniformOutput',false)...
                ,'-psd'))';
            
            dims = size(obj.psd);
            features = reshape(permute(obj.psd,[3,2,1]),dims(3),dims(1)*dims(2));
            obj.addFeaturesAndNames(features,names);
        end
        
        function addDEfeatures(obj)
            if(size(obj.de) == 0)
                obj.addDE();
            end
            [nChannels,nBands, epochs] = size(obj.de);
            names = (strcat(...
                (arrayfun(@(x) obj.INFO.reverseMap(x),repmat([1:nChannels],1,nBands),'UniformOutput',false)),'-',...
                arrayfun(@(x) obj.INFO.bands.names{x},reshape(repmat([1:nBands],1,nChannels),1,[]),'UniformOutput',false)...
                ,'-de'))';
            
            dims = size(obj.de);
            features = reshape(permute(obj.de,[3,1,2]),dims(3),dims(1)*dims(2));
            obj.addFeaturesAndNames(features,names);
        end
        
        function addDASMfeatures(obj)
            obj.processPairs(obj.de, @gsubtract, obj.INFO.pairs.lateral, 'sub');
        end
        
        function addDCAUfeatures(obj)
            obj.processPairs(obj.de, @gsubtract, obj.INFO.pairs.caudal, 'sub');
        end
        
        function addRASMfeatures(obj)
            obj.processPairs(obj.de, @gdivide, obj.INFO.pairs.lateral, 'div');
        end
        
        function addALLfeatures(obj)
            N = size(obj.de,1);
            count = 0;
            pairs = zeros(N*(N-1)/2,2);
            for i = 1:N
                for j = i+1:N
                    count = count + 1;
                    pairs(count,:) = [i, j];
                end
            end
            obj.processPairs(obj.de, @gsubtract, pairs, 'sub');
        end
        
        
        function [features,names] = getClassic(obj)     
            obj.addPSDfeatures();
            obj.addDEfeatures();
            obj.addDASMfeatures();
            obj.addDCAUfeatures();
            obj.addRASMfeatures();
            features = obj.features;
            names = obj.names;
        end
        
        function[features,names] = getAll(obj)
            obj.addALLfeatures();
            features = obj.features;
            names = obj.names;
        end
       
        
        function addFeaturesAndNames(obj, newFeatures, newNames)
            if(size(obj.features,1) > 0)
                obj.features = horzcat(obj.features, newFeatures);
            else
                obj.features =  newFeatures;
            end
            
            if(size(obj.names,1) > 0)
                obj.names = cat(1, obj.names, newNames);
            else
                obj.names = newNames;
            end
        end
        
        
        function [features] = getFeatures(obj)
            features = obj.features;
        end
        
    end
end
