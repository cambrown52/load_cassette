classdef TurbulentWind < cassette.simulation.wind.BaseWind

    properties
        TIu
        relativeTIv (1,1) double {mustBeBetween(relativeTIv,0,1)} = 0.8
        relativeTIw (1,1) double {mustBeBetween(relativeTIw,0,1)} = 0.5
        file
    end
    properties (Dependent)
        TIv
        TIw
    end

    methods
        function obj = TurbulentWind(speed,TIu,file,direction,shear,density)
            arguments
                speed (1,1) double
                TIu (1,1) double {mustBeGreaterThan(TIu,.5)}
                file (1,1) string
                direction (1,1) double = 0
                shear (1,1) double =0
                density (1,1) double = 1.225
            end
            
            obj@cassette.simulation.wind.BaseWind(speed,direction,shear,density)
            obj.TIu=TIu;
            obj.file=file;
        end
        function t=get.TIv(obj)
            t=obj.TIu*obj.relativeTIv;
        end
        function set.TIv(obj,t)
            obj.relativeTIv=t/obj.TIu;
        end
        function t=get.TIw(obj)
            t=obj.TIu*obj.relativeTIw;
        end
        function set.TIw(obj,t)
            obj.relativeTIw=t/obj.TIu;
        end
    end

    methods
        function to_bladed(obj,template)
            template.WINDSEL=template.moduleTurbulentWind(obj.speed,template.RCON.HEIGHT,obj.TIu/100,obj.TIv/100,obj.TIw/100,obj.direction,obj.file);
            template.replaceProperty("WSHEAR",obj.shear)
        end

    end
end