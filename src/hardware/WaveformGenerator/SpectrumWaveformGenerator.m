classdef (Abstract) SpectrumWaveformGenerator < WaveformGenerator
    %SpectrumWaveformGenerator Summary of this class goes here
    %   Please download the Spectrum AWG MATLAB driver:
    %   https://spectrum-instrumentation.com/products/drivers_examples/matlab_support.php
    
    properties (SetAccess = protected,Transient)
        Device
        RegMap
        ErrorMap
    end
    
    methods
        function obj = SpectrumWaveformGenerator(resourceName,name)
            %KEYSIGHT Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                resourceName string
                name string = string.empty
            end
            obj@WaveformGenerator(resourceName,name);
            obj.Manufacturer = "Spectrum";
        end

        function connect(obj)
            % Spectrum requires us to close the card handle every time we
            % upload a waveform. So it's not possible to establish a
            % constant connection. Every time we need to upload a new
            % waveform, we need to connect to the card again.
        end
        
        function connectSpec(obj)
            try
                obj.RegMap = spcMCreateRegMap;
                obj.ErrorMap = spcMCreateErrorMap;
            catch
                error("The Spectrum MATLAB library is not found. Please download it from Spectrum AWG websites and install it." + ...
                " Make sure the library is in MATLAB's search path.")
            end
            spcMFree;
            [isOpened,obj.Device] = spcMInitDevice(char(obj.ResourceName));
            if ~isOpened
                spcMErrorMessageStdOut(obj.Device, 'Error: Could not open card\n', true)
            end
        end

        function set(obj)

        end
        
        function setSpec(obj)
            obj.check;

            %% Set sampling rate
            [success,obj.Device] = spcMSetupClockPLL(obj.Device, obj.SamplingRate, 0);
            if (success == false)
                obj.closeSpec
                spcMErrorMessageStdOut(obj.Device, 'Error: spcMSetupClockPLL:\n\t', true);
                return;
            end
            obj.SamplingRate = obj.Device.setSamplerate;

            %% Set triggering
            switch obj.TriggerSource
                case "External"
                    [~,obj.Device] = spcMSetupTrigExternal(obj.Device, obj.RegMap('SPC_TM_POS'), 0, 0, 1, 0); 
                case "Immediate"
                    [~,obj.Device] = spcMSetupTrigSoftware(obj.Device, 0);
            end

            %% Set output
            for ii = 1:obj.NChannel
                if obj.IsOutput(ii)
                    [~,obj.Device] = spcMSetupAnalogOutputChannel(obj.Device, ii-1, 2000, 0, 0, obj.RegMap('SPCM_STOPLVL_ZERO'), 0, 0);     
                end
            end
        end

        function upload(obj)
            % Different from Keysight, Spectrum AWG insists that all
            % channels have the same number of segments and behave in the
            % same way. The samples must be uploaded segment by segment,
            % and each (physical) segment stores samples of all channels.
            % See the manual, chapter <data management>.
            % It might be buggy to use the simultaneous concat option or 
            % the trigger advance option with multiple channels.
            %% Set and connect
            obj.connectSpec;
            obj.setSpec;

            %% Get the minimum segment size
            enabledChannel = [];
            for ii = 1:obj.NChannel
                if isempty(obj.WaveformList{ii})
                    continue
                elseif obj.IsOutput(ii) == false
                    continue
                else
                    enabledChannel = [enabledChannel,ii];
                end
            end

            if isempty(enabledChannel)
                return
            else
                nEnabledChannel = numel(enabledChannel);
            end

            switch nEnabledChannel
                case 1
                    segmentSizeMinimum = 384;
                case 2
                    segmentSizeMinimum = 192;
                case 3
                    segmentSizeMinimum = 192;
                otherwise
                    segmentSizeMinimum = 96;
            end
            
            %% Load prepared waveforms
            t = cell(1,nEnabledChannel);
            for ii = 1:nEnabledChannel
                obj.WaveformList{enabledChannel(ii)}.SamplingRate = obj.SamplingRate;
                obj.WaveformList{enabledChannel(ii)}.NCycle = NaN; % For spectrum AWG, we don't want to split a periodic waveform into parts and upload
                t{ii} = obj.WaveformList{enabledChannel(ii)}.WaveformPrepared; % Load the prepared waveforms
            end

            %% Check numbers of waveforms of each channel
            nWaveList = zeros(1,nEnabledChannel);
            for ii = 1:nEnabledChannel
                nWaveList(ii) = size(t{ii},1);
            end
            if all(nWaveList == nWaveList(1))
                nWave = nWaveList(1) + 1;
            else
                obj.closeSpec
                error("The numbers of waveforms of each channel have to be the same.")
            end

            %% Set the peak-to-peak values
            amp = zeros(1,nEnabledChannel);
            for ii = 1:nEnabledChannel
                for jj = 1:(nWave-1)
                    amp(ii) = max(amp(ii),max(abs(t{ii}.Sample{jj})));
                end
                if obj.OutputLoad == "50"
                    oLim = obj.OutputLimit;
                else
                    oLim = obj.OutputLimit * 2;
                end
                if amp(ii) > oLim(2)
                    obj.closeSpec
                    error("The amplitude of the waveform exceeds the output limit.")
                elseif amp(ii) < oLim(1)
                    amp(ii) = oLim(1);
                end
                if obj.OutputLoad == "50"
                    [~,obj.Device] = spcMSetupAnalogOutputChannel(obj.Device, enabledChannel(ii)-1, amp(ii)*1e3, 0, 0, obj.RegMap('SPCM_STOPLVL_ZERO'), 0, 0);
                else
                    [~,obj.Device] = spcMSetupAnalogOutputChannel(obj.Device, enabledChannel(ii)-1, amp(ii)/2*1e3, 0, 0, obj.RegMap('SPCM_STOPLVL_ZERO'), 0, 0);
                end
            end

            %% Set channel selection
            % See the channel selection chapter
            bitAll = int64(2.^(enabledChannel-1));
            bitMask = bitAll(1);
            for ii = 1:(numel(bitAll)-1)
                bitMask = bitor(bitMask,bitAll(ii+1));
            end
            bitMaskH = int32(0);
            bitList = find(bitget(bitMask,33:64));
            for ii = 1:numel(bitList)
                bitMaskH = bitset(bitMaskH,bitList(ii));
            end
            bitMaskL = uint32(0);
            bitList = find(bitget(bitMask,1:32));
            for ii = 1:numel(bitList)
                bitMaskL = bitset(bitMaskL,bitList(ii));
            end
            [~,obj.Device] = spcMSetupModeRepSequence(obj.Device, bitMaskH, bitMaskL, nWave, 0); 

            %% Tailor the waveforms
            sample = cell(nWave,nEnabledChannel);
            scale=32767;            

            for jj = 1:nWave
                segSize = zeros(1,nEnabledChannel);
                for ii = 1:nEnabledChannel
                    if jj == nWave
                        sample{jj,ii} = zeros(1,segmentSizeMinimum);
                    else
                        sample{jj,ii} = t{ii}.Sample{jj};
                    end
                    if numel(sample{jj,ii}) < segmentSizeMinimum
                        sample{jj,ii} = [sample{jj,ii},interp1(sample{jj,ii},(numel(sample{jj,ii})+1):segmentSizeMinimum,'linear','extrap')];
                    end
                    remainder=32-mod(numel(sample{jj,ii}), 32);
                    segSize(ii) = ceil(numel(sample{jj,ii})/32)*32;
                    if mod(numel(sample{jj,ii}), 32)
                        sample{jj,ii} = [sample{jj,ii},interp1(sample{jj,ii}(end-9:end),11:(remainder+10),'linear','extrap')];
                    end
                    sample{jj,ii} = sample{jj,ii} * scale / amp(ii);
                end
                if ~all(segSize == segSize(1))
                    obj.closeSpec
                    error("The segment sizes of each channel have to be the same for each uploaded segment.")
                end
                errorCode = spcm_dwSetParam_i32(obj.Device.hDrv, obj.RegMap('SPC_SEQMODE_WRITESEGMENT'),jj-1); % somehow we have to write the output explicitly if we call spcm_dwSetParam_i32
                errorCode = spcm_dwSetParam_i32(obj.Device.hDrv, obj.RegMap('SPC_SEQMODE_SEGMENTSIZE'), segSize(1));
                errorCode = spcm_dwSetData(obj.Device.hDrv, 0, segSize(1), nEnabledChannel, 0, sample{jj,:});
            end

            %% Determine the order
            for ii = 1:nWave
                if ii ~= nWave
                    switch t{1}.PlayMode(ii)
                        case "Repeat"
                            [~,obj.Device] = spcMSetupSequenceStep(obj.Device,ii-1,ii,ii-1,t{1}.NRepeat(ii),0);
                        case "RepeatTilTrigger"
                            [~,obj.Device] = spcMSetupSequenceStep(obj.Device,ii-1,ii,ii-1,1,1);
                    end
                else
                    [~,obj.Device] = spcMSetupSequenceStep(obj.Device,ii-1,0,ii-1,1,1); %loop the zero output until trigger
                end
            end

            %% Activate Card
            commandMask = bitor(obj.RegMap('M2CMD_CARD_START'), obj.RegMap('M2CMD_CARD_ENABLETRIGGER'));
            errorCode = spcm_dwSetParam_i32(obj.Device.hDrv, obj.RegMap('SPC_M2CMD'), commandMask);

            if (errorCode ~= 0)
                [~, obj.Device] = spcMCheckSetError (errorCode, obj.Device);
                if errorCode == obj.ErrorMap('ERR_TIMEOUT')
                    errorCode = spcm_dwSetParam_i32 (obj.Device.hDrv, obj.RegMap('SPC_M2CMD'), obj.RegMap('M2CMD_CARD_STOP'));
                    fprintf (' OK\n ................... replay stopped\n');
                else
                    spcMErrorMessageStdOut (obj.Device, 'Error: spcm_dwSetParam_i32:\n\t', true);
                    obj.closeSpec
                    return;
                end
            end

            %% Check if upload is successful
            s = obj.check;
            if s
                for ii = enabledChannel
                    disp(obj.Name + " channel" + num2str(ii) + " uploaded [" + obj.WaveformList{ii}.Name +"] successfully.")
                end
                obj.saveObject;
            end
            obj.closeSpec;
        end

        function close(obj)

        end
        
        function closeSpec(obj)
            if isempty(obj.Device)
                warning("Device is not connected.")
                return
            else
                spcMCloseCard(obj.Device);
            end
        end
    
        function status = check(obj)
            status = false;
            if isempty(obj.Device)
                error("Device is not connected.")
            elseif obj.Device.cardFunction ~= obj.RegMap('SPCM_TYPE_AO')
                spcMErrorMessageStdOut(obj.Device, 'Error: Card function not supported by this example\n', false);
            elseif bitand(obj.Device.featureMap, obj.RegMap('SPCM_FEAT_SEQUENCE')) == 0
                spcMErrorMessageStdOut(obj.Device, 'Error: Sequence Mode Option not installed. Example was done especially for this option!\n', false);
            elseif string(obj.Device.errorText) ~= "No Error"
                obj.closeSpec
                error(obj.Device.errorText)
            else
                status = true;
            end
        end
    
    end
end

