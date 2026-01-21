classdef EmergencyShutdown < cassette.simulation.condition.BaseCondition

    properties
        shutdowntime
    end


    methods
        function obj = EmergencyShutdown(shutdowntime)
            arguments
                shutdowntime (1,1) double {mustBePositive}
            end
            obj.shutdowntime=shutdowntime;
        end


        function to_bladed(obj,template)
            template.replaceProperty("TIME",2,module="SAFETYSYSTEM")
            template.replaceProperty("TIMEVAL",obj.shutdowntime,module="SAFETYSYSTEM")
        end
    end
end