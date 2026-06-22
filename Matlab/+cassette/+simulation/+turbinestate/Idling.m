classdef Idling < cassette.simulation.turbinestate.BaseState
    %OPERATION Summary of this class goes here
    %   Detailed explanation goes here


    properties (Hidden)
        default_idlingpitchangle = 90
    end

    methods
        function obj = Idling(yaw,idlingpitchangle)
            arguments
                yaw
                idlingpitchangle (1,1) double =NaN
            end
            obj@cassette.simulation.turbinestate.BaseState(yaw,idlingpitchangle)
        end
    end
    methods

        function to_bladed(obj,template)
            arguments
                obj
                template cassette.templates.BladedTemplate
            end
            % set turbine state to operational in both places in IN file
            template.replaceProperty("CALCN",14)

            index_runconfig=template.findLine("<RunConfiguration>",method="contains");
            template.replaceXMLProperty("Calculation",14,after_index=index_runconfig)

            % set yaw error
            template.replaceProperty("INIMD",obj.yaw*pi/180)

            % set idling pitch angle
            if ~isempty(obj.pitchangle)
                error('Varying from default idling pitch angle is not yet implemented for Bladed.')
            end
        end
        function to_orcaflex(obj,template)
            template.ofxnacelle.InitialRotation3=obj.yaw;
            template.ofxturbine.GeneratorMode="Specified torque";
            template.ofxturbine.GeneratorTorqueController=0;
            template.ofxturbine.PitchController="(none)";
            template.ofxturbine.PitchControlMode='Common';
            if ~isempty(obj.pitchangle)
                template.ofxturbine.InitialPitch(1)=obj.pitchangle;
            else
                template.ofxturbine.InitialPitch(1)=obj.default_idlingpitchangle;
            end
            template.ofxturbine.IncludedInduction="None";
        end
    end
end