function add_ofxAPI_to_path(inargs)
arguments
    inargs.version (1,1) string = "latest"
end
versions=cassette.Utils.OrcaFlex.find_orcaflex_api();
if inargs.version=="latest"
    API=versions.API(1);
else
    index=find(versions.version==inargs.version);
    if isempty(index)
        error("OrcaFlex API Version %s not found. Available versions:%s",inargs.version,sprintf("\n%s",versions.version))
    end
    API=versions.API(index);
end

addpath(API)
    
end