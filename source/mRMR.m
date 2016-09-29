classdef mRMR < featureExtractionUnit
    
    methods 
        % Constructor calls super
        function obj = mRMR(INFO, features, names, labels)
            obj@featureExtractionUnit(INFO);
            obj.features = features;
            obj.names = names;
            obj.labels = labels;
            
        end
        
        function load(obj,features, labels)
            obj.features = features;
            obj.labels = labels;
        end
           
        function normalize(obj)
            temp = bsxfun(@minus,obj.features,mean(obj.features));
            obj.features = bsxfun(@rdivide,temp,std(obj.features));
        end
        
        function changeResolution(obj, resolution)
            obj.features = round(obj.features.*resolution);
        end
        
        function select(obj, nFeatures)
            obj.selected_i = feast('mrmr',nFeatures,obj.features, obj.labels);
            obj.selected_features = obj.features(:,obj.selected_i);
            obj.selected_names = obj.names(obj.selected_i);
        end
        
        function [selected_features,selected_names] = extract(obj,resolution,nFeatures)
            obj.normalize();
            obj.changeResolution(resolution);
            obj.select(nFeatures);
            selected_features = obj.selected_features;
            selected_names = obj.selected_names;
        end
        
    end
end
