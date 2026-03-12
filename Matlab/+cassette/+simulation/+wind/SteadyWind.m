classdef SteadyWind < cassette.simulation.wind.BaseWind

    properties
    end

    methods
        function obj = SteadyWind(speed,direction,windshear,density)
            arguments
                speed (1,1) double
                direction (1,1) double = 0
                windshear (1,1) double = 0
                density (1,1) double = 1.225
            end
            obj@cassette.simulation.wind.BaseWind(speed,direction,windshear,density)
        end
        function to_bladed(obj,template)
            template.WINDSEL=template.moduleSteadyWind(obj.speed,template.RCON.HEIGHT,obj.direction*pi/180);
            template.replaceProperty("WSHEAR",obj.shear)
        end

        
    end
end