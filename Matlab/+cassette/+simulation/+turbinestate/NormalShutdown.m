classdef NormalShutdown < cassette.simulation.turbinestate.BaseState
    %OPERATION Summary of this class goes here
    %   Detailed explanation goes here

    properties
        stoptime
    end

    methods
        function obj = NormalShutdown(yaw,stoptime)
            obj@cassette.simulation.turbinestate.BaseState(yaw)
            obj.stoptime=stoptime;
        end
    end
    methods

        function to_bladed(obj,template)
            arguments
                obj
                template cassette.templates.BladedTemplate
            end
            % set turbine state to operational in both places in IN file
            template.replaceProperty("CALCN",11)

            index_runconfig=template.findLine("<RunConfiguration>",method="contains");
            template.replaceXMLProperty("Calculation",11,after_index=index_runconfig)

            % set yaw error
            template.replaceProperty("INIMD",obj.yaw*pi/180)

            %
            template.replaceProperty("T_STOP",obj.stoptime)
        end
    end
end