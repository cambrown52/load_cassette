classdef SimulationTime < cassette.simulation.condition.BaseCondition

    properties
        initializaton_time
        simulation_time
    end

    methods
        function obj = SimulationTime(initialization_time,simulation_time)
            arguments
                initialization_time (1,1) double {mustBePositive}
                simulation_time (1,1) double {mustBePositive}
            end
            obj.initializaton_time=initialization_time;
            obj.simulation_time=simulation_time;
        end

        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end