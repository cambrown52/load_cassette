classdef PitchFailure < cassette.simulation.condition.BaseCondition

    properties
        time
        value
    end


    methods
        function obj = PitchFailure(time,value)
            arguments
                time (1,1) double {mustBePositive}
                value (1,1) string
            end
            obj.time=time;
            obj.value=value;
        end


        function to_bladed(obj,template)
            template.replaceProperty("FAILTIME",obj.time,module="RTOL")
            template.replaceProperty("PFAIL",obj.value,module="RTOL")

        end
    end
end