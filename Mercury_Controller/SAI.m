function szAnswer = SAI(c,s1,s2)
% function szAnswer = SAI(c,s1,s2)
FunctionName = 'Mercury_SAI';
if(strmatch(FunctionName,c.dllfunctions))
	r1 = blanks(1001);
	r2 = blanks(1001);
	try
		[bRet,r1,r2] = calllib(c.libalias,FunctionName,c.ID,s1,s2);
	catch
		rethrow(lasterror);
	end
else
	error(sprintf('%s not found',FunctionName));
end
