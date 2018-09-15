% Load the Mercury GCS DLL
loadlibrary 'PI_Mercury_GCS_DLL.dll'
% Connect to the controller on COM 1 with 9600 baud
ID = calllib('PI_Mercury_GCS_DLL','Mercury_ConnectRS232',4,9600)
% pop up a window showing all accessible functions
libfunctionsview('PI_Mercury_GCS_DLL')
% call the "show identification" command, with the id, an empty string and
% the length of this string as parameters
[a,b] = calllib('PI_Mercury_GCS_DLL','Mercury_qIDN',ID,blanks(100),100)
[a,axes] = calllib('PI_Mercury_GCS_DLL','Mercury_qSAI_ALL',ID,blanks(100),100)
% connect the M-403.62s stage to axis
axis = axes(1);
[a] = calllib('PI_Mercury_GCS_DLL','Mercury_CST',ID,axis,'M-403.62s')
% query the connected stages
[a,axes,stages] = calllib('PI_Mercury_GCS_DLL','Mercury_qCST',ID,axis,blanks(100),100)
% initialize the stage
[a,axes] = calllib('PI_Mercury_GCS_DLL','Mercury_INI',ID,axis)
% reference the stage by driving to the negative limit switch
[a,axes] = calllib('PI_Mercury_GCS_DLL','Mercury_MNL',ID,axis)
disp('Press ENTER when stage has finished moving\n')
pause
% Moving to 2.5
[a,axes] = calllib('PI_Mercury_GCS_DLL','Mercury_MOV',ID,axis,libpointer('doublePtr',2.5))
for k = 1:10
    [a,axes,positions] = calllib('PI_Mercury_GCS_DLL','Mercury_qPOS',ID,axis,libpointer('doublePtr',0))
    pause(0.1);
end
disp('You can now type commands, or "return" to quit\n')
keyboard
calllib('PI_Mercury_GCS_DLL','Mercury_CloseConnection',ID)
unloadlibrary 'PI_Mercury_GCS_DLL'