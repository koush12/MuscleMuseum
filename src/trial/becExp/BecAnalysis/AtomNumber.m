classdef AtomNumber < BecAnalysis
    %OD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = protected)
       Raw
       Thermal
       Condensate
    end

    properties (Dependent)
        Total
    end

    properties (Constant)
        Unit = 10^6;
    end

    properties (SetObservable)
        YLim double = [0,30];
        IsShowRaw logical = true;
        IsShowThermal logical = true;
        IsShowCondensate logical = true;
        IsShowTotal logical = true;
    end

    properties 
        IsShowNormalized logical = true;
        FitMethod string = "None"
        FitDataRaw
        FitDataThermal
        FitDataCondensate
    end

    properties (Hidden,Transient)
        RawLine matlab.graphics.chart.primitive.ErrorBar
        ThermalLine matlab.graphics.chart.primitive.ErrorBar
        CondensateLine matlab.graphics.chart.primitive.ErrorBar
        TotalLine matlab.graphics.chart.primitive.ErrorBar
    end
    
    methods
        function obj = AtomNumber(becExp)
            %OD Construct an instance of this class
            %   Detailed explanation goes here
            obj@BecAnalysis(becExp)
            obj.Chart(1) = Chart(...
                name = "Atom number",...
                num = 29, ...
                fpath = fullfile(becExp.DataAnalysisPath,"AtomNumber"),...
                loc = [0.6936,0.6014],...
                size = [0.3069,0.3995]...
                );
        end
        
        function initialize(obj)
            becExp = obj.BecExp;
            fig = obj.Chart(1).initialize;
            nSub = becExp.Roi.NSub;
            nSub(nSub == 0) = 1;

            %% Initialize data
            obj.Raw = zeros(1,1,nSub);
            obj.Thermal = zeros(1,1,nSub);
            obj.Condensate = zeros(1,1,nSub);

            %% Initialize figures
            if ~ishandle(fig)
                return
            end

            % Listener for plotting y limit and toggling lines
            addlistener(obj,'YLim','PostSet',@obj.handlePropEvents);
            addlistener(obj,'IsShowRaw','PostSet',@obj.handlePropEvents);
            addlistener(obj,'IsShowThermal','PostSet',@obj.handlePropEvents);
            addlistener(obj,'IsShowCondensate','PostSet',@obj.handlePropEvents);
            addlistener(obj,'IsShowTotal','PostSet',@obj.handlePropEvents);

            % Initialize axis
            ax = gca;
            co = ax.ColorOrder;
            conum=size(co, 1);
            mOrder = markerOrder();

            obj.RawLine = matlab.graphics.chart.primitive.ErrorBar.empty;
            obj.ThermalLine = matlab.graphics.chart.primitive.ErrorBar.empty;
            obj.CondensateLine = matlab.graphics.chart.primitive.ErrorBar.empty;
            obj.TotalLine = matlab.graphics.chart.primitive.ErrorBar.empty;

            hold(ax,'on')
            % Initialize raw plots
            for ii = 1:nSub
                obj.RawLine(ii) = errorbar(ax,1,1,[]);
                obj.RawLine(ii).Marker = mOrder(ii);
                obj.RawLine(ii).MarkerFaceColor = co(ii,:);
                obj.RawLine(ii).MarkerEdgeColor = co(ii,:)*.5;
                obj.RawLine(ii).MarkerSize = 8;
                obj.RawLine(ii).LineWidth = 2;
                obj.RawLine(ii).Color = co(ii,:);
                obj.RawLine(ii).CapSize = 0;
            end
            legendStrRaw = arrayfun(@(x) "Raw " + x,1:nSub);
            
            % Initialize thermal and condensate plots
            if ismember("DensityFit",becExp.AnalysisMethod)
                switch becExp.DensityFit.FitMethod
                    case {"GaussianFit1D","BosonicGaussianFit1D"}
                        for ii = 1:nSub
                            obj.ThermalLine(ii) = errorbar(ax,1,1,[]);
                            obj.ThermalLine(ii).Marker = mOrder(ii);
                            obj.ThermalLine(ii).MarkerFaceColor = co(mod(ii + nSub-1,conum)+1,:);
                            obj.ThermalLine(ii).MarkerEdgeColor = co(mod(ii + nSub-1,conum)+1,:)*.5;
                            obj.ThermalLine(ii).MarkerSize = 8;
                            obj.ThermalLine(ii).LineWidth = 2;
                            obj.ThermalLine(ii).Color = co(ii + nSub,:); 
                            obj.ThermalLine(ii).CapSize = 0;
                        end
                        if isempty(becExp.Roi.SubRoi)
                            legendStr = ["Raw","Thermal"];
                        else
                            legendStrThermal = arrayfun(@(x) "Thermal " + x,1:nSub);
                            legendStr = [legendStrRaw,legendStrThermal];
                        end
                        lg = legend(ax,legendStr(:));
                end
            else
                if isempty(becExp.Roi.SubRoi)
                    lg = legend(ax,"Raw");
                else
                    lg = legend(ax,legendStrRaw);
                end
            end
            hold(ax,'off')

            % Change axis properties
            ax.Box = "on";
            ax.XGrid = "on";
            ax.YGrid = "on";
            ax.XLabel.String = obj.BecExp.XLabel;
            ax.XLabel.Interpreter = "latex";
            ax.YLim = obj.YLim;
            if nSub > 1 && obj.IsShowNormalized
                ax.YLabel.String = "${N}_{\mathrm{atom, subroi}}/{N}_{\mathrm{atom, total}}$";
                ax.YLim = [0,1];
            else
                ax.YLabel.String = "${N}_{\mathrm{atom}}~[\times 10^{" + string(log(obj.Unit)/log(10)) + "}]$";
            end
            ax.YLabel.Interpreter = "latex";
            ax.FontSize = 12;
            
            if numel(lg.String) >= 8
                lg.NumColumns = 2;
                lg.FontSize = 8;
                lg.Location = "best";
            end

            % Change visibilities of lines
            if ~isempty(obj.RawLine)
                if obj.IsShowRaw
                    [obj.RawLine.Visible] = deal("on");
                else
                    [obj.RawLine.Visible] = deal("off");
                end
            end
            if ~isempty(obj.ThermalLine)
                if obj.IsShowThermal
                    [obj.ThermalLine.Visible] = deal("on");
                else
                    [obj.ThermalLine.Visible] = deal("off");
                end
            end
            if ~isempty(obj.CondensateLine)
                if obj.IsShowCondensate
                    [obj.CondensateLine.Visible] = deal("on");
                else
                    [obj.CondensateLine.Visible] = deal("off");
                end
            end
            if ~isempty(obj.TotalLine)
                if obj.IsShowTotal
                    [obj.TotalLine.Visible] = deal("on");
                else
                    [obj.TotalLine.Visible] = deal("off");
                end
            end

            % Turn on/off line connections
            if becExp.AveragingMethod == "None"
                if ~isempty(obj.RawLine)
                    [obj.RawLine.LineStyle] = deal("none");
                end
                if ~isempty(obj.ThermalLine)
                    [obj.ThermalLine.LineStyle] = deal("none");
                end
                if ~isempty(obj.CondensateLine)
                    [obj.CondensateLine.LineStyle] = deal("none");
                end
                if ~isempty(obj.TotalLine)
                    [obj.TotalLine.LineStyle] = deal("none");
                end
            end

        end

        function updateData(obj,runIdx)
            becExp = obj.BecExp;
            nSub = becExp.Roi.NSub;
            nSub(nSub == 0) = 1;
            px = becExp.Acquisition.PixelSizeReal;

            %% Update Raw data
            if isempty(becExp.Roi.SubRoi)
                obj.Raw(runIdx) = sum(becExp.Ad.AdData(:,:,runIdx),"all") * px^2;
            else
                subData = becExp.Roi.selectSub(becExp.Ad.AdData(:,:,runIdx));
                for ii = 1:nSub
                    obj.Raw(1,runIdx,ii) = sum(subData{ii},"all") * px^2;
                end
            end

            %% Update thermal and condensate data
            if ismember("DensityFit",obj.BecExp.AnalysisMethod)
                for ii = 1:nSub
                    switch obj.BecExp.DensityFit.FitMethod
                        case "GaussianFit1D"
                            obj.Thermal(1,runIdx,ii) = 2 * pi * prod(becExp.DensityFit.ThermalCloudSize(:,runIdx,ii)) * ...
                                becExp.DensityFit.ThermalCloudCentralDensity(1,runIdx,ii);
                        case "BosonicGaussianFit1D"
                            obj.Thermal(1,runIdx,ii) = pi * prod(becExp.DensityFit.ThermalCloudSize(:,runIdx,ii)) * ...
                                becExp.DensityFit.ThermalCloudCentralDensity(1,runIdx,ii) * ...
                                boseFunction(1,3) / boseFunction(1,2);
                    end
                end
            end
        end

        function updateFigure(obj,~)
            if ishandle(obj.Chart(1).Figure)
                fig = figure(obj.Chart(1).Figure);
            else
                return
            end

            %% Parameters. Use sorted list for plotting
            becExp = obj.BecExp;
            nSub = becExp.Roi.NSub;
            nSub(nSub == 0) = 1;
            paraList = becExp.ScannedParameterList;

            %% Update raw plots
            rawTotal = sum(obj.Raw,3);
            for ii = 1:nSub
                if nSub > 1 && obj.IsShowNormalized
                    [xRaw,yRaw,stdRaw] = computeStd(paraList,obj.Raw(1,:,ii) ./ rawTotal, becExp.AveragingMethod);
                else
                    [xRaw,yRaw,stdRaw] = computeStd(paraList,obj.Raw(1,:,ii) / obj.Unit, becExp.AveragingMethod);
                end
                obj.RawLine(ii).XData = xRaw;
                obj.RawLine(ii).YData = yRaw;
                obj.RawLine(ii).YNegativeDelta = stdRaw;
                obj.RawLine(ii).YPositiveDelta = stdRaw;
            end

            %% Update thermal and condensate plots
            if ismember("DensityFit",becExp.AnalysisMethod)
                switch becExp.DensityFit.FitMethod
                    case {"GaussianFit1D","BosonicGaussianFit1D"}
                        thermalTotal = sum(obj.Thermal,3);
                        for ii = 1:nSub
                            if nSub > 1 && obj.IsShowNormalized
                                [xThermal,yThermal,stdThermal] = computeStd(paraList,obj.Thermal(1,:,ii) ./ thermalTotal, becExp.AveragingMethod);
                            else
                                [xThermal,yThermal,stdThermal] = computeStd(paraList,obj.Thermal(1,:,ii) / obj.Unit, becExp.AveragingMethod);
                            end
                            obj.ThermalLine(ii).XData = xThermal;
                            obj.ThermalLine(ii).YData = yThermal;
                            obj.ThermalLine(ii).YNegativeDelta = stdThermal;
                            obj.ThermalLine(ii).YPositiveDelta = stdThermal;
                        end
                end
            end
            
            %% Update lengend position
            lg = findobj(fig,"Type","Legend");
            lg.Location = "best";

            %% Update Line connection
            l = findobj(fig,"Type","Line");
            le = findobj(fig,"Type","ErrorBar");
            if becExp.AveragingMethod == "None"
                if ~isempty(l)
                    [l.LineStyle] = deal("none");
                end
                if ~isempty(le)
                    [le.LineStyle] = deal("none");
                end
            else
                if ~isempty(l)
                    [l.LineStyle] = deal("-");
                end
                if ~isempty(le)
                    [le.LineStyle] = deal("-");
                end
            end
        end
        
        function val = get.Total(obj)
            val = obj.Thermal + obj.Condensate;
        end
    end

    methods (Static)
        function handlePropEvents(src,evnt)
            obj = evnt.AffectedObject;
            if isempty(obj.Chart(1).Figure) || ~ishandle(obj.Chart(1).Figure)
                return
            end
            switch src.Name
                case 'YLim'
                    fig = obj.Chart(1).Figure;
                    ax = fig.CurrentAxes;
                    ax.YLim = obj.YLim;
                case 'IsShowRaw'
                    if ~isempty(obj.RawLine)
                        if obj.IsShowRaw
                            [obj.RawLine.Visible] = deal("on");
                        else
                            [obj.RawLine.Visible] = deal("off");
                        end
                    end
                case 'IsShowThermal'
                    if ~isempty(obj.ThermalLine)
                        if obj.IsShowThermal
                            [obj.ThermalLine.Visible] = deal("on");
                        else
                            [obj.ThermalLine.Visible] = deal("off");
                        end
                    end
                case 'IsShowCondensate'
                    if ~isempty(obj.CondensateLine)
                        if obj.IsShowCondensate
                            [obj.CondensateLine.Visible] = deal("on");
                        else
                            [obj.CondensateLine.Visible] = deal("off");
                        end
                    end
                case 'IsShowTotal'
                    if ~isempty(obj.TotalLine)
                        if obj.IsShowTotal
                            [obj.TotalLine.Visible] = deal("on");
                        else
                            [obj.TotalLine.Visible] = deal("off");
                        end
                    end
            end
        end
    end
end

