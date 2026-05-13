classdef RegularWaves < cassette.simulation.condition.BaseCondition
    %REGULARWAVES Summary of this class goes here
    %   Detailed explanation goes here

    properties
        H
        T
        direction
    end

    properties (Dependent)
        name
    end

    methods
        function obj = RegularWaves(T,H,direction)
            arguments
                T (1,1) double {mustBePositive}
                H (1,1) double {mustBePositive} = 2
                direction (1,1) double =0
            end
                
            obj.H = H;
            obj.T = T;
            obj.direction = direction;
        end

        function n=get.name(obj)
            n=sprintf("H%02.1fm_T%02.0s_dir%03.0fdeg",obj.H,obj.T,obj.direction);
        end

        function to_orcaflex(obj,template)
            env=template.ofxmodel.environment;
            env.NumberOfWaveTrains=1;
            env.WaveType="Airy";
            env.WaveDirection=obj.direction;
            env.WaveHeight=obj.H;
            env.WavePeriod=obj.T;
        end

        function to_bladed(obj,template)
            folder=fileparts(template.file);
            seafile=fullfile(folder,obj.name+".SEA");

            % determine filename
            if ~exist(folder,'dir')
                mkdir(folder)
            end
            cassette.Utils.Bladed.write_regular_seafile(seafile,obj.T,obj.H,obj.direction)

            template.replaceXMLProperty("SpectrumFilePath",seafile);
        end


    end
end