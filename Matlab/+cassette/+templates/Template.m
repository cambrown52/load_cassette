classdef Template < matlab.mixin.SetGetExactNames & matlab.mixin.Copyable
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    properties
        name
        file
        metadata (1,1) struct
    end
    methods (Abstract)
        write_(obj)
        filledtemplate=merge(obj,simulation,outputfolder)
    end

    methods
        function obj = Template(file,name)
            arguments
                file (1,1) string {mustBeFile}
                name (1,1) string =string(missing)

            end
            if ismissing(name)
                [~,name,~]=fileparts(file);
            end

            obj.name=name;
            obj.file=file;
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
        function write(obj,inargs)
            arguments
                obj
                inargs.mkdir (1,1) logical = true
            end

            O=length(obj);
            for o=1:O
                
                % determine filename
                fprintf("[%i] writing:\t%s\n",o,obj(o).file)
                outputfolder=fileparts(obj(o).file);
                if inargs.mkdir && ~exist(outputfolder,'dir')
                    mkdir(outputfolder)
                end

                % write contents into file
                obj(o).write_()

                % write metadata
                if ~isempty(obj(o).metadata)
                    metadata=jsonencode(obj(o).metadata,"PrettyPrint",true);
                    
                    writelines(...
                        metadata,...
                        fullfile(outputfolder,obj(o).name+".metadata.json")...
                        );
                end

            end

        end

    end

end