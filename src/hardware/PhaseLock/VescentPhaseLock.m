classdef (Abstract) VescentPhaseLock < PhaseLock
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Serialport Serialport
    end
    
    methods
        function obj = VescentPhaseLock(resourceName,name)
            arguments
                resourceName string
                name string = string.empty
            end
            obj@PhaseLock(resourceName,name);
            obj.Manufacturer = "Vescent";
        end
        
        function connect(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            if ~isempty(obj.Serialport)
                if isvalid(obj.Serialport)
                    warning("PhaseLock box was already connected")
                    return
                end
            end
            obj.Serialport = serialport(obj.ResourceName,115200);
            configureTerminator(obj.Serialport,"CR");
        end

        function close(obj)
            delete(obj.Serialport);
        end

        function check(obj)
            if isempty(obj.Serialport)
                error("PhaseLock box is not connected")
            elseif ~isvalid(obj.Serialport)
                error("PhaseLock box was deleted")
            end
            writeline(obj.Serialport,"SERVO?")
            s = readline(obj.Serialport);
            if s == "Off"
                obj.Status = false;
            else
                obj.Status = true;
            end
        end

        function lock(obj)
            if isempty(obj.Frequency)
                error("Must specify the lock frequency")
            end
            obj.unlock
            cm = "BNTGT " + num2str(obj.Frequency);
            writeline(obj.Serialport,cm);
            readline(obj.Serialport);
            writeline(obj.Serialport,"SERVO ON");
            readline(obj.Serialport);
        end

        function unlock(obj)
            obj.check;
            if obj.Status
                writeline(obj.Serialport,"SERVO OFF");
                readline(obj.Serialport);
            end
        end
    end
end

