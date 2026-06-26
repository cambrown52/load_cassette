function [variables]=from_table(T)

    varnames=T.Properties.VariableNames;
    rowid=cassette.variables.IndependentVariable(1:height(T))';


    variables=[rowid];
    for i=1:length(varnames)
        vname=varnames{i};

        v=cassette.variables.DependentVariable(vname,rowid,@(id) T{id,vname});
        variables=[variables;v];
    end