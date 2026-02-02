classdef NoCurrent < cassette.simulation.current.BaseCurrent

    properties
        exponent
    end

    methods
        function obj = NoCurrent()
            obj@cassette.simulation.current.BaseCurrent(0,0)
        end
    end
    methods
        function to_bladed(obj,template)
            
            error("not yet implemented")
        end
    end
end