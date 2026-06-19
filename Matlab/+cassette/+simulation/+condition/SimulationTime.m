classdef SimulationTime < cassette.simulation.condition.BaseCondition

    properties
        initialization_time
        simulation_time
        output_buffer (1,1) double {mustBePositive}= 60
    end
    properties (Dependent)
        total_time
    end


    methods
        function obj = SimulationTime(initialization_time,simulation_time)
            arguments
                initialization_time (1,1)
                simulation_time (1,1)
            end
            obj.initialization_time=initialization_time;
            obj.simulation_time=simulation_time;
        end
        function t=get.total_time(obj)
            t=obj.initialization_time+obj.simulation_time;
        end

        function to_bladed(obj,template)
            template.replaceProperty("OUTSTR",obj.initialization_time)
            template.replaceProperty("ENDT",obj.total_time)
            template.replaceProperty("TLOGBUF",obj.output_buffer)
        end
        function to_orcaflex(obj,template)
            gen=template.ofxmodel.general;
            gen.StartTime=ofx.OrcinaDefaultReal;
            gen.StageCount=2;
            gen.StageDuration(1)=obj.initialization_time;
            gen.StageDuration(2)=obj.simulation_time;
        end
    end
end