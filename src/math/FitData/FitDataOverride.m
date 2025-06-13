classdef (Abstract) FitDataOverride < FitData
    %FITDATAOVERRIDE abstract class used to classify objects which have
    %overridable startpoints and retrievable parameters
    %   Ensures that classes that have been validly written to have
    %   overrides can output a list of parameters to check and set a new
    %   startpoint from the Gui
    %   Parameters include:
    %       - StartPoint (inherited from FitData)
    %       - ParamList - cell array of strings that contain the names of
    %       each parameter being fitted to in startpoint.
    %   Methods include:
    %       - Override - replaces startpoint with inputed values.

    properties 
        ParamList cell 
    end

    methods

        function obj = FitData1D(rawData)
            %FIT1D Construct an instance of this class
            %   Detailed explanation goes here
            obj.RawData = rawData;
            obj.ParamList={};
        end

        function override(obj, Params)
            if length(Params)==length(obj.ParamList)
                obj.StartPoint=Params;
            end
        end

        




    end



end