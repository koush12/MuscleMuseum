classdef Divalent < Atom
    properties(SetAccess=protected)
        Blue TwoJManifoldDivalent
        CyclerFrequency double
        CyclerSaturationIntensity double
        CyclerCrossSection double
    end

    methods
        function obj = Divalent(atomName)
            obj@Atom(atomName)
            if obj.Type ~= "Divalent"
                error("Wrong input [atomName]. [atomName] must be an divalent atom")
            end
            nG = obj.groundStateN();
            obj.Blue = TwoJManifoldDivalent(obj,nG,0,0,0,nG,1,1,0);
            obj.CyclerFrequency = obj.Blue.Frequency;
            obj.CyclerSaturationIntensity = pi * Constants.SI("hbar") * 2 * pi * Constants.SI("c") / ...
                3 / (Constants.SI("c")/obj.CyclerFrequency)^3 / (1/obj.Blue.NaturalLinewidth/2/pi);
            obj.CyclerCrossSection = ...
                Constants.SI("hbar") * (2*pi*obj.CyclerFrequency) *...
                (obj.Blue.NaturalLinewidth * 2 * pi) / 2 / obj.CyclerSaturationIntensity; 
        end
    end
end

