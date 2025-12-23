classdef Template < matlab.mixin.SetGetExactNames & matlab.mixin.Copyable
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    properties
        name
        file
        data
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
            obj.data=readlines(file);
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
                if inargs.mkdir && ~exist(fileparts(obj(o).file),'dir')
                    mkdir(fileparts(obj(o).file))
                end

                % write contents into file
                fid=fopen(obj(o).file,'w+');
                fprintf(fid,"%s",sprintf('%s\r\n',obj(o).data));
                fclose(fid);
            end

        end

    end

    methods
        function index = findLine(obj,pattern,inargs)
            % Returns the index of the line which starts with pattern
            arguments
                obj
                pattern (1,1) string
                inargs.after_index (1,1) int32 = 1
                inargs.method (1,1) string {mustBeMember(inargs.method,["startsWith","contains"])}= "startsWith"
            end
            index=NaN;

            func=str2func(inargs.method);

            index=find(func(obj.data(inargs.after_index:end),pattern),1)+inargs.after_index-1;

        end

        function l=getLine(obj,pattern,inargs)
            arguments
                obj
                pattern (1,1) string
                inargs.after_index (1,1) int32 = 1
                inargs.method (1,1) string {mustBeMember(inargs.method,["startsWith","contains"])}= "startsWith"
            end
            index=obj.findLine(pattern,after_index=inargs.after_index,method=inargs.method);
            l=obj.data(index);
        end
        function replaceLine(obj,pattern,newline,inargs)
            arguments
                obj
                pattern (1,1) string
                newline (1,1) string
                inargs.after_index (1,1) int32 = 1
                inargs.method (1,1) string {mustBeMember(inargs.method,["startsWith","contains"])}= "startsWith"
            end
            index=obj.findLine(pattern,after_index=inargs.after_index,method=inargs.method);
            obj.data(index)=newline;
        end
        function insertLines(obj,pattern,newlines,inargs)
            arguments
                obj
                pattern (1,1) string
                newlines (:,1) string
                inargs.after_index (1,1) int32 = 1
                inargs.method (1,1) string {mustBeMember(inargs.method,["startsWith","contains"])}= "startsWith"
            end
            index=obj.findLine(pattern,after_index=inargs.after_index,method=inargs.method);
            obj.data=[obj.data(1:index); newlines;obj.data(index+1:end)];
        end
        function b=getBlock(obj,startpattern,endpattern,inargs)
            arguments
                obj
                startpattern (1,1) string
                endpattern (1,1) string
                inargs.exclude_limits (1,1) logical = true
            end
            index_start=obj.findLine(startpattern);
            index_end=obj.findLine(endpattern,after_index=index_start);
            if inargs.exclude_limits
                index_start=index_start+1;
                index_end=index_end-1;
            end
            b=obj.data(index_start:index_end);
        end
        function replaceBlock(obj,startpattern,endpattern,newblock,inargs)
            arguments
                obj
                startpattern (1,1) string
                endpattern (1,1) string
                newblock (:,1) string
                inargs.exclude_limits (1,1) logical = true
            end
            index_start=obj.findLine(startpattern);
            index_end=obj.findLine(endpattern,after_index=index_start);
            if inargs.exclude_limits
                index_start=index_start+1;
                index_end=index_end-1;
            end
            obj.data=[obj.data(1:index_start-1);newblock;obj.data(index_end+1:end)];
        end


    end
    methods (Static)

    end

end