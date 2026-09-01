classdef JONSWAPWaves < cassette.simulation.wave.IrregularWaves
    %REGULARWAVES Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Hs
        Tp
        gamma
        direction
        waveseed
        numberofcomponents
    end

    methods
        function obj = JONSWAPWaves(Hs,Tp,direction,inargs)
            arguments
                Hs (1,1) double {mustBePositive}
                Tp (1,1) double {mustBePositive}
                direction (1,1) double =0
                inargs.gamma (1,1) double = NaN
                inargs.waveseed (1,1) int32 = 1
                inargs.numberofcomponents (1,1) double = NaN
            end
                
            obj.Hs = Hs;
            obj.Tp = Tp;
            obj.direction = direction;
            if ~isnan(inargs.gamma)
                obj.gamma=inargs.gamma;
            end
            obj.waveseed = inargs.waveseed;
            if ~isnan(inargs.numberofcomponents)
                obj.numberofcomponents=inargs.numberofcomponents;
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

        function to_orcaflex(obj,template,inargs)
            arguments
                obj
                template
                inargs.WaveTrainNumber (1,1) double {mustBePositive,mustBeInteger} =1;
            end
            env=template.ofxmodel.environment;
            env.NumberOfWaveTrains=inargs.WaveTrainNumber;
            env.SelectedWaveIndex =inargs.WaveTrainNumber;


            env.WaveType='JONSWAP';
            env.WaveJONSWAPParameters='Partially specified';
            env.WaveDirection=obj.direction;
            env.WaveHs=obj.Hs;
            env.WaveGamma=obj.gamma;
            env.WaveTp=obj.Tp;
            env.UserSpecifiedRandomWaveSeeds='Yes';
            env.WaveSeed=obj.waveseed;
            
            if ~isempty(obj.numberofcomponents)
                env.WaveNumberOfComponents=obj.numberofcomponents;
            end
            env.WaveKinematicsCutoffDepth=env.SeabedOriginDepth-2;
        end

        % function to_bladed(obj,template)
        % end


    end
end