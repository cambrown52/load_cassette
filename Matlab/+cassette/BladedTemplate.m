classdef BladedTemplate < cassette.Template
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here


    properties (Dependent)
        RCON
        WINDSEL


    end
    methods
        function m=get.RCON(obj); m=obj.interpretModule("RCON"); end
        function set.RCON(obj,data); obj.replaceModule("RCON",data); end

        function m=get.WINDSEL(obj); m=obj.interpretModule("WINDSEL"); end
        function set.WINDSEL(obj,data); obj.replaceModule("WINDSEL",data); end

    end

    methods
        function b=interpretModule(obj,modulename)
            arguments
                obj
                modulename (1,1) string
            end
            b=obj.getBlock("MSTART "+modulename,"MEND",exclude_limits=true);
            b=obj.lines2struct(b);
        end
        function replaceModule(obj,modulename,data)
            arguments
                obj
                modulename (1,1) string
                data (1,1) struct
            end
            block=obj.struct2lines(data);
            obj.replaceBlock("MSTART "+modulename,"MEND",block,exclude_limits=true)
        end
        function value=interpretProperty(obj,propname)
            arguments
                obj
                propname (1,1) string
            end
            value=obj.lines2struct(obj.getLine(propname));
        end
        function replaceProperty(obj,propname,value)
             arguments
                obj
                propname (1,1) string
                value (1,1)
             end
             old_value=obj.lines2struct(obj.getLine(propname));
             full_propname=string(fields(old_value));
             if propname~=full_propname
                 error("A partial match of property name '%s' was found for property '%s'",propname,full_propname)
             end
             obj.replaceLine(full_propname,sprintf("%s\t%s",full_propname,string(value)))
        end
        function insertProperty(obj,propname,value,position)
            arguments
                obj
                propname (1,1) string
                value (1,1)
                position (1,1)
            end
            try 
                old_value=obj.lines2struct(obj.getLine(propname));
                full_propname=string(fields(old_value));
                if propname~=full_propname
                    error("A partial match of property name '%s' was found for property '%s'",propname,full_propname)
                else
                    error("template already contains property '%s'= %s",full_propname,str(old_value.(full_propname)))
                end
            catch
            end
            obj.insertLines(position,sprintf("%s\t%s",propname,string(value)))

        end
        
        function value=interpretXMLProperty(obj,propname,inargs)
            arguments
                obj
                propname (1,1) string
                inargs.after_index (1,1) int32 = 1
            end
            lineindex=obj.findLine("<"+propname+">",method="contains",after_index=inargs.after_index);
            value=extractBetween(...
                obj.data(lineindex),...
                "<"+propname+">",...
                "</"+propname+">");
        end
        function replaceXMLProperty(obj,propname,value,inargs)
            arguments
                obj
                propname (1,1) string
                value (1,1)
                inargs.after_index (1,1) int32 = 1
            end
            lineindex=obj.findLine("<"+propname+">",method="contains",after_index=inargs.after_index);
            obj.data(lineindex)=replaceBetween(...
                obj.data(lineindex),...
                "<"+propname+">",...
                "</"+propname+">",...
                string(value));
        end

    end
    methods (Static)

        function block=moduleTurbulentWind(wind_speed,reference_height,ti_u,ti_v,ti_w,wind_dir,wind_file)
            arguments
                wind_speed (1,1) double
                reference_height (1,1) double
                ti_u (1,1) double
                ti_v (1,1) double
                ti_w (1,1) double
                wind_dir (1,1) double
                wind_file (1,1) string
            end
            block=struct(...
                "WMODEL",	3,...
                "UBAR",wind_speed,...
                "REFHT",reference_height,...
                "TURBHTTYPE", 1,...
                "TI",ti_u,...
                "TI_V",ti_v,...
                "TI_W", ti_w,...
                "WDIR",wind_dir,...
                "FLINC", 0,...
                "WINDF", string(wind_file),...
                "INTERPYZ", 3,...
                "CIRCWIND", 1,...
                "DIRAMP", 0,...
                "DIRSTIME", 0,...
                "DIRTIMEP", 0,...
                "DIRTYPE", "F",...
                "GUSTPROPAGATION",1);
        end
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
        function lines=struct2lines(input)
            
            properties=string(fields(input));
            I=length(properties);
            lines=strings(I,1);
            for i=1:I
                value=input.(properties(i));
                if isempty(value) || (isstring(value) && value=="")
                    lines(i)=properties(i);
                else
                    value_str=join(string(value),', ');
                    lines(i)=sprintf("%s\t%s",properties(i),value_str);
                end
            end
        end
    end
end