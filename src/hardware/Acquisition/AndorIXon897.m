classdef AndorIXon897 < Andor
    methods
        function obj = AndorIXon897(acqName)
            arguments
                acqName string
            end
            obj@Andor(acqName);
            obj.CameraModel = "IXon897";
            obj.PixelSize = 16e-06;
            obj.ImageSize = [512,512];
            obj.BitsPerSample = 32;
        end
    end
end

