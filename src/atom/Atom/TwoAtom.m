classdef TwoAtom
    %TWOATOM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = protected)
        Atom1
        Atom2
    end
    
    methods
        function obj = TwoAtom(atomName1,atomName2)
            %TWOATOM Construct an instance of this class
            %   Detailed explanation goes here
            obj.Atom1 = getAtom(atomName1);
            obj.Atom2 = getAtom(atomName2);
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Atom1 + inputArg;
        end
    end
end

