classdef OffshoreCase < cassette.simulation.Case
    %SIMULATION Summary of this class goes here
    %   Detailed explanation goes here

    properties
        wave
        current

    end

    methods
        function obj = OffshoreCase(name,wind,wave,current,turbinestate,inargs)
            arguments
                name (1,1) string
                wind (1,1)
                wave (1,1)
                current (1,1) = cassette.simulation.current.NoCurrent
                turbinestate (1,1) = cassette.simulation.turbinestate.Idling
                inargs.conditions (:,1) = []

            end
            obj@cassette.simulation.Case(name,wind,turbinestate,conditions=inargs.conditions)
            obj.wave=wave;
            obj.current=current;
            if ~isempty(inargs.conditions)
                obj.conditions=inargs.conditions;
            end

        end
        function conditions=get_all_conditions(obj)
            conditions=[obj.wind;obj.turbinestate;obj.conditions;obj.wave;obj.current];
        end

        function inputfile=to_bladed(obj,template,outputfolder)
            arguments
                obj
                template cassette.templates.BladedTemplate
                outputfolder (1,1) string {mustBeFolder}
            end
            warning("deprecated: use template.merge (works for any template type) method instead of simulation.to_bladed")
            inputfile=to_bladed@cassette.simulation.Case(obj,template,outputfolder);

            % set wave file
            obj.wave.to_bladed(inputfile)
            obj.current.to_bladed(inputfile)

        end
        function st=to_struct(obj)
            st=to_struct@cassette.simulation.Case(obj);
            st.wave=obj.wave.to_struct();
            st.current=obj.current.to_struct();
        end

       
    end
end