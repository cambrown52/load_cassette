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
                speed (1,1) 
                direction (1,1)  = 0
                shear (1,1)  = 0
                density (1,1) = 1.225
            end
            obj.speed=speed;
            if ~isa(direction,"cassette.variables.BaseVariable")
                cassette.Utils.mustBeDegrees(direction,"Wind Direction")
            end
            obj.direction=direction;
            obj.shear=shear;
            obj.density=density;
        end


    end
end