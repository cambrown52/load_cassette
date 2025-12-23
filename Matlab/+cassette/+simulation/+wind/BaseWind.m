classdef (Abstract) BaseWind < matlab.mixin.SetGetExactNames
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
            obj.direction=direction;
            obj.shear=shear;
            obj.density=density;
        end

    end
end