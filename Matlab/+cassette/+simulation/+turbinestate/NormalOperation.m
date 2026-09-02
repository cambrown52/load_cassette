classdef NormalOperation < cassette.simulation.turbinestate.BaseState
    %OPERATION Summary of this class goes here
    %   Detailed explanation goes here

    properties

    end
    properties (Hidden)
        default_initialpitchangle = 0
    end

    methods
        function obj = NormalOperation(yaw,initialpitchangle)
            arguments
                yaw (1,1)
                initialpitchangle (1,1) =NaN
            end
            obj@cassette.simulation.turbinestate.BaseState(yaw,initialpitchangle)
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

            % set initial pitch angle
            if ~isempty(obj.pitchangle)
                error('Varying from default initial pitch angle is not yet implemented for Bladed.')
            end
        end
       function to_orcaflex(obj,template)
            template.ofxnacelle.InitialRotation3=obj.yaw;
            wtg=template.ofxturbine;
            wtg.IncludedInduction="Axial and tangential";
            wtg.GeneratorMode="Specified torque";
            wtg.GeneratorTorqueController=template.ofxcontroller.name;
            wtg.PitchController=template.ofxcontroller.name;
            wtg.PitchControlMode='Individual';
            if ~isempty(obj.pitchangle)
                initialpitchangle=obj.pitchangle;
            else
                initialpitchangle=obj.default_initialpitchangle;
            end
            for i=1:wtg.BladeCount
                wtg.InitialPitch(i)=initialpitchangle;
            end
            wtg.InitialRotorAngVel=.3;
        end
    end
end