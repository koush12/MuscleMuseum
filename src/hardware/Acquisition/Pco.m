classdef Pco < Acquisition
    methods
        function obj = Pco(acqName)
            %KEYSIGHT Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                acqName string
            end
            obj@Acquisition(acqName);
            obj.CameraType = "Pco";
            obj.AdaptorName = "pcocameraadaptor_r2023a";
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
            src.TMTimestampMode = 'Binary'; %Set timestamp mode
            obj.IsExternalTriggered = true;
            obj.ImageGroupSize = 3;

            triggerconfig(vid, 'hardware', '', 'ExternExposureStart'); %Configure trigger type and mode
            vid.TriggerRepeat = inf;
            src.IO_1SignalPolarity = 'rising'; %Configure polarity of IO signal at trigger port
            src.ExposureTime_s = obj.ExposureTime;
        end
    end
end

