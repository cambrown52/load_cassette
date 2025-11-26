function writecaselist(template_file,caselist,outputfolder,inargs)
arguments
    template_file (1,1) string {mustBeFile}
    caselist table
    outputfolder (1,1) string {mustBeFolder}="."
    inargs.outputextension (1,1) string = ".yml"
    inargs.tagstartdelimiter="{"
    inargs.tagenddelimiter="}"
    inargs.mkdir=false
end


template=fileread(template_file);
tags=extractBetween(template,inargs.tagstartdelimiter,inargs.tagenddelimiter);
J=length(tags);
if J==0
    error('No tags found in template %s',template_file)
end
if ~ismember(tags,caselist.Properties.VariableNames)
    missing=setdiff(tags,caselist.Properties.VariableNames);
    error('The following tags in template are missing in caselist:\n%s',sprintf("\n%s",missing{:}))
end
if ~ismember("name",caselist.Properties.VariableNames)
    error('caselist needs a "name" column to specify the output file name')
end

I=height(caselist);
for i=1:I
    % determine filename
    filename=fullfile(outputfolder,string(caselist{i,'name'})+inargs.outputextension);
    fprintf("[%i] writing:\t%s\n",i,filename)
    if inargs.mkdir && ~exist(fileparts(filename),'dir')
        mkdir(fileparts(filename))
    end
    
    % fill template
    contents=template;
    for j=1:J
        contents=replace(contents,inargs.tagstartdelimiter+tags(j)+inargs.tagenddelimiter,string(caselist{i,tags(j)}));
    end

    % write contents into file
    fid=fopen(filename,'w+');
    fprintf(fid,'%s',contents);
    fclose(fid);
end


