classdef Case
    %SIMULATION Summary of this class goes here
    %   Detailed explanation goes here

    properties
        name 
        wind
        wave
        condition

    end

    methods
        function obj = Case(name,inargs)
            arguments
                name (1,1) string
                inargs.wind

            end
            obj.name=name;
        end

       
    end
end