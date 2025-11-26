classdef BladedTemplate < cassette.Template
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here


    methods
        function m=interpretModule(obj,modulename)
            arguments
                obj
                modulename (1,1) string
            end
            m=obj.interpretBlock("MSTART "+modulename,"MEND");
        end


    end
    methods (Static)

        function block=blockTurbulentWind(wind_speed,reference_height,ti_u,ti_v,ti_w,wind_dir,wind_file)
            arguments
                wind_speed (1,1) double
                reference_height (1,1) double
                ti_u (1,1) double
                ti_v (1,1) double
                ti_w (1,1) double
                wind_dir (1,1) double
                wind_file (1,1) string
            end
            block=["MSTART WINDSEL"
                "WMODEL	3"
                "UBAR	 "+string(wind_speed)
                "REFHT	 "+string(reference_height)
                "TURBHTTYPE	1"
                "TI	"+string(ti_u)
                "TI_V	"+string(ti_v)
                "TI_W	"+string(ti_w)
                "WDIR	 "+string(wind_dir)
                "FLINC	 0"
                "WINDF	"+string(wind_file)
                "INTERPYZ	3"
                "CIRCWIND	1"
                "DIRAMP	0"
                "DIRSTIME	0"
                "DIRTIMEP	0"
                "DIRTYPE	F"
                "GUSTPROPAGATION	1"
                "MEND"];
        end
    end
end