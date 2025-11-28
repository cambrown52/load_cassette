function versions=find_bladed(inargs)
arguments
    inargs.install_dirs (:,1) string = ["C:\DNV\"; "C:\DNV GL\"]
end


% find bladed folders
I=length(inargs.install_dirs);
versions=[];
for i=1:I
    if exist(inargs.install_dirs(i),"dir")
        ver=struct2table(dir(fullfile(inargs.install_dirs(i),"Bladed*")));
        ver(~ver.isdir,:)=[];
        ver.name=string(ver.name);
        ver.folder=string(ver.folder);
        ver=ver(:,["name","folder"]);
        versions=[versions;ver];
    end
end

versions.version=strip(extractAfter(versions.name,"Bladed"));

% find bladed executables
versions.dtbladed_exe=fullfile(versions.folder,versions.name,"dtbladed.exe");
versions(~arrayfun(@(x)exist(x,"file"),versions.dtbladed_exe),:)=[];

% check if bladed GUI exists
versions.bladed_m72_exe=fullfile(versions.folder,versions.name,"Bladed_m72.exe");
if ~all(arrayfun(@(x)exist(x,"file"),versions.bladed_m72_exe))
    warning("Bladed_m72.exe not found in folders:%s",sprintf("\n%s",versions.bladed_m72_exe(~arrayfun(@(x)exist(x,"file"),versions.bladed_m72_exe))))
end

