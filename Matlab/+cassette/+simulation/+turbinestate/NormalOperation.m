classdef NormalOperation < cassette.simulation.turbinestate.BaseState
    %OPERATION Summary of this class goes here
    %   Detailed explanation goes here

    properties

    end

    methods
        function obj = NormalOperation(yaw)
            obj@cassette.simulation.turbinestate.BaseState(yaw)
        end
    end
    methods

        function to_bladed(obj,template)
            arguments
                obj
                template cassette.templates.BladedTemplate
            end
            % set turbine state to operational in both places in IN file
            template.replaceProperty("CALCN",10)

            index_runconfig=template.findLine("<RunConfiguration>",method="contains");
            template.replaceXMLProperty("Calculation",10,after_index=index_runconfig)

            % set yaw error
            template.replaceProperty("INIMD",obj.yaw*pi/180)
        end
       function to_orcaflex(obj,template)
            template.ofxnacelle.InitialRotation3=obj.yaw;
            wtg=template.ofxturbine;
            wtg.IncludedInduction="Axial and tangential";
            wtg.GeneratorMode="Specified torque";
            wtg.GeneratorTorqueController=template.ofxcontroller.name;
            wtg.PitchController=template.ofxcontroller.name;
            wtg.InitialRotorAngVel=.3;
        end
    end
end