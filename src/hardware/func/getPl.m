function plObj = getPl(name,isLoadingSetting)
%GETWG Summary of this function goes here
%   Detailed explanation goes here
arguments
    name string
    isLoadingSetting logical = false
end
load("Config.mat","PhaseLockConfig")
plConfig = PhaseLockConfig(PhaseLockConfig.Name == name,:);
if ~isempty(plConfig)
    plObj = feval(plConfig.DeviceModel,plConfig.ResourceName,plConfig.Name);
    if isLoadingSetting
        load("PhaseLockSetting","PhaseLockSetting")
        setting = PhaseLockSetting(PhaseLockSetting.Name == name,:);
        plObj.Frequency = setting.Frequency;
        plObj.VariableName = setting.VariableName;
    end
else
    error("No device named [" + name + "] found in Config. Check your setConfig.")
end
end

