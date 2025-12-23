function prj2dtbladedin(prjfile,outputdir,inargs)
arguments
    prjfile (1,1) string {mustBeFile}
    outputdir (1,1) string = cd 
    inargs.bladed_version (1,1) string = "4.17"
end

% check bladed version
bladed_versions=cassette.Bladed.find_bladed();
bladed=bladed_versions(bladed_versions.version==inargs.bladed_version,:);
if isempty(bladed)
    error("Bladed version %s not found. Available versions: %s",inargs.bladed_version,sprintf("\n%s",bladed_versions.version(:)))
end

% convert prj file to absolute path
prjabspath=resolvePath(prjfile);
[~,prjstem,~]=fileparts(prjfile);

% create run command
run_command=sprintf('"%s" -Prj "%s" -RunDir "%s" -ResultsPath "%s"',...
    bladed.bladed_m72_exe,...
    prjabspath,...
    outputdir,...
    fullfile(outputdir,prjstem)...
    );

% execute run command
fprintf("Running command:\n%s\n\n",run_command);
[status,cmdout] = dos(run_command);
fprintf("status: %s\n",string(status))
fprintf("output:\n%s\n",cmdout)
end

function fullpath = resolvePath(filename)
  file=java.io.File(filename);
  if file.isAbsolute()
      fullpath = filename;
  else
      fullpath = char(file.getCanonicalPath());
  end
  if file.exists()
      return
  else
      error('resolvePath:CannotResolve', 'Does not exist or failed to resolve absolute path for %s.', filename);
  end
end