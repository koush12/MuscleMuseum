classdef Andor < Acquisition

    %Acquisition_Andor Acquisition class.
    %   Child Class of the Acquisition class to allow for connection to
    %   Andor.
    %   Requires modification of code since there is a proprietary SDK for
    %   Andor in contrast to the other cameras that can be accessed through
    %   the VideoInput class.
    properties (SetAccess=protected)
        CallbackFunc function_handle
        Future
    end

    methods
        function obj = Andor(acqName)
            %KEYSIGHT Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                acqName string
            end
            obj@Acquisition(acqName);
            obj.CameraType = "Andor";
        end

        function connectCamera(obj)
            %Connect to the camera. Return the VideoInput object.
            try
                ret=AndorInitialize('');
                CheckError(ret);
            catch ME
                msg = ['Camera connection failed. Check if the camera is connected. To connect to Andor cameras,', ...
                    ' you may need to restart MATLAB. Error message from MATLAB:',newline,...
                    ME.message];
                error(msg)
            end
        end

        function setCameraParameterAbsorption(obj)
            %Set camera parameters using the predefined configuration
            %functions.
            %% Set Cooling Settings
            [ret]=SetCoolerMode(1);                       % Camera temperature is maintained on ShutDown
            CheckWarning(ret);
            [ret]=CoolerON();                             %   Turn on temperature cooler
            CheckWarning(ret);
            [ret]=SetAcquisitionMode(3);                  %   Set acquisition mode; 3 for Kinetic Series
            CheckWarning(ret);

            %% Set Imaging Settings
            frameCount = 3;
            obj.ImageGroupSize = frameCount;
            obj.IsExternalTriggered = true;

            [ret]=SetNumberKinetics(frameCount);
            CheckWarning(ret);
            [ret]=SetExposureTime(obj.ExposureTime);                  %   Set exposure time in second  THIS IS THE USUAL VALUE
            CheckWarning(ret);
            % [ret]=SetExposureTime(0.1);                  %   TESTING EXPOSURE SETTING
            % CheckWarning(ret);
            [ret]=SetReadMode(4);                         %   Set read mode; 4 for Image
            CheckWarning(ret);
            [ret]=SetTriggerMode(1);                      %   Set internal trigger mode
            CheckWarning(ret);
            [ret]=SetShutter(1, 1, 0, 0);                 %   Open Shutter
            CheckWarning(ret);
            [ret,XPixels, YPixels]=GetDetector;           %   Get the CCD size
            CheckWarning(ret);
            [ret]=SetImage(1, 1, 1, XPixels, 1, YPixels); %   Set the image size
            CheckWarning(ret);
            [ret]=SetEMCCDGain(1);                        %   Set EMCCD gain
            CheckWarning(ret);
        end

        function setCallback(obj,callbackFunc)
            %Set camera callback function.
            obj.CallbackFunc = callbackFunc;
        end

        function startCamera(obj)
            %Start camera recording
            [ret] = StartAcquisition();
            CheckWarning(ret);

            p = gcp('nocreate');
            if isempty(p)
                p = parpool(1);
            end
            obj.Future = parfeval(p,@andorLoop,obj.ImageGroupSize,obj.CallbackFunc);

            function andorLoop(groupSize,callbackFunc)
                while(1)
                    pause(0.1)
                    % Setting this return value to avoid evaluation of the "if" statement
                    % for saving a new image if there is no new image.
                    atmcd.DRV_NO_NEW_DATA;

                    % Find "first" which is the index for the oldest image in the buffer.
                    % Updates when GetImages is called, but after having gotten all the
                    % images, it returns first = last = "the newest image that exists" even
                    % if the "newest image" in the buffer was already retreived.
                    [~, firstIndex, lastIndex] = GetNumberNewImages();
                    if (lastIndex - firstIndex) == groupSize
                        callbackFunc([],[])
                    end
                end
            end
        end

        function pauseCamera(obj)
            %Pause camera recording
            [ret] = AbortAcquisition();
            CheckWarning(ret);
        end

        function stopCamera(obj)
            %Stop camera recording
            cancel(obj.Future)
            [ret] = AbortAcquisition();
            CheckWarning(ret);
            [ret]=SetShutter(1, 2, 1, 1);
            CheckWarning(ret);
            [ret] = AndorShutDown();
            CheckWarning(ret);
        end

    end
end

