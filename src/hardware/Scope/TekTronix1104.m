classdef TekTronix1104 < TektronixScope
    %TEKTRONIX1104 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = TekTronix1104(resourceName,name)
            arguments
                resourceName string
                name string = string.empty
            end
            obj@TektronixScope(resourceName,name)
            obj.Model = "1104";
            obj.SamplingRateMax = 1e9;
            obj.NSampleMax = 2.5e3;
            obj.NSample = obj.NSampleMax;
            obj.NChannel = 4;
            obj.IsEnabled = true(1,obj.NChannel);
            obj.VerticalOffset = zeros(1,obj.NChannel);
            obj.VerticalCoupling = repmat("DC",1,obj.NChannel);
            obj.VerticalRange = repmat(10,1,obj.NChannel);
            obj.DisabledProperty = ["NSample","TriggerSource","TriggerLevel","VerticalOffset","VerticalRange"];
        end

        function set(obj)
            obj.check;
            obj.Oscilloscope.AcquisitionTime = obj.Duration;
            obj.Oscilloscope.TriggerMode = lowerFirst(obj.TriggerMode);
            if obj.TriggerSlope == "Rise"
                obj.Oscilloscope.TriggerSlope = "rising";
            else
                obj.Oscilloscope.TriggerSlope = "falling";
            end
            for ii = 1:obj.NChannel
                cName = "CH" + num2str(ii);
                if ~obj.IsEnabled(ii)
                    disableChannel(obj.Oscilloscope,cName)
                else
                    enableChannel(obj.Oscilloscope,cName)
                    configureChannel(obj.Oscilloscope,cName,'VerticalCoupling',obj.VerticalCoupling(ii))
                end
            end
        end
        
    end
end

