function iVal = qTNJ(c)
% function iVal = qTNJ(c)
FunctionName = 'Mercury_qTNJ';
if(strmatch(FunctionName,c.dllfunctions))
	iVal = 1;
	piValue = libpointer('int32Ptr',iVal);
	try
		[bRet,iVal] = calllib(c.libalias,FunctionName,c.ID,piValue);
	catch
		rethrow(lasterror);
	end
else
	error(sprintf('%s not found',FunctionName));
end
