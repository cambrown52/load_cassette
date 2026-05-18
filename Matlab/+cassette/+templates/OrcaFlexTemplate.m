classdef OrcaFlexTemplate < cassette.templates.Template
    %ORCAFLEXTEMPLATE Summary of this class goes here
    %   Detailed explanation goes here
    properties
        ofxmodel
    end
    properties (Dependent)
        ofxturbine
        rotor_diameter
    end
    properties (SetAccess=private)
        hub_height
    end
    methods
        function m=get.ofxmodel(obj)
            if isempty(obj.ofxmodel)
                m=ofxModel(obj.file);
                obj.ofxmodel=m;
            else
                m=obj.ofxmodel;
            end
        end
        function new_obj = new_case(obj,name,folder)
            arguments
                obj
                name (1,1) string
                folder (1,1) string
            end

            new_obj=copy(obj);
            new_obj.name=name;
            new_obj.file=fullfile(folder,name+".dat");
            new_obj.ofxmodel=ofxModel(obj.file);
        end


        function write_(obj)
            arguments
                obj (1,1) cassette.templates.OrcaFlexTemplate
            end
            % write contents into file
            obj.ofxmodel.SaveData(obj.file)
        end
        function merge(obj,simulation,outputfolder)
            error("not implemented")
        end
        function wtg=get.ofxturbine(obj)
            obj=obj.ofxmodel.objects;
            obj_type=cellfun(@(obj)obj.type,obj);
            obj_class=string(cellfun(@class,obj));
            wtg=obj(obj_type==ofx.otTurbine);
            if length(wtg)>1
                error("too many turbines found in model")
            else
                wtg=wtg{1};
            end
        end
        function D=get.rotor_diameter(obj)
            wtg=obj.ofxturbine;
            D=2*(wtg.HubRadius+max(wtg.BladeSectionCumulativeLength));
        end
        function hh=get.hub_height(obj)
            if isempty(obj.hub_height)
  
                %create object method
                hub=obj.ofxmodel.CreateObject(ofx.otConstraint,"hub_center");
                hub.Connection=obj.ofxturbine.Name;
                hub.InFrameInitialX=0;
                hub.InFrameInitialY=0;
                hub.InFrameInitialZ=0;
                hub.Connection="Fixed";
                hh=hub.InFrameInitialZ;
                obj.ofxmodel.DestroyObject(hub);

                obj.hub_height=hh;
            else
                hh=obj.hub_height;
            end


        end
    end

    % methods (Static)
    %     function obj=default()
    %         [mfiledir,~,~]=fileparts(mfilename);
    %         obj=cassette.templates.OrcaFlexTemplate(fullfile(mfiledir,"OrcaFlexDefault.yml"));
    %     end
    % end
end