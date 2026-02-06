classdef BladedTemplate < cassette.templates.Template
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here


    properties (Dependent)
        RCON
        WINDSEL
        CURRENT


    end
    methods
        function m=get.RCON(obj); m=obj.interpretModule("RCON"); end
        function set.RCON(obj,data); obj.replaceModule("RCON",data); end

        function m=get.WINDSEL(obj); m=obj.interpretModule("WINDSEL"); end
        function set.WINDSEL(obj,data); obj.replaceModule("WINDSEL",data); end

        function m=get.CURRENT(obj)
            if ~obj.existsModule("CURRENT")
                obj.insertModule("CURRENT",obj.moduleCurrent(),"DISCON")
            end
            m=obj.interpretModule("CURRENT");
        end
        function set.CURRENT(obj,data) 
            if ~obj.existsModule("CURRENT")
                error("Module CURRENT not found in template %s",obj.name)
            end
            obj.replaceModule("CURRENT",data); 
        end
        function out=existsModule(obj,name)
            arguments
                obj
                name (1,1) string
            end
            index=obj.findLine("MSTART "+name,error="returnEmpty");
            if isempty(index)
                out=false;
            else
                out=true;
            end
        end


    end

    methods
        function new_obj = new_case(obj,name,folder)
            arguments
                obj
                name (1,1) string
                folder (1,1) string
            end

            new_obj=copy(obj);
            new_obj.name=name;
            new_obj.file=fullfile(folder,name,"DTBLADED.IN");
        end
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
        function insertModule(obj,modulename,data,after_module)
            arguments
                obj
                modulename (1,1) string
                data (1,1) struct
                after_module (1,1) string
            end
            block=[...
                ""; %blank line to separate modules
                "MSTART "+modulename;
                obj.struct2lines(data);
                "MEND"];
            
            index_module=obj.findLine("MSTART "+after_module);
            obj.insertLines("MEND",block,after_index=index_module)

        end
        function value=interpretProperty(obj,propname)
            arguments
                obj
                propname (1,1) string
            end
            value=obj.lines2struct(obj.getLine(propname));
        end
        function replaceProperty(obj,propname,value,inargs)
             arguments
                obj
                propname (1,1) string
                value (1,1)
                inargs.module (1,1) string = missing
             end
             if ~ismissing(inargs.module)
                 index_module=obj.findLine("MSTART "+inargs.module);
             else
                 index_module=1;
             end

             old_value=obj.lines2struct(obj.getLine(propname,after_index=index_module));
             full_propname=string(fields(old_value));
             if propname~=full_propname
                 error("A partial match of property name '%s' was found for property '%s'",propname,full_propname)
             end
             obj.replaceLine(full_propname,sprintf("%s\t%s",full_propname,string(value)),after_index=index_module)
        end
        function insertProperty(obj,propname,value,after_property)
            arguments
                obj
                propname (1,1) string
                value (1,1)
                after_property (1,1)
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
            obj.insertLines(after_property,sprintf("%s\t%s",propname,string(value)))

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
            cassette.Utils.mustBeRadians(wind_dir)
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
        function block=moduleCurrent()
            block=struct(...
                "ICURRW", 0,...
                "NSVEL", 0,...
                "NSDEPTH", 0,...
                "MUCW", 0,...
                "ICURRS", 0,...
                "US0Z0", 0,...
                "MUCS", 0,...
                "ICURRN", 0,...
                "NSCURRN", 0,...
                "MUCN", 0);

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