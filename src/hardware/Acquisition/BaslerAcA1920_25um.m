classdef BaslerAcA1920_25um < Basler
    methods
        function obj = BaslerAcA1920_25um(acqName)
            arguments
                acqName string
            end
            obj@Basler(acqName);
            obj.CameraModel = "AcA1920_25um";
            obj.PixelSize = 2.2e-06;
            obj.ImageSize = [1080,1920];
            obj.BitsPerSample = 8;
        end
    end
end

