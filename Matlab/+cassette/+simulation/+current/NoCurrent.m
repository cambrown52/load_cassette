classdef NoCurrent < cassette.simulation.current.BaseCurrent

    methods
        function obj = NoCurrent()
            obj@cassette.simulation.current.BaseCurrent(0,0)
        end
    end
    methods
        function to_orcaflex(obj,template)
            env=template.ofxmodel.environment;
            env.VerticalCurrentVariationMethod='Power law';
            env.CurrentSpeedAtSeabed=0;
            env.CurrentSpeedAtSurface=0;
            env.RefCurrentDirection=obj.direction;
        end
        function to_bladed(obj,template)
            template.CURRENT=template.moduleCurrent();
        end
    end
end