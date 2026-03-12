function tbl=structs2commontable(st)
% join multiple structs with differing fields to a common table. NaNs will
% be put in columns where the field was undefined.
 
% find all column names
col=cellfun(@fields,st,'UniformOutput',false);
col=unique(vertcat(col{:}));
 
% merge to a common table
st=cellfun(@(x)addmissingparams(x,col),st,'UniformOutput',false);
tbl=struct2table([st{:}]);
end
 
function st=addmissingparams(st,col)
missing_col=setdiff(col,fields(st));
J=length(missing_col);
for j=1:J
    st.(missing_col{j})=NaN;
end
end