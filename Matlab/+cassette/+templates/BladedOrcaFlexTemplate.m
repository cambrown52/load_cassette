classdef BladedOrcaFlexTemplate < cassette.templates.BladedTemplate
    %BLADEDORCAFLEXTEMPLATE.M Summary of this class goes here
    %   Detailed explanation goes here

    properties
        orcaflex_template

    end
    properties (Dependent)
        orcaflex_settings
    end

    methods
        function obj = BladedOrcaFlexTemplate(file,name)
            arguments
                file (1,1) string {mustBeFile}
                name (1,1) string =string(missing)
            end
            obj@cassette.templates.BladedTemplate(file,name)

            orcaflex_template=cassette.templates.OrcaFlexTemplate(obj.orcaflex_settings.OrcaFlexInputModelPath);
            obj.orcaflex_template=orcaflex_template;
        end
        function settings=get.orcaflex_settings(obj)

            % get orcaflex input file
            index=obj.findLine("ExternalLoadsModules",method="contains");
            block=obj.getXMLBlock("ExternalLoadsModuleAdditionalParameters",after_index=index,remove_blockname=true);

            % adjust json data before interpretting
            index=contains(block,["OrcaFlexAPIDllPath", "OrcaFlexInputModelPath"]);
            block(index)=replace(block(index),"\","\\");
            block=block.join(newline);

            settings=jsondecode(block);
        end
        function set.orcaflex_settings(obj,settings)

            block=string(jsonencode(settings,"PrettyPrint",true));
            block=split(block,newline);
            
            % get orcaflex input file
            index=obj.findLine("ExternalLoadsModules",method="contains");
            obj.replaceXMLBlock("ExternalLoadsModuleAdditionalParameters",block,after_index=index);

        end

        function new_obj = new_case(obj,name,folder)
            arguments
                obj
                name (1,1) string
                folder (1,1) string
            end
            %bladed template new_case
            new_obj=new_case@cassette.templates.BladedTemplate(obj,name,folder);

            % orcaflex template new_case
            [bladed_folder,~,~]=fileparts(new_obj.file);
            new_obj.orcaflex_template=obj.orcaflex_template.new_case(name,bladed_folder);
        end

        function inputfile=merge(template,simulation,outputfolder)
            arguments
                template
                simulation cassette.simulation.OffshoreCase
                outputfolder (1,1) string
            end


            inputfile=template.new_case(simulation.name,outputfolder);

            % add path
            inputfile.replaceProperty("PATH",fileparts(inputfile.file))

            % specify run name and calculation type:
            inputfile.replaceProperty("RUNNAME",simulation.name)

            index_runconfig=inputfile.findLine("<RunConfiguration>",method="contains");
            inputfile.replaceXMLProperty("Name",simulation.name,after_index=index_runconfig)

            % replace various properties
            I=length(simulation.conditions);
            for i=1:I
                simulation.conditions(i).to_bladed(inputfile)
            end

            % set turbine state
            simulation.turbinestate.to_bladed(inputfile)

            % set turbulence block
            simulation.wind.to_bladed(inputfile)

            inputfile.metadata=simulation.to_struct();


            % set wave file
            simulation.wave.to_orcaflex(inputfile.orcaflex_template)
            simulation.current.to_orcaflex(inputfile.orcaflex_template)

            %set orcaflex file path in
            orcaflex_settings=inputfile.orcaflex_settings;
            orcaflex_settings.OrcaFlexInputModelPath=inputfile.orcaflex_template.file;
            inputfile.orcaflex_settings=orcaflex_settings;


        end

        function write_(obj)
            arguments
                obj (1,1) cassette.templates.BladedOrcaFlexTemplate
            end
            write_@cassette.templates.BladedTemplate(obj)
            obj.orcaflex_template.write_()
        end


    end
end