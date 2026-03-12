classdef (Abstract) BaseCondition < matlab.mixin.Heterogeneous & matlab.mixin.SetGetExactNames
    methods
        function to_bladed(obj,template)
            error('not implemented in class %s',class(obj))
        end
    end
    methods
        function st=to_struct(obj)
            p=string(properties(obj));
            I=length(p);
            st=struct();
            st.ObjectType=string(class(obj));
            for i=1:I
                st.(p(i))=obj.(p(i));
            end
        end
    end
end