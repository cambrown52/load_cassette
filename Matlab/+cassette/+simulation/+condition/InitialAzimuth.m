classdef InitialAzimuth < cassette.simulation.condition.BaseCondition

    properties
        azimuth
    end


    methods
        function obj = InitialAzimuth(azimuth)
            arguments
                azimuth (1,1) double {mustBeNonnegative}
            end
            cassette.Utils.mustBeDegrees(azimuth)
            obj.azimuth=azimuth;
        end
        function to_bladed(obj,template)
            template.replaceProperty("INAZI",obj.azimuth*pi/180,module="INITCON");
        end
    end
end