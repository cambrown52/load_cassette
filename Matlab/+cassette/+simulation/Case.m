classdef Case
    %SIMULATION Summary of this class goes here
    %   Detailed explanation goes here

    properties
        name 
        wind
        wave
        turbinestate
        conditions (:,1) 

    end

    methods
        function obj = Case(name,wind,wave,turbinestate,inargs)
            arguments
                name (1,1) string
                wind (1,1)
                wave (1,1)
                turbinestate (1,1)
                inargs.conditions (:,1) =[]

            end
            obj.name=name;
            obj.wind=wind;
            obj.turbinestate=turbinestate;
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

            inputfile=template.new_case(obj.name,outputfolder);

            % add path
            inputfile.replaceProperty("PATH",fileparts(inputfile.file))

            % specify run name and calculation type:
            inputfile.replaceProperty("RUNNAME",obj.name)

            index_runconfig=inputfile.findLine("<RunConfiguration>",method="contains");
            inputfile.replaceXMLProperty("Name",obj.name,after_index=index_runconfig)

            % replace various properties
            I=length(obj.conditions);
            for i=1:I
                obj.conditions(i).to_bladed(inputfile)
            end

            % set turbine state
            obj.turbinestate.to_bladed(inputfile)

            % set turbulence block
            obj.wind.to_bladed(inputfile)

        end

       
    end
end