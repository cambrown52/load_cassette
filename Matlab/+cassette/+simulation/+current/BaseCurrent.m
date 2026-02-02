classdef (Abstract) BaseCurrent < matlab.mixin.SetGetExactNames
    %BASE Summary of this class goes here
    %   Detailed explanation goes here

    properties
        speed
        direction
    end

    methods
        function obj = BaseCurrent(speed,direction)
            arguments
                speed (1,1) double
                direction (1,1) double = 0
            end
            obj.speed=speed;
            cassette.Utils.mustBeDegrees(direction,"Current Direction")
            obj.direction=direction;
        end

    end
end