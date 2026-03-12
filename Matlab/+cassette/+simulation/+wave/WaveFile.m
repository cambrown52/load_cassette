classdef WaveFile < cassette.simulation.condition.BaseCondition
    %WAVEFILE Summary of this class goes here
    %   Detailed explanation goes here

    properties
        filepath
    end

    methods
        function obj = WaveFile(filepath)
            %WAVEFILE Construct an instance of this class
            %   Detailed explanation goes here
            obj.filepath = filepath;
        end
    end
    methods
        function to_bladed(obj,template)
            template.replaceXMLProperty("SpectrumFilePath",obj.filepath);
        end

    end
end