classdef ExponentialCurrentProfile < cassette.simulation.current.BaseCurrent

    properties
        exponent
    end

    methods
        function obj = ExponentialCurrentProfile(speed,direction,exponent)
            arguments
                speed % current speed at the surface
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
            if abs(obj.exponent/(1/7)-1)>100*eps
                CURRENT.USERSHEAR=-1;
                CURRENT.CSHEAR=obj.exponent;
            end
            template.CURRENT=CURRENT;
        end
        function to_orcaflex(obj,template)
            env=template.ofxmodel.environment;
            env.VerticalCurrentVariationMethod='Power law';
            env.CurrentSpeedAtSeabed=0;
            env.CurrentSpeedAtSurface=obj.speed;
            env.RefCurrentDirection=obj.direction;
            env.CurrentExponent=1/obj.exponent;

        end
    end
end