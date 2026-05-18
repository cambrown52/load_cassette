classdef NoWaves < cassette.simulation.condition.BaseCondition
    %WAVEFILE Summary of this class goes here
    %   Detailed explanation goes here
    properties
        filename
    end

    methods
        function obj = NoWaves(inargs)
            arguments
                inargs.filename (1,1) string = "stillwater.SEA"
            end
            obj.filename=inargs.filename;
        end
    end
    methods
        function to_bladed(obj,template)
            folder=fileparts(template.file);
            seafile=fullfile(folder,obj.filename);

            % determine filename
            if ~exist(folder,'dir')
                mkdir(folder)
            end
            
            contents=["source: SEAFileGenerator.exe, Regular: H=0m, T=10s, theta=0deg"
                "identifier: 2025-07-09 09:51"
                "duration: 0"
                "funit: Hz"
                "dunit: rad"
                "dconv: naut"
                "seed: 1752116010"
                "amp method: det"
                "phase method: rnd"
                "dir method: det"
                "components:"
                "0.1,0,0,0"];
            
            
            fid=fopen(seafile,"w");
            fprintf(fid,"%s\r\n",contents);
            fclose(fid);

            template.replaceXMLProperty("SpectrumFilePath",seafile);
        end
        function to_orcaflex(obj,template)
            env=template.ofxmodel.environment;
            env.NumberOfWaveTrains=1;
            env.WaveType="Airy";
            env.WaveDirection=0;
            env.WaveHeight=0;
            env.WavePeriod=10;

        end

    end
end