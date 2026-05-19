classdef (Abstract) BaseDLC < matlab.mixin.SetGetExactNames
    properties
        name
        simulations (:,1) cassette.simulation.Case
    end

    methods
        function obj = BaseDLC(name)
            arguments
                name (1,1) string
            end
            obj.name=name;
        end
    end

end