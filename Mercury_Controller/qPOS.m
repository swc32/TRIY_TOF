function dValues = qPOS(c,szAxes)
% function dValues = qPOS(c,szAxes)
FunctionName = 'Mercury_qPOS';
if(strmatch(FunctionName,c.dllfunctions))
	if(nargin==1)
		szAxes = '';
	end
	len = length(szAxes);
	if(len == 0)
			len = c.NumberOfAxes;
	end
	dValues = zeros(len,1);
	pdValues = libpointer('doublePtr',dValues);
	try
		[ret,szAxes,dValues] = calllib(c.libalias,FunctionName,c.ID,szAxes,pdValues);
	catch
		rethrow(lasterror);
	end
else
	error(sprintf('%s not found',FunctionName));
end
