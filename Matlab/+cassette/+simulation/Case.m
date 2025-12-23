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

        end

        function run=to_bladed(obj,template,outputfolder)
            arguments
                obj
                template cassette.templates.BladedTemplate
                outputfolder (1,1) string {mustBeFolder}
            end

            run=template.new_case(obj.name,outputfolder);

            % add path
            run.replaceProperty("PATH",fileparts(run.file))

            % specify run name and calculation type:
            run.replaceProperty("RUNNAME",obj.name)

            index_runconfig=run.findLine("<RunConfiguration>",method="contains");
            run.replaceXMLProperty("Name",obj.name,after_index=index_runconfig)

            % replace various properties
            I=length(obj.conditions);
            for i=1:I
                obj.conditions(i).to_bladed(run)
            end

            % set turbine state
            obj.turbinestate.to_bladed(run)

            % set turbulence block
            obj.wind.to_bladed(run)

        end

       
    end
end