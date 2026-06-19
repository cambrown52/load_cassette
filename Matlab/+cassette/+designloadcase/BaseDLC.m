classdef (Abstract) BaseDLC < matlab.mixin.SetGetExactNames
    properties
        name
        psf
        simulations (:,1) cassette.simulation.Case
    end

    methods
        function obj = BaseDLC(name,psf)
            arguments
                name (1,1) string
                psf (1,1) double {mustBePositive} = 1.35
            end
            obj.name=name;
            obj.psf=psf;
        end
    end
end