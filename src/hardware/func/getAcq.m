function acqObj = getAcq(name,isLoadingSetting)
arguments
    name string
    isLoadingSetting logical = false
end
load("Config.mat","AcquisitionConfig")
acqConfig = AcquisitionConfig(AcquisitionConfig.Name == name,:);
if ~isempty(AcquisitionConfig)
    acqObj = feval(acqConfig.DeviceModel,acqConfig.Name);
else
    error("No device named [" + name + "] found in Config. Check your setConfig.")
end
end
