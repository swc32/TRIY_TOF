function display(c)
disp('Mercury_Controller class object');
disp(sprintf('ID: %d',c.ID));
disp(sprintf('IDN: %s',c.IDN));
if(c.NumberOfAxes>1)
    disp(sprintf('%d possible axes',c.NumberOfAxes));
else
    disp(sprintf('%d possible axis',c.NumberOfAxes));
end
iErr = qERR(c);
if(iErr~=0)
    disp(sprintf('Error %d occured:\n%s',iErr,TranslateError(c,iErr)));
end
    