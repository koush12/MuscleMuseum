classdef (Abstract) PhaseLock < Hardware
    %PHASELOCK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Frequency double {mustBePositive} % in Hz
        VariableName string
    end

    properties (SetAccess = protected)
        FrequencyLimit (1,2) double % in Hz [lower,upper]
        CurrentFrequency double % in Hz
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
            obj@Hardware(resourceName,name,false)
        end

        function set.Frequency(obj,val)
            if isempty(obj.FrequencyLimit)
                obj.Frequency = val;
            elseif val<obj.FrequencyLimit(1) || val>obj.FrequencyLimit(2)
                error("Frequency is out of the range [" + num2str(obj.Frequency(1)*1e-6)  + " MHz, " + ...
                    num2str(obj.Frequency(2)*1e-6)  + " MHz]")
            else
                obj.Frequency = val;
            end
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

