function bConnected = IsConnected(c)
% function bConnected = IsConnected(c)
FunctionName = [c.libalias,'_IsConnected']; 
if(strmatch(FunctionName,c.dllfunctions))
	bConnected = libpointer('int32Ptr',0);
    bConnected = calllib(c.libalias,FunctionName,c.ID);
    
   
else
    error(sprintf('%s not found',FunctionName));
end