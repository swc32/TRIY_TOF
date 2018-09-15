function szAnswer = TranslateError(c,errnum)
% function szAnswer = TranslateError(c,errnum)
FunctionName = 'Mercury_TranslateError';
if(strmatch(FunctionName,c.dllfunctions))
	szAnswer = blanks(1001);
	try
		[bRet,szAnswer] = calllib(c.libalias,FunctionName,errnum,szAnswer,1000);
	catch
		rethrow(lasterror);
	end
else
	error(sprintf('%s not found',FunctionName));
end
