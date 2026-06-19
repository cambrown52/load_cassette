classdef SteadyWind < cassette.simulation.wind.BaseWind

    properties
    end

    methods
        function obj = SteadyWind(speed,direction,windshear,density)
            arguments
                speed (1,1) 
                direction (1,1)  = 0
                windshear (1,1)  = 0
                density (1,1)  = 1.225
            end
            obj@cassette.simulation.wind.BaseWind(speed,direction,windshear,density)
        end
        function to_bladed(obj,template)
            template.WINDSEL=template.moduleSteadyWind(obj.speed,template.RCON.HEIGHT,obj.direction*pi/180);
            template.replaceProperty("WSHEAR",obj.shear)
        end
        function to_orcaflex(obj,template)
            env=template.ofxmodel.environment;

            env.WindType='Constant';
            env.WindSpeed=obj.speed;
            env.WindDirection=obj.direction;

            if obj.shear==0
                env.VerticalWindVariationFactor='~';
            else
                hh=template.hub_height;
                D=template.rotor_diameter;
                
                z=sort(unique([0:10:hh-D/2 hh+1.1*(-D/2:D/11:D/2)]));
                factor=(z./hh).^obj.shear;
                
                shear=template.ofxmodel.CreateObject(ofx.otVerticalVariationFactor);
                shear.Name=sprintf("Power Law Shear hh=%fm alpha=%f",hh,obj.shear);
                shear.IndependentValue=z;
                shear.DependentValue=factor;

                env.VerticalWindVariationFactor=shear.Name;

            end
            

            % input density converted to model units
            env.AirDensity=obj.density/1000*env.UnitsConversionFactor('MM.LL^-3');

        end

        
    end
end