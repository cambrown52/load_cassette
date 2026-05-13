classdef BladedOrcaFlexTemplate < cassette.templates.BladedTemplate
    %BLADEDORCAFLEXTEMPLATE.M Summary of this class goes here
    %   Detailed explanation goes here

    properties
        orcaflex_template
    end

    methods
        function obj = BladedOrcaFlexTemplate(file,name)
            arguments
                file (1,1) string {mustBeFile}
                name (1,1) string =string(missing)
            end
            obj@cassette.templates.BladedTemplate(file,name)

            % get orcaflex input file
            index=obj.findLine("ExternalLoadsModules",method="contains");
            block=obj.getXMLBlock("ExternalLoadsModuleAdditionalParameters",after_index=index);
            OrcaFlexSettings=jsondecode(block);


            %obj.orcaflex_template=orcaflex_template;
        end
        function n=get.name(obj)
            obj.bladed_template.name
        end

        function new_obj = new_case(obj,name,folder)
            arguments
                obj
                name (1,1) string
                folder (1,1) string
            end

            new_obj=copy(obj);
            new_obj.name=name;
            new_obj.file=fullfile(folder,name);
        end

        function inputfile=merge(template,simulation,outputfolder)
            arguments
                template
                simulation cassette.simulation.OffshoreCase
                outputfolder (1,1) string
            end


            inputfile=template.new_case(simulation.name,outputfolder);

            % add path
            inputfile.bladed_template.replaceProperty("PATH",fileparts(inputfile.file))

            % specify run name and calculation type:
            inputfile.bladed_template.replaceProperty("RUNNAME",simulation.name)

            index_runconfig=inputfile.bladed_template.findLine("<RunConfiguration>",method="contains");
            inputfile.bladed_template.replaceXMLProperty("Name",simulation.name,after_index=index_runconfig)

            % replace various properties
            I=length(simulation.conditions);
            for i=1:I
                simulation.conditions(i).to_bladed(inputfile.bladed_template)
            end

            % set turbine state
            simulation.turbinestate.to_bladed(inputfile.bladed_template)

            % set turbulence block
            simulation.wind.to_bladed(inputfile.bladed_template)


            inputfile.metadata=simulation.to_struct();


            % set wave file
            obj.wave.to_orcaflex(inputfile.orcaflex_template)
            obj.current.to_orcaflex(inputfile.orcaflex_template)

            %set orcaflex file path in 

        end

    end
end