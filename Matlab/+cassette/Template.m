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
        function new_obj = new_case(obj,name)
            arguments
                obj
                name (1,1) string
            end

            new_obj=copy(obj);
            new_obj.name=name;
            new_obj.file=[];
        end
        function write(obj,folder)
            arguments
                obj
                folder (1,1) string {mustBeFolder}
            end

            fid=fopen(fullfile(folder,obj.name),'w+');
            fprintf(fid,"%s\r\n",obj.data);
            fclose(fid);

        end

    end

    methods
        function index = startsWith(obj,pattern,after_index)
            % Returns the index of the line which starts with pattern
            arguments
                obj
                pattern (1,1) string
                after_index (1,1) int32 = 1
            end
            index=NaN;
            for i = after_index:length(obj.data)
                if startsWith(obj.data(i), pattern)
                    index = i;
                    return
                end
            end
        end

        function l=getLine(obj,pattern,after_index)
            arguments
                obj
                pattern (1,1) string
                after_index (1,1) int64 = 1
            end
            index=obj.startsWith(pattern,after_index=after_index);
            l=obj.data(index);
        end
        function replaceLine(obj,pattern,newline,after_index)
            arguments
                obj
                pattern (1,1) string
                newline (1,1) string
                after_index (1,1) int64 = 1
            end
            index=obj.startsWith(pattern,after_index=after_index);
            obj.data(index)=newline;
        end
        function b=getBlock(obj,startpattern,endpattern)
            arguments
                obj
                startpattern (1,1) string
                endpattern (1,1) string
            end
            index_start=obj.startsWith(startpattern);
            index_end=obj.startsWith(endpattern,index_start);

            b=obj.data(index_start:index_end);
        end
        function replaceBlock(obj,startpattern,endpattern,newblock)
            arguments
                obj
                startpattern (1,1) string
                endpattern (1,1) string
                newblock (:,1) string
            end
            index_start=obj.startsWith(startpattern);
            index_end=obj.startsWith(endpattern,start_index);

            obj.data(index_start:index_end)=newblock;
        end

        function b=interpretBlock(obj,startpattern,endpattern)
            arguments
                obj
                startpattern (1,1) string
                endpattern (1,1) string
            end
            index_start=obj.startsWith(startpattern);
            index_end=obj.startsWith(endpattern,index_start);

            b=obj.lines2struct(obj.data(index_start:index_end));
        end
    end
    methods (Static)
        function result=lines2struct(lines)
            result=struct();
           
            I=length(lines);
            for i=1:I
                [token,remainder]=strtok(lines(i),[" ", sprintf("\t")]);
                parsed_str=strip(strsplit(remainder,','));
                parsed_num=str2double(parsed_str);
                if all(isnan(parsed_num))
                    parsed=parsed_str;
                else
                    parsed=parsed_num;
                end
                result.(token)=parsed;
            end            
        end
    end

end