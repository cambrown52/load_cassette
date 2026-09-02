classdef PointMoment < cassette.simulation.condition.BaseCondition
    %POINTMOMENT undefined
    %   undefined

    properties
        body
        Mx
        My
        Mz
    end

    methods
        function obj = PointMoment(body,Mx,My,Mz)
            arguments
                body
                Mx
                My
                Mz
            end
            
            obj.body=body;
            obj.Mx=Mx;
            obj.My=My;
            obj.Mz=Mz;
        end

        function to_orcaflex(obj,template)
            b=template.ofxmodel(char(obj.body));
            b.NumberOfLocalAppliedLoads=0;
            b.NumberOfLocalAppliedLoads=1;
            UnitsConversionFactor=b.UnitsConversionFactor('FF.LL');
            b.LocalAppliedMomentX(1)=obj.Mx*UnitsConversionFactor;
            b.LocalAppliedMomentY(1)=obj.My*UnitsConversionFactor;
            b.LocalAppliedMomentZ(1)=obj.Mz*UnitsConversionFactor;
        end
    end
end