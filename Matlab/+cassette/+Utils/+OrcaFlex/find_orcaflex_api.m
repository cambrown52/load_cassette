function [versions] = find_orcaflex_api(inargs)
arguments
    inargs.install_dirs (:,1) string = ["c:\Program Files (x86)\Orcina\OrcaFlex\"]
end


% find bladed folders
I=length(inargs.install_dirs);
versions=[];
for i=1:I
    if exist(inargs.install_dirs(i),"dir")
        ver=struct2table(dir(fullfile(inargs.install_dirs(i),"*")));
        ver(~ver.isdir,:)=[];
        ver(ismember(ver.name,[".", ".."]),:)=[];
        ver.name=string(ver.name);
        ver.folder=string(ver.folder);
        ver=ver(:,["name","folder"]);
        versions=[versions;ver];
    end
end
if isempty(versions)
    error("Could not find OrcaFlex API ")
end

versions.version=strip(versions.name);
versions.major=double(extractBefore(versions.version,'.'));
versions.minor=double(extractAfter(versions.version,'.'));

versions=sortrows(versions,["major", "minor"],"descend");


% find bladed executables
versions.API=fullfile(versions.folder,versions.name,"OrcFxAPI","MATLAB");
versions(~arrayfun(@(x)exist(x,"dir"),versions.API),:)=[];


