classdef GaussianRandom < RandomWaveform
    %GAUSSIANRANDOM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Mean double %mu
        StandardDeviation double %sigma
    end
    
    methods
        function obj = GaussianRandom(options)
            arguments
                options.samplingRate double = [];
                options.startTime double = 0;
                options.duration double = [];
                options.mean double = [];
                options.standardDeviation double = 0;
            end
            field = string(fieldnames(options));
            for ii = 1:numel(field)
                if ~isempty(options.(field(ii)))
                    obj.(capitalizeFirst(field(ii))) = options.(field(ii));
                end
            end
        end
        
        function func = TimeFunc(obj)
            mu = obj.Mean;
            sigma = obj.StandardDeviation;
            td = obj.Duration;
            t0 = obj.StartTime;
            func = @tFunc;
            function waveOut = tFunc(t)
                waveOut = (t>=t0 & t<=(t0+td)) .* ...
                    normrnd(mu,sigma,1,numel(t));
            end
        end
    end
end

