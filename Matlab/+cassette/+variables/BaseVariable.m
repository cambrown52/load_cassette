classdef BaseVariable < matlab.mixin.SetGetExactNames & matlab.mixin.Heterogeneous
    properties
        name
    end

    methods
        function obj = BaseVariable(name)
            arguments
                name (1,1) string
            end
            obj.name=name;
        end
    end
    methods (Sealed)
        function n=names(obj)
            n=arrayfun(@(x) x.name, obj);
        end
        function generate_combinations(obj)
            % add independent variables to table
            index=arrayfun(@(o)isa(o,'cassette.variables.IndepententVariable'),obj);
            if ~any(index)
                error('At least one Independent Variable is required to generate combinations.')
            end
            obj(index).generate_independent_combinations();

        end
        function n=number_of_combinations(obj)
            
            index=arrayfun(@(o)isa(o,'cassette.variables.IndepententVariable'),obj);
            n=unique([obj(index).number_of_combinations]);
            
            if length(n)>1
                error('Unexpected result. Multiple unique numbers of combinations from independent variables.')
            end
        end
        function t=to_table(obj)

            % add independent variables to table
            obj.generate_combinations();

            I=length(obj);
            t=table();
            for i=1:I
                t= obj(i).add_column(t);
            end
            
        end
    end

end