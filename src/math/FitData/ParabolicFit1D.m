classdef ParabolicFit1D < FitData1D
    %GAUSSIANFIT1D Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = ParabolicFit1D(rawData)
            %GAUSSIANFIT1D Construct an instance of this class
            %   Detailed explanation goes here
            obj@FitData1D(rawData)
        end

        function setFormula(obj)
            obj.Func = fittype('poly2');
        end

        function guessCoefficient(obj)
            
        end
    end
end

