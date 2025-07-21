classdef (Abstract) FitData < handle
    %FIT Summary of this class goes here
    %   Detailed explanation goes here

    properties
        RawData double
        IsOverride logical = false
        StartPointOverride (1,:) double % Fit coefficient start point. Check the documentso of [fitoptions]
        LowerOverride (1,:) double % Fit coefficient lower bound.
        UpperOverride (1,:) double % Fit coefficient upper bound.
        TolFun (1,1) double = 1E-16
        MaxFunEvals (1,1) double = 2000
        MaxIter (1,1) double = 2000
    end

    properties (Dependent,Hidden,Transient)
        Option % MATLAB fitoptions object
    end

    properties (SetAccess = protected)
        StartPoint (1,:) double % Fit coefficient start point. Check the documentso of [fitoptions]
        Lower (1,:) double % Fit coefficient lower bound.
        Upper (1,:) double % Fit coefficient upper bound.
        Func % MATLAB fittype object
        Result % MATLAB fitobject
        Gof % Goodness of fit
        Coefficient double % Coefficient resulted from fit
    end

    properties (Dependent)
        CoefficientName string
        FitFormula string
        MinimumDataSize double
    end

    methods
        function obj = FitData(rawData)
            obj.setFormula
            obj.RawData = rawData;
        end

        function option = get.Option(obj)
            coffSize = size(obj.CoefficientName);
            if ~isempty(obj.Func)
                option = fitoptions(obj.Func);
                if isa(option,'curvefit.llsqoptions')
                    return
                end

                if obj.IsOverride && ~isempty(obj.StartPointOverride)...
                        && all(size(obj.StartPointOverride) == coffSize)
                    option.StartPoint = obj.StartPointOverride;
                elseif ~isempty(obj.StartPoint)
                    option.StartPoint = obj.StartPoint;
                end

                if obj.IsOverride && ~isempty(obj.LowerOverride)...
                        && all(size(obj.LowerOverride) == coffSize)
                    option.Lower = obj.LowerOverride;
                elseif ~isempty(obj.Lower)
                    option.Lower = obj.Lower;
                end

                if obj.IsOverride && ~isempty(obj.UpperOverride)...
                        && all(size(obj.UpperOverride) == coffSize)
                    option.Upper = obj.UpperOverride;
                elseif ~isempty(obj.Upper)
                    option.Upper = obj.Upper;
                end

                if option.Method ~= "LinearLeastSquares"
                    option.TolFun = obj.TolFun;
                    option.MaxFunEvals = obj.MaxFunEvals;
                    option.MaxIter = obj.MaxIter;
                end

                % validate options
                if any(option.Upper < option.Lower)
                    idx = option.Upper < option.Lower;
                    temp = option.Upper(idx);
                    option.Upper(idx) = option.Lower(idx);
                    option.Lower(idx) = temp;
                end
                if any((option.StartPoint < option.Lower) | (option.StartPoint > option.Upper))
                    idx = (option.StartPoint < option.Lower) | (option.StartPoint > option.Upper);
                    option.StartPoint(idx) = (option.Lower(idx) + option.Upper(idx)) / 2;
                end
            end
        end

        function cName = get.CoefficientName(obj)
            if isempty(obj.Func)
                cName = string.empty;
            else
                cName = string(coeffnames(obj.Func)).';
            end
        end

        function minSize = get.MinimumDataSize(obj)
            cName = obj.CoefficientName;
            if isempty(cName)
                minSize = 1;
            else
                minSize = numel(cName);
            end
        end

        function formulaString = get.FitFormula(obj)
            if isempty(obj.Func)
                formulaString = string.empty;
            else
                formulaString = string(formula(obj.Func));
            end
        end
    
        function set.RawData(obj,val)
            obj.RawData = obj.checkData(val);
            obj.guessCoefficient;
        end
        
        function setDefaultOverride(obj)
            obj.guessCoefficient
            nameList = ["StartPoint","Lower","Upper"];
            for ii = 1:numel(nameList)
                if isempty(obj.(nameList(ii)+"Override"))
                    obj.(nameList(ii)+"Override") = obj.(nameList(ii));
                end
            end
        end

        function clearOverride(obj)
            nameList = ["StartPoint","Lower","Upper"];
            for ii = 1:numel(nameList)
                obj.(nameList(ii)+"Override") = [];
            end
        end
    end

    methods (Abstract)
        setFormula(obj)
        output = checkData(obj,RawData)
        guessCoefficient(obj)
        obj = do(obj)
        plot(obj)
    end
end

