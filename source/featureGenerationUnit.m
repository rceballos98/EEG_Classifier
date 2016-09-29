% inherets from handle to work with reference
classdef (Abstract) featureGenerationUnit < handle
    properties
        EEG;
        features;
        names;
        INFO;
        status;
    end
    
    methods
        function obj = featureGenerationUnit(EEG, INFO)
            obj.EEG = EEG;
            obj.INFO = INFO;
        end
        function loadData(EEG)
            obj.EEG = EGG;
        end
        function loadInfo(INFO)
            obj.INFO = INFO;
        end
    end
    
    methods(Abstract)
        getFeatures(obj)
    end
end