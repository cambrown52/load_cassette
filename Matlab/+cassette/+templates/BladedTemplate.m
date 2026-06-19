classdef BladedTemplate < cassette.templates.ASCIITemplate
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties (Hidden,SetAccess=private)
        towerGeom = []
    end
        

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
                obj.insertModule("CURRENT",obj.moduleCurrent(),"DISCON")
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

        function [nodes,members]=interpretTowerGeom(obj)
            if ~isempty(obj.towerGeom)
                nodes=obj.towerGeom.nodes;
                members=obj.towerGeom.members;
            else

                % read bladed modules
                TGEOM=obj.interpretModule("TGEOM");
                TMASS=obj.interpretModule("TMASS");

                % interpret node coordinates
                nodes=array2table(TGEOM.TCLOCAL,'VariableNames',["X" "Y" "Z"]);
                nodes.id=(1:height(nodes))';
                nodes=movevars(nodes,"id","Before",1);

                % interpret member geometry
                members_w=table(TGEOM.ELSTNS,TGEOM.TDIAM,TMASS.WALLTHICK,VariableNames=["NODE", "TDIAM", "WALLTHICK"]);
                members_w.Length=arrayfun(@(id_1,id_2)norm(nodes{id_1,["X" "Y" "Z"]}-nodes{id_2,["X" "Y" "Z"]}),members_w.NODE(:,1),members_w.NODE(:,2));
                members_w.id=(1:height(members_w))';

                % reshape members table
                members_1=members_w;
                members_1.End(:)=1;
                members_1.NODE(:,2)=[];
                members_1.TDIAM(:,2)=[];
                members_1.WALLTHICK(:,2)=[];
                members_1.DistanceAlongMember(:)=0;

                members_2=members_w;
                members_2.End(:)=2;
                members_2.NODE(:,1)=[];
                members_2.TDIAM(:,1)=[];
                members_2.WALLTHICK(:,1)=[];
                members_2.DistanceAlongMember=members_2.Length;

                members=sortrows([members_1;members_2],"id");

                % add member node height
                members.z=nodes.Z(members.NODE);
                members.zSBD=members.z+TGEOM.SEADEPTH;
                members=movevars(members,"id","Before",1);

                obj.towerGeom=struct("nodes",nodes,"members",members);
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

        function inputfile=merge(template,simulation,outputfolder)
           
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
                inargs.after_index (1,1) = missing
             end
             if ~ismissing(inargs.module)
                 after_index=obj.findLine("MSTART "+inargs.module);
                 if ~ismissing(inargs.after_index)
                     warning("after_index input ignored when both module and after_index is input")
                 end
             elseif ~ismissing(inargs.after_index)
                 after_index=inargs.after_index;
             else
                 after_index=1;
             end

             old_value=obj.lines2struct(obj.getLine(propname,after_index=after_index));
             full_propname=string(fields(old_value));
             if propname~=full_propname
                 error("A partial match of property name '%s' was found for property '%s'",propname,full_propname)
             end
             obj.replaceLine(full_propname,sprintf("%s\t%s",full_propname,string(value)),after_index=after_index)
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
        function lines=getXMLBlock(obj,blockname,inargs)
            arguments
                obj
                blockname (1,1) string
                inargs.after_index (1,1) int32 = 1
                inargs.remove_blockname (1,1) logical =false
            end
            startindex=obj.findLine("<"+blockname+">",method="contains",after_index=inargs.after_index);
            endindex=obj.findLine("</"+blockname+">",method="contains",after_index=startindex);
            lines=obj.data(startindex:endindex);
            if inargs.remove_blockname
                lines(1)=extractAfter(lines(1),"<"+blockname+">");
                lines(end)=extractBefore(lines(end),"</"+blockname+">");
            end
        end
        function replaceXMLBlock(obj,blockname,block,inargs)
            arguments
                obj
                blockname (1,1) string
                block
                inargs.after_index (1,1) int32 = 1
                inargs.add_blockname (1,1) logical =true
            end
            startindex=obj.findLine("<"+blockname+">",method="contains",after_index=inargs.after_index);
            endindex=obj.findLine("</"+blockname+">",method="contains",after_index=startindex);
            if inargs.add_blockname
                block(1)= extractBefore(obj.data(startindex),"<"+blockname+">")+"<"+blockname+">"+block(1);
                block(end)=block(end)+"</"+blockname+">"+extractAfter(obj.data(endindex),"</"+blockname+">");
            end
            obj.data=[obj.data(1:startindex-1);block;obj.data(endindex+1:end)];

        end

    end
    methods (Static)
        function block=moduleSteadyWind(wind_speed,reference_height,wind_dir)
            arguments
                wind_speed (1,1) double
                reference_height (1,1) double
                wind_dir (1,1) double
            end
            cassette.Utils.mustBeRadians(wind_dir)
            block=struct("WMODEL",	1,...
                "MEANHTTYPE",	1,...
                "USPD",	 wind_speed,...
                "REFHT",	 reference_height,...
                "WDIR",	 wind_dir,...
                "FLINC",	 0);
        end
        
        function block=moduleECDWind(initial_wind_speed,reference_height,initial_wind_dir,gust_time,wind_speed_increase,wind_direction_change)
            arguments
                initial_wind_speed (1,1) double
                reference_height (1,1) double
                initial_wind_dir (1,1) double
                gust_time (1,1) double
                wind_speed_increase (1,1) double
                wind_direction_change (1,1) double
            end

            block=struct(...
                "WMODEL",	4,...
                "MEANHTTYPE",	1,...
                "FLINC",	0,...
                "REFHT",	reference_height,...
                "WSSTRT",	initial_wind_speed,...
                "WSAMP",	wind_speed_increase,...
                "WSSTIME",	gust_time,...
                "WSTIMEP",	10,...
                "WSTYPE",	"H",...
                "DIRSTRT",	initial_wind_dir,...
                "DIRAMP",	wind_direction_change,...
                "DIRSTIME",	gust_time,...
                "DIRTIMEP",	10,...
                "DIRTYPE",	"H",...
                "HWSSTRT",	0,...
                "HWSAMP",	0,...
                "HWSSTIME",	0,...
                "HWSTIMEP",	0,...
                "HWSTYPE",	"F",...
                "VWSSTRT",	0,...
                "VWSAMP",	0,...
                "VWSSTIME",	0,...
                "VWSTIMEP",	0,...
                "VWSTYPE",	"F",...
                "VDCSTRT",	0,...
                "VDCAMP",	0,...
                "VDCSTIME",	0,...
                "VDCTIMEP",	0,...
                "VDCTYPE",	"F");
        end




        function block=moduleTurbulentWind(wind_speed,reference_height,ti_u,ti_v,ti_w,wind_dir,wind_file,inargs)
            arguments
                wind_speed (1,1) double
                reference_height (1,1) double
                ti_u (1,1) double
                ti_v (1,1) double
                ti_w (1,1) double
                wind_dir (1,1) double
                wind_file (1,1) string
                inargs.turbulence_box_centered_on_hub(1,1) logical = true
            end
            cassette.Utils.mustBeRadians(wind_dir)
            if inargs.turbulence_box_centered_on_hub
                TURBHTTYPE=0;
            else
                TURBHTTYPE=1;
            end
            block=struct(...
                "WMODEL",	3,...
                "UBAR",wind_speed,...
                "REFHT",reference_height,...
                "TURBHTTYPE", TURBHTTYPE,...
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
                line=strip(lines(i),"'");
                if isletter(line{1}(1))
                    [token,remainder]=strtok(lines(i),[" ", sprintf("\t")]);
                    token=strip(token,"'");
                    parsed_str=strsplit(strip(remainder),[" ",","]);
                    parsed_num=str2double(parsed_str);
                    if all(isnan(parsed_num))
                        parsed=parsed_str;
                    else
                        parsed=parsed_num;
                    end
                    result.(token)=parsed;
                else
                    parsed_str=strsplit(strip(line),[","," "]);
                    parsed_num=str2double(parsed_str);
                    if all(isnan(parsed_num))
                        parsed=parsed_str;
                    else
                        parsed=parsed_num;
                    end
                    result.(token)=[result.(token);parsed];
                end
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