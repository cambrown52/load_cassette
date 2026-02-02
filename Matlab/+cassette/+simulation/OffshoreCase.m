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

        function inputfile=to_bladed(obj,template,outputfolder)
            arguments
                obj
                template cassette.templates.BladedTemplate
                outputfolder (1,1) string {mustBeFolder}
            end
            inputfile=to_bladed@cassette.simulation.Case(obj,template,outputfolder);

            % inputfile=template.new_case(obj.name,outputfolder);
            % 
            % % add path
            % inputfile.replaceProperty("PATH",fileparts(inputfile.file))
            % 
            % % specify run name and calculation type:
            % inputfile.replaceProperty("RUNNAME",obj.name)
            % 
            % index_runconfig=inputfile.findLine("<RunConfiguration>",method="contains");
            % inputfile.replaceXMLProperty("Name",obj.name,after_index=index_runconfig)
            % 
            % % replace various properties
            % I=length(obj.conditions);
            % for i=1:I
            %     obj.conditions(i).to_bladed(inputfile)
            % end

            % % set turbine state
            % obj.turbinestate.to_bladed(inputfile)

            % % set turbulence block
            % obj.wind.to_bladed(inputfile)

            % set wave file
            obj.wave.to_bladed(inputfile)
            obj.current.to_bladed(inputfile)

        end

       
    end
end