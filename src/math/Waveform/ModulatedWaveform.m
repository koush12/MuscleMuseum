classdef (Abstract) ModulatedWaveform < Waveform
    %MODULATIONWAVEFORM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Amplitude double = 0 % Peak-to-peak amplitude, usually in Volts.
        Offset double = 0 % Offest, usually in Volts.
        Frequency double {mustBePositive} = 100 % In Hz
        Phase double = 0 % In radians
        AmplitudeModulation WaveformList
        FrequencyModulation WaveformList
        PhaseModulation WaveformList
    end
    
    methods
        function obj = ModulatedWaveform()
            %MODULATIONWAVE Construct an instance of this class
            %   Detailed explanation goes here
        end

        function [ampMod,freqMod,phaseMod] = getModulation(obj)
            if ~isempty(obj.AmplitudeModulation)
                obj.AmplitudeModulation.SamplingRate = obj.SamplingRate;
                ampMod = obj.AmplitudeModulation.TimeFunc;
            else
                ampMod = @(t) zeros(size(t));
            end
            if ~isempty(obj.FrequencyModulation)
                obj.FrequencyModulation.SamplingRate = obj.SamplingRate;
                freqMod = obj.FrequencyModulation.TimeFunc;
            else
                freqMod = @(t) zeros(size(t));
            end
            if ~isempty(obj.PhaseModulation)
                obj.PhaseModulation.SamplingRate = obj.SamplingRate;
                phaseMod = obj.PhaseModulation.TimeFunc;
            else
                phaseMod = @(t) zeros(size(t));
            end
        end
    end
end

