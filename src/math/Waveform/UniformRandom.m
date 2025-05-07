classdef UniformRandom < RandomWaveform
    %GAUSSIANRANDOM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        LowerBound double = 0 %mu
        UpperBound double = 1 %sigma
    end
    
    methods
        function obj = UniformRandom(options)
            arguments
                options.samplingRate double = [];
                options.startTime double = 0;
                options.duration double = [];
                options.lowerBound double = [];
                options.upperBound double = 0;
            end
            field = string(fieldnames(options));
            for ii = 1:numel(field)
                if ~isempty(options.(field(ii)))
                    obj.(capitalizeFirst(field(ii))) = options.(field(ii));
                end
            end
        end
        
        function func = TimeFunc(obj)
            lb = obj.LowerBound;
            ub = obj.UpperBound;
            td = obj.Duration;
            t0 = obj.StartTime;
            func = @tFunc;
            function waveOut = tFunc(t)
                waveOut = (t>=t0 & t<=(t0+td)) .* ...
                    (rand(1,numel(t)).*(ub-lb) + lb);
            end
        end
    end
end

