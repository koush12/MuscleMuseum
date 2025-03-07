classdef (Abstract) WaveformGenerator < Hardware
    %WAVEFORMGENERATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        SamplingRate double
        TriggerSource string {mustBeMember(TriggerSource,{'External','Software','Immediate'})} = "External"
        TriggerSlope string {mustBeMember(TriggerSlope,{'Rise','Fall'})} = "Rise"
        OutputMode string {mustBeMember(OutputMode,{'Gated','Normal'})} = "Normal"
        IsOutput logical
        OutputLoad string {mustBeMember(OutputLoad,{'50','Infinity'})} = "50"
        WaveformList cell
        OutputLimit (1,2) double % [lower,upper], At 50 Ohm
    end
    
    methods
        function obj = WaveformGenerator(resourceName,name)
            arguments
                resourceName string
                name string = string.empty
            end
            obj@Hardware(resourceName,name)
        end
        
    end

    methods (Abstract)
        connect(obj)
        set(obj)
        upload(obj)
        close(obj)
        status = check(obj)
    end
end

