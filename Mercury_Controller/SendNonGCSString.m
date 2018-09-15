function SendNonGCSString(c)
% function SendNonGCSString(c)
FunctionName = 'Mercury_SendNonGCSString';
if(strmatch(FunctionName,c.dllfunctions))
	try
		[bRet,c] = calllib(c.libalias,FunctionName,c.ID,c);
	catch
		rethrow(lasterror);
	end
else
	error(sprintf('%s not found',FunctionName));
end
