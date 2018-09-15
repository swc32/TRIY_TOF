function Destroy( c )
%DESTROY C843_Controller object and unload library
if(IsConnected(c))
    c = CloseConnection(c);
end
if(libisloaded(c.libalias))
    unloadlibrary (c.libalias);
end
clear c;