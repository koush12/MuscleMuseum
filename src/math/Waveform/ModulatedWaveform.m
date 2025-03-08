classdef (Abstract) ModulatedWaveform < Waveform
    %MODULATIONWAVEFORM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Amplitude double = 0 % Peak-to-peak amplitude, usually in Volts.
        Offset double = 0 % Offest, usually in Volts.
        Frequency double {mustBePositive} % In Hz
        Phase double % In radians
        AmplitudeModuation WaveformList
        FrequencyModulation WaveformList
        PhaseModulation WaveformList
    end
    
    methods
        function obj = ModulatedWaveform()
            %MODULATIONWAVE Construct an instance of this class
            %   Detailed explanation goes here
        end
    end
end

