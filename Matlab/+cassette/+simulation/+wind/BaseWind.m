classdef (Abstract) BaseWind < cassette.simulation.condition.BaseCondition
    %BASE Summary of this class goes here
    %   Detailed explanation goes here

    properties
        speed
        direction
        shear
        density
    end

    methods
        function obj = BaseWind(speed,direction,shear,density)
            arguments
                speed (1,1) double
                direction (1,1) double = 0
                shear (1,1) double = 0
                density (1,1) double = 1.225
            end
            obj.speed=speed;
            cassette.Utils.mustBeDegrees(direction,"Wind Direction")
            obj.direction=direction;
            obj.shear=shear;
            obj.density=density;
        end

        function to_bladed(obj,template)
            error('not implemented')
        end

    end
end