                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        % inherets from handle to work with reference
classdef (Abstract) featureExtractionUnit < handle
    properties
        selected_features;
        selected_names;
        selected_i;
        names;
        features;
        labels;
        INFO;
    end
    
    methods
        function obj = featureExtractionUnit(INFO)
            obj.INFO = INFO;
        end
    end
    
    methods(Abstract)       
      load(obj)
      extract(obj)
    end
    
end