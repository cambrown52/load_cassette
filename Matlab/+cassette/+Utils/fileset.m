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
        function filepath=match(obj,data,inargs)
            arguments
                obj
                data table
                inargs.fileset_keys = missing
                inargs.data_keys = missing
            end
            if ismissing(inargs.data_keys)
                inargs.data_keys=data.Properties.VariableNames;
            end
            if ismissing(inargs.fileset_keys)
                inargs.fileset_keys=inargs.data_keys;
            end

            if ~all(ismember(inargs.data_keys,data.Properties.VariableNames))
                error('Right Keys not found in the data table to match:\n%s',sprintf("%s\n",setdiff(inargs.data_keys,data.Properties.VariableNames)))
            end
            if ~all(ismember(inargs.fileset_keys,obj.propnames))
                error('Left Keys not found in the fileset:\n%s',sprintf("%s\n",setdiff(inargs.fileset_keys,obj.propnames)))
            end

            % match wind files from available files
            fileset_data=obj.to_table;
            data.rowid=(1:height(data))';

            if height(unique(data(:,inargs.data_keys))) == height(data)
                %each row of data table is unique, only one match can be made
                matches=outerjoin(data,fileset_data,"LeftKeys",inargs.data_keys,"RightKeys",inargs.fileset_keys,"MergeKeys",true,"Type","left");%,"LeftVariables",["rowid",],"RightVariables",["filepath",]);
                matches=sortrows(matches,"rowid");

                % if multiple matches were available, keep only the first match
                if height(matches)>height(data)
                    matches.matchid=(1:height(matches))';
                    keepmatch=splitapply(@(id)min(id),matches.matchid,matches.rowid);
                    matches=matches(ismember(matches.matchid,keepmatch),:);
                    matches.matchid=[];
                end
            else

                [data.groupid,groups]=findgroups(data(:,inargs.data_keys));
                groups.groupid=(1:height(groups))';

                options=outerjoin(groups,fileset_data,"LeftKeys",inargs.data_keys,"RightKeys",inargs.fileset_keys,"MergeKeys",true,"Type","left");%,"LeftVariables",["rowid",],"RightVariables",["filepath",]);
                options=sortrows(options,"groupid");

                matches=data;
                matches.filepath(:)=string(missing);
                for groupid=1:height(groups)
                    groupoptions=options(options.groupid==groupid,:);
                    rowindex=matches.groupid==groupid;
                    
                    Nrows=sum(rowindex);
                    Noptions=height(groupoptions);

                    matchindex=repmat((1:Noptions)',ceil(Nrows/Noptions),1);
                    matchindex=matchindex(1:Nrows);

                    matches.filepath(rowindex)=groupoptions.filepath(matchindex);
                end
            end

            filepath=matches.filepath;
            if any(ismissing(filepath))
                warning("not all rows of table were matched with a file from fileset")
            end

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