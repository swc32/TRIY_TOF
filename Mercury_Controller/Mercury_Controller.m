function [c,notfound,warnings] = Mercury_Controller()
%Mercury_Controller controller class constructor
if nargin==0

    c.ControllerName = [];
    c.DLLName = [];
    c.ID = -1;
    c.IDN = 'not queried yet';
    c.NumberOfAxes = 0;
    if(exist('c:\programme\pi\gcstranslator\','dir')==7)
        c.DLLName=('c:\\programme\\pi\\gcstranslator\\PI_Mercury_GCS_DLL.dll');
    elseif(exist('c:\program files\pi\gcstranslator\','dir')==7)
        c.DLLName=('c:\\program files\\pi\\gcstranslator\\PI_Mercury_GCS_DLL.dll');
    end
    disp(sprintf('loading %s',c.DLLName));
    c.hfile = 'c:\\program files\\pi\\mercury\\mercury_gcs_dll\\PI_Mercury_GCS_DLL.h';
    fid1 = fopen(c.hfile,'r');
    winhfound = 0;
    while(~feof(fid1))
       s = fgetl(fid1);
       if(~isempty(strfind(s,'windows.h')))
           winhfound = 1;
       end
    end
    if(winhfound == 0)
        error(['Please insert #include "windows.h" into the PI_Mercury_GCS_DLL.h header file you use. '...
            ,'Otherwise BOOL will be interpreted wrong.']);

    end
    c.libalias = 'Mercury';
    % only load dll if it wasn't loaded before
    if(~libisloaded(c.libalias))
        [notfound_loc,warnings_loc] = loadlibrary (c.DLLName,c.hfile,'alias',c.libalias);
    end
    if(~libisloaded(c.libalias))
        error('DLL could not be loaded');
    else
        
        c.dllfunctions = libfunctions(c.libalias);

    end
    c = class(c,'Mercury_Controller');
    if(nargout==3)
        notfound = notfound_loc;
        warnings = warnings_loc;
    end
end