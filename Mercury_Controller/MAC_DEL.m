function MAC_DEL(c)
% function MAC_DEL(c)
FunctionName = 'Mercury_MAC_DEL';
if(strmatch(FunctionName,c.dllfunctions))
	try
		[bRet,c] = calllib(c.libalias,FunctionName,c.ID,c);
	catch
		rethrow(lasterror);
	end
else
	error(sprintf('%s not found',FunctionName));
end
