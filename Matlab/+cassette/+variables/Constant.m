classdef Constant < cassette.variables.BaseVariable
    properties
        value (1,1) double {mustBeReal}
    end

    methods
        function obj = Constant(name,value)
            arguments
                name (1,1) string
                value (1,1) double {mustBeReal}
            end
            obj@cassette.variables.BaseVariable(name);
            obj.value = value;
        end
        function v=get_value(obj,index)
            v=obj.value;
        end
        function t=add_column(obj,t)
            t.(obj.name)(:)=obj.value;
        end
    end
end