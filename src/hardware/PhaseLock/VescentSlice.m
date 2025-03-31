classdef VescentSlice < VescentPhaseLock
    %VESCENTSLICE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = VescentSlice(resourceName,name)
            arguments
                resourceName string
                name string = string.empty
            end
            obj@VescentPhaseLock(resourceName,name);
            obj.Model = "Slice";
            obj.FrequencyLimit = [10,9500] * 1e6;
        end
    end
end

