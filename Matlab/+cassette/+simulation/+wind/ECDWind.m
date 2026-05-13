classdef ECDWind < cassette.simulation.wind.BaseWind

    properties
        gust_time
        gust_sign 
        wind_speed_change (1,1) double = 15;
        wind_direction_change double {mustBeNonnegative}
    end

    methods
        function obj = ECDWind(initial_speed,gust_time,gust_sign,initial_direction,windshear,density,inargs)
            arguments
                initial_speed (1,1) double
                gust_time (1,1) double
                gust_sign (1,1) double {mustBeMember(gust_sign,[-1 1])} = 1
                initial_direction (1,1) double = 0
                windshear (1,1) double = 0
                density (1,1) double = 1.225
                inargs.wind_speed_change (1,1) double = NaN
                inargs.wind_direction_change (1,1) double = NaN
            end
            obj@cassette.simulation.wind.BaseWind(initial_speed,initial_direction,windshear,density)
            obj.gust_time=gust_time;
            obj.gust_sign=gust_sign;

            if ~isnan(inargs.wind_direction_change)
                obj.wind_direction_change=inargs.wind_direction_change;
            end
            if ~isnan(inargs.wind_speed_change)
                obj.wind_speed_change=inargs.wind_speed_change;
            end

        end
        function dir_amp=get.wind_direction_change(obj)
            if isempty(obj.wind_direction_change) || isnan(obj.wind_direction_change)
                if obj.speed<4
                    dir_amp=180;
                else
                    dir_amp=720/obj.speed;
                end
            else
                dir_amp=obj.wind_direction_change;
            end

        end
        function to_bladed(obj,template)

            template.WINDSEL=template.moduleECDWind(...
                obj.speed,...
                template.RCON.HEIGHT,...
                obj.direction*pi/180,...
                obj.gust_time,...
                obj.wind_speed_change,...
                obj.wind_direction_change*pi/180*obj.gust_sign);

            template.replaceProperty("WSHEAR",obj.shear)
        end

        
    end
end