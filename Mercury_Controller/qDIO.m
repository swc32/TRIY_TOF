function iValues = qDIO(c,szAxes)
% function iValues = qDIO(c,szAxes)
FunctionName = 'Mercury_qDIO';
if(strmatch(FunctionName,c.dllfunctions))
	if(nargin==1)
		szAxes = '';
	end
	len = length(szAxes);
	if(len == 0)
			len = c.NumberOfAxes;
	end
	iValues = zeros(len,1);
	piValues = libpointer('int32Ptr',iValues);
	try
		[ret,szAxes,iValues] = calllib(c.libalias,FunctionName,c.ID,szAxes,piValues);
	catch
		rethrow(lasterror);
	end
else
	error(sprintf('%s not found',FunctionName));
end
