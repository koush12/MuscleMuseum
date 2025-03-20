classdef (Abstract) PhaseLock < Hardware
    %PHASELOCK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Frequency double {mustBePositive}
        Status logical
    end
    
    methods
        function obj = PhaseLock(resourceName,name)
            %PHASELOCK Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                resourceName string
                name string = string.empty
            end
            obj@Hardware(resourceName,name)
        end
    end

    methods (Abstract)
        connect(obj)
        close(obj)
        check(obj)
        lock(obj)
        unlock(obj)
    end
end

