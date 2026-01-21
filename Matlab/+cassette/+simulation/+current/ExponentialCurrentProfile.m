classdef ExponentialCurrentProfile < cassette.simulation.current.BaseCurrent

    properties
        exponent
    end

    methods
        function obj = ExponentialCurrentProfile(speed,direction,exponent)
            obj@cassette.simulation.current.BaseCurrent(speed,direction)
            obj.exponent = exponent;
        end
    end
    methods
        function to_bladed(obj,template)
        end
    end
end