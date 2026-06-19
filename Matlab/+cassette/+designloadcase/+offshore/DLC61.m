classdef DLC61 < cassette.designloadcase.offshore.BaseDLC
    methods
        function obj = DLC61(windspeed,winddirection,waveheight,waveperiod,currentspeed)
            arguments
                psf (1,1) double {mustBePositive} = 1.35
            end
            obj@cassette.designloadcase.offshore.BaseDLC("DLC61", 1.35);
        end
    end
end