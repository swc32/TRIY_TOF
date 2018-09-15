function MAC_START(c)
% function MAC_START(c)
FunctionName = 'Mercury_MAC_START';
if(strmatch(FunctionName,c.dllfunctions))
	try
		[bRet,c] = calllib(c.libalias,FunctionName,c.ID,c);
	catch
		rethrow(lasterror);
	end
else
	error(sprintf('%s not found',FunctionName));
end
