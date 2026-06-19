classdef DependentVariable < cassette.variables.BaseVariable
    properties
        inputs (:,1) cassette.variables.BaseVariable
        equation (1,1) 
    end
    properties (Dependent)
        caseValues
    end

    methods
        function obj = DependentVariable(name,inputs,equation)
            arguments
                name (1,1) string
                inputs (:,1) cassette.variables.BaseVariable
                equation (1,1) function_handle
            end
            obj@cassette.variables.BaseVariable(name);
            obj.inputs = inputs;
            obj.equation = equation;
        end
        function v=get.caseValues(obj)
            caseValues=horzcat( obj.inputs.caseValues);
            v=arrayfun(obj.equation,caseValues);
        end
        function v=get_value(obj,index)
            arguments
                obj (1,1) cassette.variables.DependentVariable
                index (1,1) double {mustBePositive, mustBeInteger}
            end
            
            caseValues=horzcat( obj.inputs.get_value(index));
            v=arrayfun(obj.equation,caseValues);
        end
        function t=add_column(obj,t)
            t.(obj.name) = obj.caseValues;
        end
    end
end