function c = Connect(c,pciID)
% function c = Connect(c,pciID)
FunctionName = [c.libalias,'_Connect']; 
% foundit = cellfun(@(x) (strcmp(x,FunctionName)),c.dllfunctions,'UniformOutput',true);
if(strmatch(FunctionName,c.dllfunctions))
    c.ID = calllib(c.libalias,FunctionName,pciID);
    if(c.ID<0)
        error('Not connected');
    end
    c = InitializeController(c);
   
else
    error(sprintf('%s not found',FunctionName));
end