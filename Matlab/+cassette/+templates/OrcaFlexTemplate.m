classdef OrcaFlexTemplate < cassette.templates.Template
    %ORCAFLEXTEMPLATE Summary of this class goes here
    %   Detailed explanation goes here
    properties
        ofxmodel
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

        function write_(obj)
            arguments
                obj (1,1) cassette.templates.OrcaFlexTemplate
            end
            % write contents into file
            obj.ofxmodel.SaveData(obj.file)
        end
    end

    % methods (Static)
    %     function obj=default()
    %         [mfiledir,~,~]=fileparts(mfilename);
    %         obj=cassette.templates.OrcaFlexTemplate(fullfile(mfiledir,"OrcaFlexDefault.yml"));
    %     end
    % end
end