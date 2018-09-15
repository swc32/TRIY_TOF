function szAnswer = ReceiveNonGCSString(c)
% function szAnswer = ReceiveNonGCSString(c)
FunctionName = 'Mercury_ReceiveNonGCSString';
if(strmatch(FunctionName,c.dllfunctions))
	szAnswer = blanks(1001);
	try
		[bRet,szAnswer] = calllib(c.libalias,FunctionName,c.ID,szAnswer,1000);
	catch
		rethrow(lasterror);
	end
else
	error(sprintf('%s not found',FunctionName));
end
