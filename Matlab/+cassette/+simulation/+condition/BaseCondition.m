classdef (Abstract) BaseCondition < matlab.mixin.Heterogeneous & matlab.mixin.SetGetExactNames & matlab.mixin.Copyable
    methods       
        function to_bladed(obj,template)
            error('not implemented in class %s',class(obj))
        end
        function to_orcaflex(obj,template)
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
                value=obj.(p(i));
                if isa(value,"cassette.simulation.condition.BaseCondition")
                    value=value.to_struct();
                end
                st.(p(i))=value;
            end
        end
        function p=independent_properties(obj)
            mc = metaclass(obj);
            plist = mc.PropertyList;

            % Names of properties that are NOT Dependent
            p = string({plist(~[plist.Dependent]).Name});
        end
        function tf=has_variables(obj)
            p=obj.independent_properties();
            I=length(p);
            tf=false;
            for i=1:I
                if isa(obj.(p(i)),"cassette.variables.BaseVariable")
                    tf=true;
                    break
                end
            end
        end

        function newobj=get_scalar_instance(obj,index)
            arguments
                obj (1,1) cassette.simulation.condition.BaseCondition
                index (1,1) double {mustBePositive, mustBeInteger}
            end
            O=length(obj);
            newobj=obj; %initialize list
            for o=1:O
                newobj(o)=copy(obj(o));
                p=newobj.independent_properties();
                I=length(p);
                for i=1:I
                    if isa(newobj(o).(p(i)),"cassette.variables.BaseVariable")
                        newobj(o).(p(i))=obj(o).(p(i)).get_value(index);
                    end
                end
            end

        end
    end
    methods (Sealed)
        function v=get_variables(obj)
            v=[];
            O=length(obj);
            for o=1:O
                p=obj(o).independent_properties();
                I=length(p);

                for i=1:I
                    prop=obj(o).(p(i));
                    if isa(prop,"cassette.variables.BaseVariable")
                        v=[v;prop];
                    end
                end
            end
        end
    end
end