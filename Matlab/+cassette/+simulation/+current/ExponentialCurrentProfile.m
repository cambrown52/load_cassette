classdef ExponentialCurrentProfile < cassette.simulation.current.BaseCurrent

    properties
        exponent
    end

    methods
        function obj = ExponentialCurrentProfile(speed,direction,exponent)
            arguments
                speed
                direction
                exponent (1,1) double {mustBePositive}= 1/7
            end
            obj@cassette.simulation.current.BaseCurrent(speed,direction)
            obj.exponent = exponent;
        end
    end
    methods
        function to_bladed(obj,template)
            CURRENT=template.CURRENT;
            CURRENT.ICURRS=1;
            CURRENT.US0Z0=obj.speed;
            CURRENT.MUCS=obj.direction*pi/180;
            CURRENT.
            template.CURRENT=CURRENT;
        end
    end
end