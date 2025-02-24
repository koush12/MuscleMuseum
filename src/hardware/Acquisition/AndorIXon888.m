classdef AndorIXon888 < Andor
    methods
        function obj = AndorIXon888(acqName)
            arguments
                acqName string
            end
            obj@Andor(acqName);
            obj.CameraModel = "IXon888";
            obj.PixelSize = 13e-06;
            obj.ImageSize = [1024,1024];
            obj.BitsPerSample = 16;
        end
    end
end

