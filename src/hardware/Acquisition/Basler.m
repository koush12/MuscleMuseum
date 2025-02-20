classdef Basler < Acquisition
    methods
        function obj = Basler(acqName)
            %KEYSIGHT Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                acqName string
            end
            obj@Acquisition(acqName);
            obj.CameraType = "Basler";
            obj.AdaptorName = "gentl";
        end

        function setCameraParameterAbsorption(obj)
            %Set camera parameters using the predefined configuration
            %functions.
            if isempty(obj.VideoInput)
                error('Camera not connected. Try the "connectCamera" method first.')
            end
            vid = obj.VideoInput;
            vid.FramesPerTrigger = 1; %Set frames per trigger
            vid.FramesAcquiredFcnCount = 3;
            vid.LoggingMode = 'memory'; %Set logging to memory
            src = getselectedsource(vid); %Create adaptor source
            src.ShutterMode = 'GlobalResetRelease';
            obj.IsExternalTriggered = true;
            obj.ImageGroupSize = 3;

            triggerconfig(vid, 'hardware', 'DeviceSpecific', 'DeviceSpecific'); %Configure trigger type and mode
            vid.TriggerRepeat = inf;
            src.TriggerSelector = 'FrameStart';
            src.TriggerSource = 'Line1';
            src.TriggerActivation = 'RisingEdge';
            src.TriggerMode = 'on';
            src.ExposureMode = 'Timed';
            src.ExposureTime = obj.ExposureTime * 1e6;
        end
    end
end

