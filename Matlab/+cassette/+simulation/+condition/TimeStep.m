classdef TimeStep < cassette.simulation.condition.BaseCondition

    properties
        dt (1,1) double {mustBePositive}= 60
    end

    methods
        function obj = TimeStep(dt)
            arguments
                dt (1,1)
            end
            obj.dt=dt;
        end

        % function to_bladed(obj,template)
        % end

        function to_orcaflex(obj,template)
            gen=template.ofxmodel.general;
            gen.ImplicitConstantTimeStep=obj.dt;
        end
        
    end
end