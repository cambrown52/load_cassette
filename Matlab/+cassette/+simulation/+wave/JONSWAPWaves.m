classdef JONSWAPWaves < cassette.simulation.condition.BaseCondition
    %REGULARWAVES Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Hs
        Tp
        gamma
        direction
        
    end

    methods
        function obj = JONSWAPWaves(Hs,Tp,direction,inargs)
            arguments
                Hs (1,1) double {mustBePositive}
                Tp (1,1) double {mustBePositive}
                direction (1,1) double =0
                inargs.gamma (1,1) double = NaN
            end
                
            obj.Hs = Hs;
            obj.Tp = Tp;
            obj.direction = direction;
            if ~isnan(inargs.gamma)
                obj.gamma=inargs.gamma;
            end

        end
        function g=get.gamma(obj)
            if ~isempty(obj.gamma)
                g=obj.gamma;
            else
                x=obj.Tp/sqrt(obj.Hs);
                if x<=3.6
                    g=5;
                elseif 5<x
                    g=1;
                else
                    g=exp(5.75-1.15*x);
                end
            end
        end

        % function n=get.name(obj)
        %     n=sprintf("H%02.1fm_T%02.0s_dir%03.0fdeg",obj.Hs,obj.Tp,obj.direction);
        % end

        function to_orcaflex(obj,template)
            env=template.ofxmodel.environment;
            env.NumberOfWaveTrains=1;
            env.WaveType='JONSWAP';
            env.WaveJONSWAPParameters='Partially specified';
            env.WaveDirection=obj.direction;
            env.WaveHs=obj.Hs;
            env.WaveGamma=obj.gamma;
            env.WaveTp=obj.Tp;
        end

        % function to_bladed(obj,template)
        % end


    end
end