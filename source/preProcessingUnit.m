% inherets from handle to work with reference
classdef (Abstract) preProcessingUnit < handle
    properties
        EEG;
        INFO;
        status;
    end
    
    methods
        function obj = preProcessingUnit(INFO)
            obj.INFO = INFO;
            obj.status = {'init'};
            obj.load();
        end
    end
    
    methods(Abstract)       
      load(obj)
      getData(obj)
      preProcess(obj)
    end
end