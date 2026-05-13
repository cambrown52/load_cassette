classdef ASCIITemplate < cassette.templates.Template
    properties
        data
    end

    methods
        function obj = ASCIITemplate(file,name)
            obj@cassette.templates.Template(file,name)
            obj.data=readlines(file);
        end
    
        function write_(obj)
            arguments
                obj (1,1) cassette.templates.ASCIITemplate
            end
            % write contents into file
            fid=fopen(obj.file,'w+');
            fprintf(fid,"%s",sprintf('%s\r\n',obj.data));
            fclose(fid);
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
                inargs.error(1,1) string {mustBeMember(inargs.error,["raise","returnEmpty"])}="raise"
            end
            index=NaN;

            func=str2func(inargs.method);
            index_all=func(obj.data(inargs.after_index:end),pattern);
            if ~any(index_all)
                switch inargs.error
                    case "raise"
                        error("could not find pattern %s in template %s",pattern,obj.name)
                    case "returnEmpty"
                        index=[];
                end
            else
                index=find(index_all,1)+inargs.after_index-1;
            end

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

end