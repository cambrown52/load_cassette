classdef ControllerFault < cassette.simulation.condition.BaseCondition

    properties
        time
        value
    end


    methods
        function obj = ControllerFault(time,value)
            arguments
                time (1,1) double {mustBePositive}
                value (1,1) int32
            end
            obj.time=time;
            obj.value=value;
        end


        function to_bladed(obj,template)
            template.replaceProperty("FAULTTIME",obj.time,module="DISCON")
            template.replaceProperty("FAULTVAL",obj.value,module="DISCON")
        end
    end
end