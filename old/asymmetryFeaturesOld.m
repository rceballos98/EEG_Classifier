classdef asymmetryFeatures < featureGenerationUnit
    
    methods
        
        % Constructor calls super
        function obj = asymmetryFeatures(EEG, INFO)
            obj@featureGenerationUnit(EEG, INFO);
        end
        
        %%Takes in a 2D matrix of channels versus raw EEG and computes
        %%the psd over given frequency bands in the INFO datafile
        function [powerBands] = getPSD(obj, data)
            %get data dimensions
            [nChannels, N] = size(data);
            powerBands = zeros(nChannels,size(obj.INFO.bands.names,2));
            
            
            %compute raw power sprectral density (psd)
            xdft = fft(data, N, 2);
            xdft = xdft(:,1:N/2+1);
            psdx = (1/(obj.INFO.fs*N)) * abs(xdft).^2;
            
            %take away mirrored data and save
            psdx(:,2:end-1) = 2*psdx(:,2:end-1);
            psd = psdx;
            
            
            %Get indexes for frequency band cutoffs
            INFO.bands.i = obj.INFO.bands.freq.*(size(psd,2)-1)/(obj.INFO.fs/2);
            
            for band = 1:size(obj.INFO.bands.freq,1)
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
                powerBands(:,band) = sum(band_data,2)./point_num;
                
            end
        end
        
        
        
        function [features] = getAllAsymmetryFeatures(obj, psd)
            features = struct();
            de = log(psd);
            N = obj.EEG.nbchan;
            nBands = size(de,2);
            count = 0;
            features.data = zeros(N*(N-1)/2,nBands);
            features.names = cell(N*(N-1)/2,1);
            for i = 1:N
                for j = i+1:N
                    count = count + 1;
                    features.data(count,:) = de(i,:) - de(j,:);
                    features.names{count} = strcat(int2str(i),'-',int2str(j));
                end
            end
            
        end
        
        function [data, names] = getAllAsymmetryFeatures2(obj, psd)
            
            de = log(psd);
            N = obj.EEG.nbchan;
            nBands = size(de,2);
            count = 0;
            data = zeros(1,N*(N-1)*nBands/2);
            names = cell(1,N*(N-1)*nBands/2);
            for i = 1:N
                for j = i+1:N
                    for b = 1:nBands
                        count = count + 1;
                        data(1,count) = de(i,b) - de(j,b);
                        names{1,count} = ...
                            strcat(int2str(i),'-',int2str(j),'-',obj.INFO.bands.names{b});
                    end
                end
            end
            
        end
        
        
        
        function  [data, names] = getClassicAsymmetryFeatures(obj, psd)
            % input is a power spectrum density (PSD) array - one value per channel and
            % per frequency band
            channelMap = containers.Map({obj.EEG.chanlocs.labels} , {1, 2, 3, 4, ...
                5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, ...
                23, 24, 25, 26, 27, 28, 29, 30, 31, 32});
            
            % Hemispheric assymmetry Pairs (between the left and right hemisphere)
            assymPairs ={'Fp1' 'Fp2'; 'F7' 'F8'; 'F3' 'F4'; ...
                'T7' 'T8'; 'P7' 'P8'; 'C3' 'C4'; 'P3' 'P4'; ...
                'O1' 'O2'; 'F7' 'F8'; 'FC5' 'FC6'; 'FC1' 'FC2'; ...
                'CP5' 'CP6'; 'CP1' 'CP2'; 'PO9' 'PO10'; 'TP9' 'TP10'};
            
            
            % Caudality Pairs (in frontal-posterior direction)
            caudPairs = {'FC5' 'CP5'; 'FC1' 'CP1'; 'FC2' 'CP2'; 'FC6' 'CP6'; ...
                'F7' 'P7'; 'F3' 'P3'; 'Fz' 'Pz'; 'F4' 'P4'; 'F8' 'P8'; ...
                'Fp1' 'O1'; 'Fp2' 'O2'};
            
            [nChannels, nBands] = size(psd);
            nAssymPairs = size(assymPairs,1);
            nCaudPairs = size(caudPairs,1);
            
      
            nFeatures = nChannels*2 + nAssymPairs*2 + nCaudPairs;
            data = zeros(1,nFeatures*nBands);
            names = cell(1,nFeatures*nBands);
            
            % 1. power spectral density (PSD)
            count = 1;
            nextCount = count + nChannels*nBands - 1;
            data(1,count:nextCount) = psd(:);
            channelNames = strread(num2str([1:nChannels]),'%s');
            names{1,count:nextCount} = (strcat(channelNames,'-psd'));
            count = nextCount+1;
            % keep track of array index
            
            % 2. differential entropy (DE)
            % in a certain band, DE is equivalent to the logarithmic PSD for a
            % fixed length EEG sequence.
            nextCount = count + nChannels*nBands - 1;
            de = log(psd);
            data(1,count:nextCount) = de(:); % not sure what base we should use here...
            names{count:nextCount} = (strcat(channelNames,'-de'));
            count = nextCount+1;
            
            % 3. differential asymmetry (DASM)
            for i=1:nAssymPairs
                %disp(assymPairs{i,1})
                left = channelMap(assymPairs{i,1});
                right = channelMap(assymPairs{i,2});
                for b = 1:nBands
                    data(1,count) = de(left,b) - de(right,b);
                    names{count} =...
                        strcat(int2str(left),'-',int2str(right),'-','dasm-',obj.INFO.bands.names{b});
                    count = count + 1;
                end
            end
            % 4. rational asymmetry (RASM)
            for i=1:nAssymPairs
                %disp(assymPairs{i,1})
                left = channelMap(assymPairs{i,1});
                right = channelMap(assymPairs{i,2});
                for b = 1:nBands
                    data(1,count) = de(left,b) / de(right,b);
                    names{count} =...
                        strcat(int2str(left),'-',int2str(right),'-','rasm',obj.INFO.bands.names{b});
                    count = count + 1;
                end
                
            end
            
            % 5.differential caudality (DCAU)
            for i=1:nCaudPairs
                %disp(caudPairs{i,1})
                front = channelMap(caudPairs{i,1});
                back = channelMap(caudPairs{i,2});
                for b = 1:nBands
                    data(1,count) = de(front,b) / de(back,b);
                    names{count} =...
                        strcat(int2str(left),'-',int2str(right),'-','dcau',obj.INFO.bands.names{b});
                    count = count + 1;
                end
                count = count + 1;
            end
            
        end
        
        function [features, names] = getFeaturesWith(obj, func)
            for epoch = 1:size(obj.EEG.data,3)
                psd = obj.getPSD(obj.EEG.data(:,:,epoch));
                %features(epoch,:) = obj.getAllAsymmetryFeatures(psd);
                [data, name] = func(psd);
                features(epoch,:) = data;
                names(epoch,:) = name;
            end
        end
        
        function [features] = getFeatures(obj)
            for epoch = 1:size(obj.EEG.data,3)
                psd = obj.getPSD(obj.EEG.data(:,:,epoch));
                %features(epoch,:) = obj.getAllAsymmetryFeatures(psd);
                features(epoch,:) = getClassicAsymmetryFeatures(psd);
            end
        end
        
        function addFeatures(obj, newFeatures)
            for epoch = 1:size(features)
                obj.features(epoch).data = cat(1, obj.features.data, newFeatures.data);
                obj.features(epoch).names = cat(1, obj.features.names, newFeatures.names);
            end
        end
        
        function [features] = getMyFeatures(obj)
            features = obj.features;
        end
        
    end
end