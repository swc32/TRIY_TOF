function RemoveStage(c)
% function RemoveStage(c)
FunctionName = 'Mercury_RemoveStage';
if(strmatch(FunctionName,c.dllfunctions))
	try
		[bRet,c] = calllib(c.libalias,FunctionName,c.ID,c);
	catch
		rethrow(lasterror);
	end
else
	error(sprintf('%s not found',FunctionName));
end
