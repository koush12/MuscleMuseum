classdef TwoAtom
    %TWOATOM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = protected)
        Atom1
        Atom2
    end

    properties
        Manifold1
        Manifold2
    end
    
    methods
        function obj = TwoAtom(atomName1,atomName2,manifoldName1,manifoldName2)
            %TWOATOM Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                atomName1 string
                atomName2 string
                manifoldName1 string = string.empty
                manifoldName2 string = string.empty
            end
            obj.Atom1 = getAtom(atomName1);
            obj.Atom2 = getAtom(atomName2);
            if ~isempty(manifoldName1)
                obj.Manifold1 = obj.Atom1.(manifoldName1);
            end
            if ~isempty(manifoldName2)
                obj.Manifold2 = obj.Atom2.(manifoldName2);
            end
        end
        
        function Ha = HamiltonianAtom(obj,fRot,U)
            arguments
                obj TwoAtom
                fRot double = 0
                U double = 1
            end
            Ha1 = obj.Manifold1.HamiltonianAtom(fRot,U);
            eye1 = eye(obj.Manifold1.NNState);
            Ha2 = obj.Manifold2.HamiltonianAtom(fRot,U);
            eye2 = eye(obj.Manifold2.NNState);
            Ha = kron(Ha1,eye2) + kron(eye1,Ha2);
        end
    end
end

