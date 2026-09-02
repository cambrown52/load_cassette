classdef WindSwellWaves < cassette.simulation.wave.IrregularWaves

    properties
        windsea
        swellsea
    end

    methods
        function obj = WindSwellWaves(windsea,swellsea)
            arguments
                windsea (1,1) cassette.simulation.wave.JONSWAPWaves
                swellsea (1,1) cassette.simulation.wave.JONSWAPWaves
            end
            %   undefined
            obj.windsea=windsea;
            obj.swellsea=swellsea;

        end
        function to_orcaflex(obj,template)
           obj.windsea.to_orcaflex(template,WaveTrainNumber=1)
           obj.swellsea.to_orcaflex(template,WaveTrainNumber=2)

        end
    end
end