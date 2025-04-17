classdef SineWaveModulated < ModulatedWaveform
    %SINEWAVE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = SineWaveModulated(options)
            %SINEWAVE Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                options.samplingRate double = [];
                options.startTime double = 0;
                options.duration double = [];
                options.amplitude double = [];
                options.offset double = 0;
                options.frequency double = [];
                options.phase double = 0;

                options.amplitudeModuation = []; 
                options.frequencyModulation = [];
                options.phaseModulation = [];
            end
            field = string(fieldnames(options));
            for ii = 1:numel(field)
                if ~isempty(options.(field(ii)))
                    obj.(capitalizeFirst(field(ii))) = options.(field(ii));
                end
            end
        end
        
        function func = TimeFunc(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            amp = obj.Amplitude;
            freq = obj.Frequency;
            td = obj.Duration;
            t0 = obj.StartTime;
            phi = obj.Phase;
            offset = obj.Offset;
            [ampMod,freqMod,phaseMod] = obj.getModulation;

            func = @tFunc;
            function waveOut = tFunc(t)
                waveOut = (t>=t0 & t<=(t0+td)) .* ...
                    ((amp+ampMod(t)) ./2 .* sin(2 * pi .* (freq+freqMod(t)) .* (t-t0) + (phi+phaseMod(t))) + offset);
            end
        end
    end
end

