classdef fileset < matlab.mixin.SetGetExactNames

    properties
        filepath
        props
    end
    properties (SetAccess=private,Hidden)
        propnames_ (:,1) string
    end

    methods
        function obj = fileset(filepath,props)
            arguments
                filepath (1,1) string% {mustBeFile}
                props (1,1) struct = struct()
            end
            obj.filepath=filepath;
            obj.props=props;
        end
        function propnames=get.propnames_(obj)
            if isempty(obj.propnames_)
                propnames=string(fields(obj.props));
                obj.propnames_=propnames;
            else
                propnames=obj.propnames_;
            end
        end
        function out=propnames(obj)
            propnames_=arrayfun(@(obj_i)get(obj_i,"propnames_"),obj,UniformOutput=false);
            out=unique([propnames_{:}]);
        end
        function addProp(obj,propname,value)
            arguments
                obj (:,1)
                propname (1,1) string {mustBeValidVariableName}
                value (:,1)
            end
            if length(obj)~=length(value)
                error("Length of fileset is not equal to the length of the input data.")
            end


        end
        function out=getProp(obj,propname,inargs)
            arguments
                obj
                propname (1,1) string {mustBeValidVariableName}
                inargs.default (1,1) = missing
            end
            if ~ismember(propname,obj.propnames)
                error("Property '%s' not found in fileset. Available Properties:%s",...
                    propname,...
                    sprintf('\n%s',obj.propnames))
            end
            O=length(obj);
            out=cell(O,1);
            for o=1:O
                out{o}=obj(o).getProp_(propname,inargs.default);
            end
            out=vertcat(out{:});
        end
        function [filtered_obj]=filter(obj,propname,value,inargs)
            arguments
                obj
                propname (1,1) string
                value (1,1)
                inargs.function = @eq
            end
            index=inargs.function(obj.getProp(propname),value);
            if ~any(index)
                error("No files pass filter of %s=%s",propname,string(value))
            end
            filtered_obj=obj(index);
        end
        function t=to_table(obj)

            function st=addmissingparams(st,col)
                missing_col=setdiff(col,fields(st));
                J=length(missing_col);
                for j=1:J
                    st.(missing_col{j})=NaN;
                end
            end

            % merge to a common table
            st={obj.props};
            propnames=obj.propnames();
            st=cellfun(@(x)addmissingparams(x,propnames),st,'UniformOutput',false);
            t=struct2table([st{:}]);
            t.filepath=vertcat(obj.filepath);
            t=movevars(t,"filepath","Before",1);
        end
 


        function disp(obj)
            fprintf("cassette fileset\nlength %i\n",length(obj))
            disp(obj.to_table())
        end
    end
    methods (Hidden)
        function [value]=getProp_(obj,propname,default)
            arguments
                obj (1,1)
                propname (1,1) string
                default (1,1) = missing
            end
            if ismember(propname,obj.propnames_)
                value=obj.props.(propname);
            else
                value=default;
            end
        end
    end
    methods (Static)
        function fs=from_table(t,inargs)
            arguments
                t
                inargs.filepath_variable="filepath"
            end
            if ~ismember(inargs.filepath_variable,t.Properties.VariableNames)
                error("table must contain a 'filepath' column, or the filepath column name must be specified via input from_table(...,'filepath_variable','<filepath_column_name>').\nTable column names:%s",...
                    sprintf('\n%s',t.Properties.VariableNames{:}))
            end
            filepath=t{:,inargs.filepath_variable};
            t(:,inargs.filepath_variable)=[];
            props=table2struct(t);
            fs=arrayfun(@(f,p)cassette.Utils.fileset(f,p),filepath,props);
        end

    end
end