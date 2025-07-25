function wgObj = getWg(name,isLoadingSetting)
%GETWG Summary of this function goes here
%   Detailed explanation goes here
arguments
    name string
    isLoadingSetting logical = false
end
load("Config.mat","WaveformGeneratorConfig")
wgConfig = WaveformGeneratorConfig(WaveformGeneratorConfig.Name == name,:);
if ~isempty(wgConfig)
    wgObj = feval(wgConfig.DeviceModel,wgConfig.ResourceName,wgConfig.Name);
    if isLoadingSetting
        load("WaveformGeneratorSetting","WaveformGeneratorSetting")
        load("WaveformLibrary.mat","WaveformLibrary")
        setting = WaveformGeneratorSetting(WaveformGeneratorSetting.Name == name,:);
        wgObj.SamplingRate = setting.SamplingRate{1};
        wgObj.TriggerSource = setting.TriggerSource{1};
        wgObj.TriggerSlope = setting.TriggerSlope{1};
        wgObj.OutputMode = setting.OutputMode{1};
        wgObj.OutputLoad = setting.OutputLoad{1};
        wgObj.IsOutput = setting.IsOutput{1};
        wfName = setting.WaveformListName{1};
        for ii = 1:numel(wfName)
            if any(wfName(ii) == [WaveformLibrary.Name])
                wgObj.WaveformList{ii} = WaveformLibrary([WaveformLibrary.Name] == wfName(ii));
            else
                wgObj.WaveformList{ii} = [];
            end
        end
    end
else
    error("No device named [" + name + "] found in Config. Check your setConfig.")
end
end

