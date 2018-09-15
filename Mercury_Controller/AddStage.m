function AddStage(c)
% function AddStage(c)
FunctionName = 'Mercury_AddStage';
if(strmatch(FunctionName,c.dllfunctions))
	try
		[bRet,c] = calllib(c.libalias,FunctionName,c.ID,c);
	catch
		rethrow(lasterror);
	end
else
	error(sprintf('%s not found',FunctionName));
end
