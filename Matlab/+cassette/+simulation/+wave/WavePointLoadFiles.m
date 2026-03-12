classdef WavePointLoadFiles < cassette.simulation.condition.BaseCondition
    %WAVEPOINTLOADFILES Summary of this class goes here
    %   Detailed explanation goes here

    properties
        jsonfile
        jsondata

        pointloadfiles

        nodedata

    end

    methods
        function obj = WavePointLoadFiles(jsonfile)
            arguments
                jsonfile (1,1) string {mustBeFile}
            end
            obj.jsonfile = jsonfile;
            
            % read/interpret json data
            jsondata=fileread(jsonfile);
            obj.jsondata=jsondecode(jsondata);

            % point load files
            [folder,stem,extension]=fileparts(jsonfile);
            pointloadfiles=struct2table(dir(fullfile(folder,stem+"*.txt")));
            pointloadfiles.Member_str=strip(erase(erase(pointloadfiles.name,stem),".txt"),"_");
            pointloadfiles.MemberID=str2double(erase(pointloadfiles.Member_str,"Mbr_"));

            pointloadfiles=sortrows(pointloadfiles,"MemberID","descend");
            pointloadfiles.path=fullfile(pointloadfiles.folder,pointloadfiles.name);
            obj.pointloadfiles=pointloadfiles;


            % convert jsondata into a table of nodes
            Variables=string(fields(obj.jsondata.fnddim));

            VarName=extractBefore(Variables,"_");
            VarUnit=extractAfter(Variables,"_");

            rows=arrayfun(@(x)struct2table(obj.jsondata.fnddim.(x)),Variables,UniformOutput=false);
            nodedata=vertcat(rows{:});
            nodedata.VarName=VarName;

            nodedata=rows2vars(nodedata,VariableNamesSource="VarName");
            nodedata=renamevars(nodedata,"OriginalVariableNames","NodeID_str");
            nodedata.NodeID=str2double(erase(string(nodedata.NodeID_str),"x"));
            nodedata.D_MG=nodedata.D+2*nodedata.tmg/1000;

            nodedata.pointloadfile(:)=string(missing);
            nodedata.pointloadfile(1:height(pointloadfiles))=obj.pointloadfiles.path;
            obj.nodedata=nodedata;


        end
        function plotGeometry(obj)
            figure
            hold on
            plot(obj.nodedata.D,obj.nodedata.h,'b.-','DisplayName',"OD.")
            plot(obj.nodedata.D_MG,obj.nodedata.h,'g.-',"DisplayName","OD with MG")
            xlim([0 15])
            xlabel('Diameter [m]')
            ylabel('Height [mSBD]')
            legend show
        end
        function matchdata=match_bladed_nodes(obj,template)

            % extract bladed members
            [BladedNodes,BladedMembers]=template.interpretTowerGeom();
            BladedMembers=BladedMembers(BladedMembers.End==1,:);
            
            % extract point load nodes
            matchdata=obj.nodedata(~ismissing(obj.nodedata.pointloadfile),:);

            % merge wave file nodes and bladed members
            I=height(matchdata);
            for i=1:I
                [distance,index]=min(abs(BladedMembers.zSBD-matchdata.h(i)));
                if distance>0.0001
                    error('Could not find a match for wave load file "%s" at h=%fm.\nClosest node is at h=%fm (%fm away).',matchdata.pointloadfile(i),matchdata.h(i),BladedMembers.zSBD(index),distance)
                end
                matchdata.BladedMemberID(i)=BladedMembers.id(index);
                matchdata.DistanceAlongMember(i)=BladedMembers.DistanceAlongMember(index);

            end
        end
        function to_bladed(obj,template)

            % check for TowerLoading and add empty section if missing
            index_towerloading=template.findLine("<TowerLoading>",method="contains",error="returnEmpty");
            if isempty(index_towerloading)
                template.insertLines("</RunConfiguration>",["<TowerLoading>";"</TowerLoading>"])
            end

            % replate TowerLoading
            data=obj.match_bladed_nodes(template);
            data.pointloadfile_bladed=strrep(data.pointloadfile,"&","&amp;");

            I=height(data);
            for i=1:I
                data.block{i}=[...
                    "    <PointLoading>"
                    sprintf("      <PathOfDataFile>%s</PathOfDataFile>",data.pointloadfile_bladed(i));
                    "      <NumberOfComponents>Six</NumberOfComponents>"
                    "      <Direction>0</Direction>"
                    "      <StartTime>0</StartTime>"
                    "      <HeightOfImpact>0</HeightOfImpact>"
                    sprintf("      <MemberNumber>%i</MemberNumber>",data.BladedMemberID(i))
                    sprintf("      <DistanceAlongMember>%f</DistanceAlongMember>",data.DistanceAlongMember(i))
                    "    </PointLoading>"];

            end

            TowerLoading=["  <ActivateLoading>true</ActivateLoading>";
                "  <Loading>";
                vertcat(data.block{:});
                "  </Loading>";
                "  <ActivateBladeLoading>false</ActivateBladeLoading>";
                "  <BladeLoading />"];


            % overwrite TowerLoading block
            template.getXMLBlock("TowerLoading");
            template.replaceXMLBlock("TowerLoading",TowerLoading)

            
        end
    end
end