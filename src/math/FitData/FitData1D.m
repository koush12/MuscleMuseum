classdef (Abstract) FitData1D < FitData
    %FIT1D Summary of this class goes here
    %   Detailed explanation goes here

    properties (Dependent)
        FitPlotData (:,2) double % n * 2 array
        DataSize (1,1) double
    end
    
    methods
        function obj = FitData1D(rawData)
            %FIT1D Construct an instance of this class
            %   Detailed explanation goes here
            obj@FitData(rawData)
        end

        function output = checkData(obj,rawData)
            if isempty(rawData)
                output = [];
            elseif ~ismatrix(rawData)
                error("Fit raw data must be a n * 2 matrix.")
            elseif size(rawData,2) ~= 2
                error("Fit raw data must be a n * 2 matrix.")
            else
                output = rawData;
            end
        end

        function fpData = get.FitPlotData(obj)
            if isempty(obj.Result)
                fpData = [];
                return
            end
            xFit = linspace(min(obj.RawData(:,1)),max(obj.RawData(:,1)),1000).';
            yFit = obj.evaluateFit(xFit);
            fpData = [xFit,yFit];
        end

        function dataSize = get.DataSize(obj)
            dataSize = size(obj.RawData,1);
        end

        function obj = do(obj)
            [fitResult,gof] = fit(obj.RawData(:,1),obj.RawData(:,2),obj.Func,obj.Option);
            obj.Result = fitResult;
            obj.Gof = gof;
            obj.Coefficient = coeffvalues(fitResult);
        end

        function y = evaluateFit(obj,x)
            if isempty(obj.Result)
                y = [];
            else
                y = feval(obj.Result,x);
            end
        end
        
        function plot(obj,targetAxes,isRender)
            arguments
                obj FitData1D
                targetAxes = []
                isRender logical = true
            end

            if isempty(targetAxes)
                figure
                ax = gca;
            else
                ax = targetAxes;
            end
            x = obj.RawData(:,1);
            [x,idx] = sort(x);
            y = obj.RawData(:,2);
            y = y(idx);
            l = plot(ax,x,y,obj.FitPlotData(:,1),obj.FitPlotData(:,2));
            l(1).LineWidth = 1.5;
            l(2).LineWidth = 1.5;
            legend(ax,"Raw Data","Fit Data")

            if isRender
                box on
                xlabel("$x$",'Interpreter','latex')
                ylabel("$y$",'Interpreter','latex')
            end
        end
        
    end
end

