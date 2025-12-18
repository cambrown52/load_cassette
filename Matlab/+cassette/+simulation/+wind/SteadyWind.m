classdef SteadyWind < cassette.simulation.wind.BaseWind

    properties
    end

    methods
        function obj = SteadyWind(speed,direction,density)
            arguments
                speed (1,1) double
                direction (1,1) double = 0
                density (1,1) double = 1.225
            end
            obj@cassette.simulation.wind.BaseWind(speed,direction,density)
        end
    end
end