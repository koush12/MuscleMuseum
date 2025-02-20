classdef Andor < Acquisition

    %Acquisition_Andor Acquisition class.
    %   Child Class of the Acquisition class to allow for connection to
    %   Andor.
    %   Requires modification of code since there is a proprietary SDK for
    %   Andor in contrast to the other cameras that can be accessed through
    %   the VideoInput class.


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
            % obj.VideoInput = vid; %No videoinput object compatible with
            % it.
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
            [ret]=SetEMCCDGain(gain);                        %   Set EMCCD gain
            CheckWarning(ret);
        end

        function setCallback(obj,callbackFunc) %%% Do not use for Acquisition_Andor, we shall for now disable AutoAcquire until this is figured out.
            %Set camera callback function.
            % if isempty(obj.VideoInput)
            %     error('Camera not connected. Try the "connectCamera" method first.')
            % end
            % vid = obj.VideoInput;
            % vid.FramesAcquiredFcn = callbackFunc;
        end

        function startCamera(obj)
            %Start camera recording
            % if isempty(obj.VideoInput)
            %     error('Camera not connected. Try the "connectCamera" method first.')
            % end
            [ret] = StartAcquisition();
            CheckWarning(ret);
        end

        function pauseCamera(obj)
            %Pause camera recording
            % vid = obj.VideoInput;
            % stop(vid);

            [ret] = AbortAcquisition();
            CheckWarning(ret);
        end

        function stopCamera(obj)
            %Stop camera recording
            % vid = obj.VideoInput;
            % stop(vid);
            % delete(vid);
            % clear vid;
            [ret] = AbortAcquisition();
            CheckWarning(ret);
            [ret] = AndorShutDown();
            CheckWarning(ret);
        end

    end
end

