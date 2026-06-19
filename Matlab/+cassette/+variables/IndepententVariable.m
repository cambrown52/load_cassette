classdef IndepententVariable < cassette.variables.BaseVariable
    properties
        values
    end
    properties (SetAccess = protected)
        caseValues
    end
    properties(Dependent)
        number_of_combinations
    end

    methods
        function obj = IndepententVariable(name,values)
            arguments
                name (1,1) string
                values (:,1) double {mustBeReal}
            end
            obj@cassette.variables.BaseVariable(name);
            obj.values=values;
        end
        function generate_independent_combinations(obj)
            arguments
                obj (:,1) cassette.variables.IndepententVariable
            end
            I=length(obj);
            
            t=obj(1).to_column();
            for i=2:I
                t=cassette.Utils.crossjoin(t,obj(i).to_column());
            end
            for i=1:I
                obj(i).caseValues = t.(obj(i).name);
            end
        end
        function N=get.number_of_combinations(obj)
            N=length(obj.caseValues);
        end
        function v=get_value(obj,index)
            arguments
                obj (1,1) cassette.variables.IndepententVariable
                index (1,1) double {mustBePositive, mustBeInteger}
            end
            mustBeLessThanOrEqual(index,obj.number_of_combinations)
            v=obj.caseValues(index);
        end
        function t=add_column(obj,t)
            t.(obj.name) = obj.caseValues;
        end
        function c=to_column(obj)
            c=table(obj.values,'VariableNames',obj.name);
        end
    end

end