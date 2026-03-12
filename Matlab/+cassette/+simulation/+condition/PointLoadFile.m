classdef PointLoadFile < cassette.simulation.condition.BaseCondition

    properties
        filepath
        member_id
        distance_along_member
    end
    


    methods
        function obj = PointLoadFile(filepath,member_id,distance_along_member)
            arguments
                filepath (1,1) string
                member_id (1,1) double
                distance_along_member (1,1) double =0
            end
            obj.filepath=filepath;
            
            obj.member_id=member_id;
            obj.distance_along_member=distance_along_member;
            
        end


        function to_bladed(obj,template)

            % check for TowerLoading and add empty section if missing
            index_towerloading=template.findLine("<TowerLoading>",method="contains",error="returnEmpty");
            if isempty(index_towerloading)
                template.insertLines("</RunConfiguration>",["<TowerLoading>";"</TowerLoading>"])
            end

            % replate TowerLoading
            filepath=strrep(obj.filepath,"&","&amp;");

            TowerLoading=[...
                "  <ActivateLoading>true</ActivateLoading>";
                "  <Loading>";
                "    <PointLoading>";
                sprintf("      <PathOfDataFile>%s</PathOfDataFile>",filepath);
                "      <NumberOfComponents>Six</NumberOfComponents>";
                "      <Direction>0</Direction>";
                "      <StartTime>0</StartTime>";
                "      <HeightOfImpact>0</HeightOfImpact>";
                sprintf("      <MemberNumber>%i</MemberNumber>",obj.member_id);
                sprintf("      <DistanceAlongMember>%f</DistanceAlongMember>",obj.distance_along_member);
                "    </PointLoading>";
                "  </Loading>";
                "  <ActivateBladeLoading>false</ActivateBladeLoading>";
                "  <BladeLoading />"];

            % overwrite TowerLoading block
            template.getXMLBlock("TowerLoading");
            template.replaceXMLBlock("TowerLoading",TowerLoading)

        end
    end
    methods (Static)
        function write_bladed_free_decay_load_file(filepath,load,dof,ramp_time)


            time=[0; ramp_time; ramp_time+1];
            load6DOF=zeros(3,6);
            load6DOF(2,dof)=load;


            fid=fopen(filepath,"w");
            fprintf(fid,"NUMPOINTS\t%i\r\n",length(time));
            fprintf(fid,'%f\t%f\t%f\t%f\t%f\t%f\t%f\r\n',[time load6DOF]');
            fclose(fid);
        end
    end
end