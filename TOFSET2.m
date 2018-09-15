function varargout = TOFSET2(varargin)
% TOFSET2 MATLAB code for TOFSET2.fig
%      Designed by Stuart Crane of Heriot-Watt University, Edinburgh.
%      Used to obtain the time of flight of ions through an electric field
%      and callibrate them to m/q peaks, using two previously known m/q peaks. 


gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TOFSET2_OpeningFcn, ...
                   'gui_OutputFcn',  @TOFSET2_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function TOFSET2_OpeningFcn(hObject, eventdata, handles, varargin)

Oscilloscopetablebuilder                                %Build table of oscilloscope controls
evalin('base','load(''oscilloscopecontrol.mat'')');     %Load table into MATLAB workspace

closeinstruments    %% is a function which close any instruments left open form previous sessions

%Create a VISA-USB object if it exists.
 handles.oscIntObj = instrfind('Type', 'visa-usb', 'RsrcName', 'USB0::0x0699::0x0366::C063853::INSTR' , 'Tag', '');


% Create the VISA-USB object if it does not exist
% otherwise use the object that was found.
if isempty(handles.oscIntObj)
    try
    handles.oscIntObj = visa('ni', 'USB0::0x0699::0x0366::C063853::INSTR');         %me USB0::0x0699::0x0366::C063853::INSTR %lab USB0::0x0699::0x0363::C064995::INSTR
    handles.oscFlag=1;                                                          % set to 1 to indicate oscilliscope connected    
    end
    else
       handles.oscFlag=1;                                                          % set to 1 to indicate oscilliscope connected 
       fclose(handles.oscIntObj);
       handles.oscIntObj = handles.oscIntObj(1);
 end

% only try to connect if oscilloscope present
if (handles.oscFlag==1) 
end                       

% Create a device object. 
handles.oscDevObj = icdevice('tektronix_tds2000B.mdd', handles.oscIntObj);            

if exist('Previous_Sessions_Settings.settings')==2
    previoussettings = importdata('Previous_Sessions_Settings.settings');    %Imports data from previous settings text file
    handles.previoussettings = previoussettings;
    %Get Settings from previous session
    handles.itterations = handles.previoussettings(1,1);
    handles.delaytime = handles.previoussettings(2,1);
    handles.averagenum = handles.previoussettings(3,1);
    handles.timebasenum = handles.previoussettings(4,1);
    handles.voltnumone = handles.previoussettings(5,1); 
    handles.voltnumtwo = handles.previoussettings(6,1); 
    handles.aqmodenumber = handles.previoussettings(7,1); 
    handles.channelnum = handles.previoussettings(8,1);
    handles.scans = handles.previoussettings(9,1);
    set(handles.noitterations,'String', handles.itterations);                        %Set itterations
    set(handles.scansperit,'String', handles.scans);                                 %Set scans per itteration
    set(handles.delaytimeinc,'String', handles.delaytime);                           %Set delay time
    averagenumlist=evalin('base','handles.averagenum');                              %Load list of possible average values from workspace
    set(handles.average,'Value',find(averagenumlist == handles.averagenum));         %Sets dropdown menu to correct average
    timebasenumlist=evalin('base','handles.timebasenum');                            %Load list of possible timebase values from workspace
    set(handles.timebase,'Value',find(timebasenumlist == handles.timebasenum));      %Sets dropdown menu to correct timebase
    voltnumlist=evalin('base','handles.voltnum');                                    %Load list of possible volt/div values from workspace
    if handles.channelnum == 1;
        handles.channelname = 'channel1';
        set(handles.oscDevObj.Channel(1), 'Scale', handles.voltnumone)               %sets new volt/div
        set(handles.channel,'Value',1)
        set(handles.volt,'Value',find(voltnumlist == handles.voltnumone));           %Sets dropdown menu to correct volts/div
    elseif handles.channelnum == 2;
        handles.channelname = 'channel2';
        set(handles.oscDevObj.Channel(2), 'Scale', handles.voltnumtwo)               %sets new volt/div
        set(handles.channel,'Value',2)
        set(handles.volt,'Value',find(voltnumlist == handles.voltnumtwo));           %Sets dropdown menu to correct volts/div
    end
    clearvars averagenumlist timebasenumlist voltnumlist
else
handles.aqmodenumber = 1;
handles.averagenum = 4;
handles.averagenumcase = 1;
handles.timebasenum = 5.0000e-009;
handles.timebasenumcase = 1;
handles.timebasename= '5 nanoseconds';
handles.voltnumone = 0.0020;
handles.voltnumtwo = 0.0020;
handles.voltnumcase = 1;
handles.voltname= '2 miliVolts';
handles.channelnum= 1;
handles.channelname= 'channel1';
handles.itterations=1;
handles.delaytime=0.3;
handles.scans=6
end





%set handles for main run
handles.itsel=1;
handles.filename='';
handles.uservariable=0;
handles.triggersource = 'external';
handles.excell = 0;
handles.rdat= 1;
handles.osccalset = 1;
handles.Ymax = 1;
handles.Ymin = 0;
handles.run = 0;                %for error to stop calibration if no raw data collected
handles.data = 0;               %for error to stop saving if no raw data collected
handles.settingssave = 0;       %control handle to ensure programme has run before attempting to save settings
handles.calcomp = 0;            %control for zero-offset if calibration not complete 
handles.vertoffcomp = 0;        %to show if vertical offset complete to decide which axis to save with the image save function (icon at top)
handles.DisableAS= 0;    %controls autoscaling of plot axis, default is autoscale
guidata(hObject, handles);

%Set handles for calibration
handles.lpmass=str2double(get(handles.lpmassbox,'string'));
handles.rpmass=str2double(get(handles.rpmassbox,'string'));
handles.scalel=0;
handles.scaler=1;
handles.scalev=0;
handles.verticaloffsetold=0;

%input initial settings with error warning if oscilloscope is not connected
try connect(handles.oscDevObj);
    disconnect(handles.oscDevObj);
        catch                                                                       % if there is an error this stops the whole program exiting
        handles.osc=[];                                                             % if there is no oscilloscope
        handles.oscFlag=0;                                                          % set to 0 to signal that oscilloscope is not connected
        warndlg('No Oscilloscope Connected. Please connect oscilloscope and restart programme', 'Warning !!');
    return
end
connect(handles.oscDevObj);
set(handles.oscDevObj.Acquisition(1), 'Timebase', handles.timebasenum)
set(handles.oscDevObj.Channel(1), 'Scale', handles.voltnumone)
set(handles.oscDevObj.Channel(2), 'Scale', handles.voltnumtwo)
set(handles.oscDevObj.Trigger(1), 'Source', handles.triggersource) 
set(handles.oscDevObj.Acquisition(1), 'NumberOfAverages', handles.averagenum)
if  handles.aqmodenumber == 1;
    set(handles.oscDevObj.Acquisition(1), 'Mode', 'SAMPLE')
    set(handles.average,'enable','off');
    set(handles.aqmode,'Value',1)
elseif  handles.aqmodenumber == 2;
    set(handles.oscDevObj.Acquisition(1), 'Mode', 'AVERAGE')
    set(handles.average,'enable','on');
    set(handles.aqmode,'Value',2)
end
disconnect(handles.oscDevObj);

handles.output = hObject;

guidata(hObject, handles);

function varargout = TOFSET2_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


%Load settings from previous run
function loaddata_Callback(hObject, eventdata, handles)

%Set new oscilloscope settings
try connect(handles.oscDevObj);
    disconnect(handles.oscDevObj); 
        catch                                                                       % if there is an error this stops the whole program exiting
        handles.osc=[];                                                             % if there is no oscilloscope
        handles.oscFlag=0;                                                          % set to 0 to signal that oscilloscope is not connected
        errordlg('No oscilloscope connected, connect oscilloscope before loading file');
    return
end 
[file,path,filterIndex]=uigetfile;
if file~=0;                                         % If file seclected
    loadsettings=load(fullfile(path,file));
    handles.loadsettings=loadsettings;
    handles.channelnum = loadsettings(2,1);         % Create handles for oscilloscope settings
    if handles.channelnum == 1;
        handles.channelname = 'channel1';
    elseif handles.channelnum == 2;
        handles.channelname = 'channel2';
    end
    handles.calconstant = loadsettings(1,1);
    handles.massoffset = loadsettings(1,2);
    handles.voltnumone = loadsettings(2,2);
    handles.averagenum = loadsettings(3,1);
    handles.timebasenum = loadsettings(3,2);
    handles.voltnumtwo = loadsettings(4,1);
    handles.voltageoffset = loadsettings(4,2);
    handles.aqmodenumber= loadsettings(5,1);
    handles.uservariable= loadsettings(5,2);

    %Set new oscilloscope settings
    try connect(handles.oscDevObj);
        disconnect(handles.oscDevObj); 
            catch                                                                       % if there is an error this stops the whole program exiting
            handles.osc=[];                                                             % if there is no oscilloscope
            handles.oscFlag=0;                                                          % set to 0 to signal that oscilloscope is not connected
            errordlg('Oscilloscope disconnected, connect oscilloscope and reload data');
        return
    end 
    connect(handles.oscDevObj);
    set(handles.oscDevObj.Acquisition(1), 'Timebase', handles.timebasenum)
    set(handles.oscDevObj.Channel(1), 'Scale', handles.voltnumone)
    set(handles.oscDevObj.Channel(2), 'Scale', handles.voltnumtwo)
    set(handles.oscDevObj.Trigger(1), 'Source', 'external') 
    set(handles.oscDevObj.Acquisition(1), 'NumberOfAverages', handles.averagenum)
    if  handles.aqmodenumber == 1;
        set(handles.oscDevObj.Acquisition(1), 'Mode', 'SAMPLE')
        set(handles.aqmode,'Value',1)
        set(handles.average,'enable','off');
    elseif  handles.aqmodenumber == 2;
        set(handles.oscDevObj.Acquisition(1), 'Mode', 'AVERAGE')
        set(handles.aqmode,'Value',2)
        set(handles.average,'enable','on');
    end
    disconnect(handles.oscDevObj);
    
    voltnumlist=evalin('base','handles.voltnum');                                    %Load list of possible volt/div values from workspace
    if handles.channelnum == 1;
        set(handles.oscDevObj.Channel(1), 'Scale', handles.voltnumone)               %sets new volt/div
        set(handles.channel,'Value',1)
        set(handles.volt,'Value',find(voltnumlist == handles.voltnumone));           %Sets dropdown menu to correct volts/div
    elseif handles.channelnum == 2;
        set(handles.oscDevObj.Channel(2), 'Scale', handles.voltnumtwo)               %sets new volt/div
        set(handles.channel,'Value',2)
        set(handles.volt,'Value',find(voltnumlist == handles.voltnumtwo));           %Sets dropdown menu to correct volts/div
    end
    timebasenumlist=evalin('base','handles.timebasenum');                            %Load list of possible timebase values from workspace
    set(handles.timebase,'Value',find(timebasenumlist == handles.timebasenum));      %Sets dropdown menu to correct timebase
    averagenumlist=evalin('base','handles.averagenum');                              %Load list of possible average settings from workspace
    set(handles.average,'Value',find(averagenumlist == handles.averagenum));         %Sets dropdown menu to correct average
    clearvars voltnumlist timebasenumlist averagenumlist
end
guidata(hObject, handles);








% Stop Button 
function expstop_Callback(hObject, eventdata, handles)
set(handles.Run,'UserData',0);   
guidata(hObject, handles);

%Run Oscilloscope
function Run_Callback(hObject, eventdata, handles)

set(handles.Run,'UserData',1); 

% Connection Check
try connect(handles.oscDevObj);
    disconnect(handles.oscDevObj);
        catch                                                                       % if there is an error this stops the whole program exiting
        handles.osc=[];                                                             % if there is no oscilloscope
        handles.oscFlag=0;                                                          % set to 0 to signal that oscilloscope is not connected
        errordlg('No Oscilloscope Connected');
    return
end 
  
% Connect to device
connect(handles.oscDevObj);

% set matricies for main run
handles.data=zeros(2500,(handles.itterations+1));               % Build zeros matrix to store data
ymax=zeros(1,handles.itterations);                      % Build zeros matrix to store max Y values
ymin=zeros(1,handles.itterations);                      % Build zeros matrix to store min Y values
cla (handles.axes4);                            % Clear axis from previous run
cla (handles.axes1);

%Reset fact that calibration has not taken place
handles.calcomp=0;
handles.vertoffcomp=0;

%Settings set-up for stop button not pressed at start 
set(handles.Run,'UserData',1);

%Get X axis data
[X] = invoke(handles.oscDevObj.Waveform(1), 'readxwaveform', handles.channelname);

i=1;

while i<=handles.itterations && (get(handles.Run,'UserData') ~= 0);                            % while loop to set run for specified itterations and stop escape condition
    
    [Y] = invoke(handles.oscDevObj.Waveform(1), 'readwaveforms', handles.channelname, handles.scans);
    if handles.scans > 1;
        Y=mean(Y);
    end
    if handles.itterations==1;
        set(handles.textdisplay,'String',['Single itteration completed']);
    elseif handles.itterations~=1;
        set(handles.textdisplay,'String',[num2str(i) ' of ' num2str(handles.itterations) ' itterations completed']);
    end
    plot(handles.axes1,X,Y,'.','MarkerSize',5);
    if handles.DisableAS == 1            % Allows user to manually set plotted Y scale 
        axis(handles.axes1,[min(X) max(X) str2num(get(handles.minYScale,'String'))...
            str2num(get(handles.maxYScale,'String'))] );
    end
    xlabel(handles.axes1,'Time (s)');ylabel(handles.axes1,'Intensity (V)');
     pause(handles.delaytime);                  % Delay time to allow for scope transfer time 
    maxy= max(Y);                               % Find y max for each itteration
    miny= min(Y);                               % Find y min for each itteration
    y = Y(:);                                   % Put Y data into collumn vector
    handles.data(:,(i+1))= y(:,1);              % Sub Y data into main collection matrix
    ymax(:,i)= maxy;                            % Collect all Y max
    ymin(:,i)= miny;                            % Collect all Y min
    if i< handles.itterations                   % Clears axis if not in last itteration
        cla;
    end

    if handles.DisableAS == 0
        set(handles.minYScale,'String',num2str(miny)); % shows minY value in box
        set(handles.maxYScale,'String',num2str(maxy)); % shows minY value in box
    end
    hold on                                     % Holds on to data from previous itterations 
    i=i+1;
end

%normalised time plot data organisation
x = X(:);                                       % Put X data into collumn vector
Xmin=min(X);                                    % Find X min
handles.Xpos=X-Xmin;                                    % Make scale positive
handles.Xmax=max(handles.Xpos);                                 % Find maxi
handles.Xnorm=handles.Xpos/handles.Xmax;                                % Normalise data

handles.data(:,1)= x(:,1);
handles.Ymax=max(ymax);                                 % Find maximum y value of the data
handles.Ymin=min(ymin);                                 % Find minimum y value of the data

plot(handles.axes4,handles.Xnorm,handles.data(1:2500,(handles.itsel+1)),'.','MarkerSize',5)  % Plots against voltage
xlabel(handles.axes4,'Normalised Time (arb.)');ylabel(handles.axes4,'Intensity (V)');

%Set-up cursors
scalel=0;                       % Starting Position
Al=(ones(1,50)*scalel);         % Single location X data
Bl=linspace(handles.Ymin,handles.Ymax,50);      % Cursor hight set by Ymax and Y min
axes(handles.axes4);
lowslider=line(Al,Bl,'linestyle','-','Color',[1 0 0],'Tag','left slider');

scaler=1;
Ar=(ones(1,50)*scaler);         % Single location X data
Br=linspace(handles.Ymin,handles.Ymax,50);      % Cursor hight set by Ymax and Y min
axes(handles.axes4);
highslider=line(Ar,Br,'linestyle','-','Color',[1 0 0],'Tag','right slider');


% Save handles
handles.run=1;
handles.caldata=0;
handles.settingssave=1;
handles.timestamp=datestr(now,'ddmmyyyy_HHMMSS');           %Take timestamp for all data from this run

if (get(handles.Run,'UserData') == 0)
    set(handles.textdisplay,'String',['Scan stopped on ', handles.timestamp,' with ', num2str(i), ' completed iterations']);
else
    if handles.itterations==1;
        set(handles.textdisplay,'String',['Single iteration completed on ', handles.timestamp]);
    elseif handles.itterations~=1;
        set(handles.textdisplay,'String',[num2str(handles.itterations), ' Iterations completed on ', handles.timestamp]);
    end
end
guidata(hObject, handles);

 disconnect(handles.oscDevObj);
 
disp('done :)')


 
 
 
 
 %itterations
function noitterations_Callback(hObject, eventdata, handles)
itterations=str2double(get(hObject,'String'));            %get the new itterations value
if isnan(itterations);                                    %if it's not a number
    itterations = handles.itterations;                    %reset value
    set(hObject, 'String', itterations);                  %reset editbox
    errordlg('Iterations must be a number','Error');     %display an error message
end
if round(itterations)-itterations~=0;                      %if it's not an integer
    itterations = handles.itterations;                     %reset value
    set(hObject, 'String', itterations);                   %reset editbox
    errordlg('Iterations must be an integer','Error');    %display an error message
end
if sign(itterations)<=0.9;                                                     % if it's not positive and greater than zero
    itterations = handles.itterations;                                         %reset value
    set(hObject, 'String', itterations);                                       %reset editbox
    errordlg('Itterations must be positive and greater than zero','Error');    %display an error message
end
handles.itterations = itterations;
guidata(hObject, handles);

function noitterations_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%Scans per itteration
function scansperit_Callback(hObject, eventdata, handles)
scans=str2double(get(hObject,'String'));            %get the new scans value
if isnan(scans);                                    %if it's not a number
    scans = handles.scans;                    %reset value
    set(hObject, 'String', scans);                  %reset editbox
    errordlg('Scans must be a number','Error');     %display an error message
end
if round(scans)-scans~=0;                      %if it's not an integer
    scans = handles.scans;                     %reset value
    set(hObject, 'String', scans);                   %reset editbox
    errordlg('Scans must be an integer','Error');    %display an error message
end
if sign(scans)<=0.9;                                                     % if it's not positive and greater than zero
    scans = handles.scans;                                         %reset value
    set(hObject, 'String', scans);                                       %reset editbox
    errordlg('Scans must be positive and greater than zero','Error');    %display an error message
end
handles.scans = scans;
guidata(hObject, handles);

function scansperit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%Delay time
function delaytimeinc_Callback(hObject, eventdata, handles)
delaytime=str2double(get(hObject,'String'));            %get the new itterations value
if isnan(delaytime);                                    %if it's not a number
    delaytime = handles.delaytime;                      %reset value
    set(hObject, 'String', delaytime);                  %reset editbox
    errordlg('Delay time must be a number','Error');    %display an error message
end
if delaytime < 0.3;                                             % if it's not positive and greater than zero
    delaytime = handles.delaytime;                             %reset value
    set(hObject, 'String', delaytime);                         %reset editbox
    errordlg('Delay time must be 0.3s or greater','Error');    %display an error message
end
handles.delaytime = delaytime;
guidata(hObject, handles);

function delaytimeinc_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%Channel
function channel_Callback(hObject, eventdata, handles)
try connect(handles.oscDevObj);
    disconnect(handles.oscDevObj); 
        catch                                                                       % if there is an error this stops the whole program exiting
        set(handles.channel, 'Value', handles.channelnum);
        handles.osc=[];                                                             % if there is no oscilloscope
        handles.oscFlag=0;                                                          % set to 0 to signal that oscilloscope is not connected
        errordlg('No Oscilloscope Connected');
    return
end 

handles.channelnum= get(hObject, 'value');                                %Get current case
channelnamelist=evalin('base','handles.channelname');                     %Load list of possible channel names from workspace
handles.channelname=channelnamelist(handles.channelnum,1);                %Search for correct channel name for case
voltnumlist=evalin('base','handles.voltnum');                             %Load list of possible volt/div settings from workspace

connect(handles.oscDevObj);
if handles.channelnum == 1;
    set(handles.oscDevObj.Channel(1), 'Scale', handles.voltnumone)          %sets new volt/div
    set(handles.volt,'Value',find(voltnumlist == handles.voltnumone));
elseif handles.channelnum == 2;
    set(handles.oscDevObj.Channel(2), 'Scale', handles.voltnumtwo)          %sets new volt/div
    set(handles.volt,'Value',find(voltnumlist == handles.voltnumtwo));
end
disconnect(handles.oscDevObj);                                            %Disconnects from oscilloscope
clearvars channelnamelist voltnumlist                                     %Clear lists of variables from current workspace
guidata(hObject, handles);

function channel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% Timebase
function timebase_Callback(hObject, eventdata, handles)
  try connect(handles.oscDevObj);
      disconnect(handles.oscDevObj);                                          
          catch                                                                       % if there is an error this stops the whole program exiting
          set(handles.timebase, 'Value', handles.timebasenumcase);
          handles.osc=[];                                                             % if there is no oscilloscope
          handles.oscFlag=0;                                                          % set to 0 to signal that oscilloscope is not connected
          errordlg('No Oscilloscope Connected');
      return
  end 
handles.timebasenumcase= get(hObject, 'value');                         %Get current case
timebasenumlist=evalin('base','handles.timebasenum');                   %Load list of possible timebase values from workspace
timebasenumnamelist=evalin('base','handles.timebasenumname');           %Load list of possible timebase names from workspace
handles.timebasenum=timebasenumlist(handles.timebasenumcase,1);         %Search for correct timebase number for case
handles.timebasenumname=timebasenumnamelist(handles.timebasenumcase,1); %Search for correct timebase name for case
clearvars timebasenumlist timebasenumnamelist                           %Clear lists of variables from current workspace
connect(handles.oscDevObj);                                             %connects to oscilloscope
set(handles.oscDevObj.Acquisition(1), 'Timebase', handles.timebasenum)  %sets new timebase
disconnect(handles.oscDevObj);                                          %disconnects from oscilloscope
guidata(hObject, handles);

function timebase_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%Volt/div
function volt_Callback(hObject, eventdata, handles)
try connect(handles.oscDevObj);
    disconnect(handles.oscDevObj); 
        catch                                                                       % if there is an error this stops the whole program exiting
        set(handles.volt, 'Value', handles.voltnumcase);
        handles.osc=[];                                                             % if there is no oscilloscope
        handles.oscFlag=0;                                                          % set to 0 to signal that oscilloscope is not connected
        errordlg('No Oscilloscope Connected');
    return
end 

handles.voltnumcase= get(hObject, 'value');                 %Get current case
voltnumlist=evalin('base','handles.voltnum');               %Load list of possible volt/div values from workspace
voltnamelist=evalin('base','handles.voltname');             %Load list of possible volt/div names from workspace
handles.voltnum=voltnumlist(handles.voltnumcase,1);         %Search for correct volt/div number for case
handles.voltname=voltnamelist(handles.voltnumcase,1);       %Search for correct volt/div name for case
clearvars voltnumlist voltnamelist                          %Clear lists of variables from current workspace

connect(handles.oscDevObj);                                             %connects to oscilloscope
if handles.channelnum == 1;
    handles.voltnumone=handles.voltnum;
    set(handles.oscDevObj.Channel(1), 'Scale', handles.voltnumone)          %sets new volt/div                         %For saving on exit
elseif handles.channelnum == 2;
    handles.voltnumtwo=handles.voltnum;
    set(handles.oscDevObj.Channel(2), 'Scale', handles.voltnumtwo)          %sets new volt/div
end
disconnect(handles.oscDevObj);                                          %disconnects from oscilloscope
guidata(hObject, handles);

function volt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%Filename
function namefile_Callback(hObject, eventdata, handles)
filename=get(hObject,'string');
handles.filename=filename;
guidata(hObject, handles);

function namefile_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Acquisiition Mode
function aqmode_Callback(hObject, eventdata, handles)
aqmodenumber= get(hObject, 'value');
try connect(handles.oscDevObj);
    disconnect(handles.oscDevObj); 
        catch                                                                       % if there is an error this stops the whole program exiting
        set(handles.aqmode, 'Value', handles.aqmodenumber);
        handles.osc=[];                                                             % if there is no oscilloscope
        handles.oscFlag=0;                                                          % set to 0 to signal that oscilloscope is not connected
        errordlg('No Oscilloscope Connected');
    return
end 

handles.aqmodenumber= get(hObject, 'value');                            %Get current case
aqmodenumlist=evalin('base','handles.aqmodenum');                       %Load list of possible acquisition modes from workspace
aqmodenumcaselist=evalin('base','handles.aqmodenumcase');               %Load list of possible acquisition mode names from workspace
handles.aqmodenum=aqmodenumlist(handles.aqmodenumber,1);                %Search for correct acquisition mode number for case
handles.aqmodenumcase=aqmodenumcaselist(handles.aqmodenumber,1);        %Search for correct acquisition mode name for case
clearvars aqmodenumlist aqmodenumcaselist                               %Clear lists of variables from current workspace

connect(handles.oscDevObj);                                             %Connects to oscilloscope
if handles.aqmodenumber == 1;                                           %Sets the mode of acquisition chosen
    set(handles.oscDevObj.Acquisition(1), 'Mode', 'SAMPLE')        
    set(handles.average,'enable','off');
elseif handles.aqmodenumber == 2;
    set(handles.oscDevObj.Acquisition(1), 'Mode', 'AVERAGE')    
    set(handles.average,'enable','on');
end
disconnect(handles.oscDevObj);                                          %Disconnects from oscilloscope
guidata(hObject, handles);

function aqmode_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Number of Averages
function average_Callback(hObject, eventdata, handles)
averagenum= get(hObject, 'value');
try connect(handles.oscDevObj);
    disconnect(handles.oscDevObj); 
        catch                                                                       % if there is an error this stops the whole program exiting
        set(handles.average, 'Value', handles.averagenumcase);
        handles.osc=[];                                                             % if there is no oscilloscope
        handles.oscFlag=0;                                                          % set to 0 to signal that oscilloscope is not connected
        errordlg('No Oscilloscope Connected');
    return
end 
handles.averagenumcase= get(hObject, 'value');                                       %Get current case
averagenumlist=evalin('base','handles.averagenum');                                  %Load list of possible average settings from workspace
handles.averagenum=averagenumlist(handles.averagenumcase,1);                         %Search for correct average for case
clearvars averagenumlist                                                             %Clear lists of variables from current workspace
connect(handles.oscDevObj);                                                          %connects to oscilloscope
set(handles.oscDevObj.Acquisition(1), 'NumberOfAverages', handles.averagenum)        %sets new Number of Averages
disconnect(handles.oscDevObj);                                                       %disconnects from oscilloscope
guidata(hObject, handles);

function average_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%Shows File location
function filelocation_Callback(hObject, eventdata, handles)
get(hObject,'string');                      %Gets input file location

function filelocation_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%Opens directory to set file location
function filedirectory_Callback(hObject, eventdata, handles)
filedirectory=uigetdir('C:\');                      % Opens up directory box
set(handles.filelocation, 'string',filedirectory);  % States the file location in the file directory edit box 
handles.filedirectory=filedirectory;
guidata(hObject, handles);


%Slider to pick out known peak on left
function leftslider_Callback(hObject, eventdata, handles)

scalel=get(hObject,'value');                    %Position of left slider
newAl=(ones(1,50)*scalel);                      %X position of cursor
newBl=linspace(handles.Ymin,handles.Ymax,50);                   %Y position of cursor
lowslider = findobj(gcf,'Tag','left slider');   %Update cursor
set(lowslider,'Xdata',newAl,'YData',newBl);
handles.scalel=scalel;
guidata(hObject, handles);

function leftslider_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


%Slider to pick out known peak on right
function rightslider_Callback(hObject, eventdata, handles)

scaler=get(hObject,'value');                    %Position of right slider
newAr=(ones(1,50)*scaler);                      %X position of cursor
newBr=linspace(handles.Ymin,handles.Ymax,50);                   %Y position of cursor
highslider = findobj(gcf,'Tag','right slider'); %Update cursor
set(highslider,'Xdata',newAr,'YData',newBr);
handles.scaler=scaler;
guidata(hObject, handles);

function rightslider_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%Slider to pick vertical offset
function verticalslider_Callback(hObject, eventdata, handles)
Xmax=handles.mqcalmax;
Xmin=handles.mqcalmin;
scalev=get(hObject,'value');                    %Position of right slider
newAv=linspace(Xmin,Xmax,50);                   %X position of cursor
newBv=(ones(1,50)*scalev);
vertslider = findobj(gcf,'Tag','vertical slider'); %Update cursor
set(vertslider,'Xdata',newAv,'YData',newBv);
handles.scalev=scalev;
guidata(hObject, handles);

function verticalslider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end











%calibration

function Calibration_Callback(hObject, eventdata, handles)

if handles.run==0
    errordlg('Must have data before calibration can occur','Error');    %display an error message
    return
end
lpmass=handles.lpmass;                                %Takes data from lpmass set
rpmass=handles.rpmass;                                %Takes data from lpmass set
if rpmass==0                                          %Checks if rpmass is zero
    errordlg('Must set mass to charge ratio of right peak before running','Error');    %display an error message
    return
end
if handles.scaler<handles.scalel;
     errordlg('Must set right peak at a later time than left peak','Error');    %display an error message
    return
end
handles.lpmass= lpmass;
handles.rpmass= rpmass;

cla(handles.axes1);

  %Collect relevant handles
scaler=handles.scaler;
scalel=handles.scalel;
itsel=handles.itsel;
data=handles.data;


%Calculate m/q calibration constants from the two peaks
massneg=rpmass-lpmass;                             %mass difference
timesqneg=(((scaler*handles.Xmax)^2)-((scalel*handles.Xmax)^2));      %time squared difference
calconstant=(massneg/timesqneg);                      %divide mass by timesq for calibration constant

masspos=rpmass+lpmass;
timesqpos=(calconstant*(((scaler*handles.Xmax)^2)+((scalel*handles.Xmax)^2)));
massoffset=((masspos-timesqpos)/2);

%Callibrate data
mq=(((handles.Xpos.^2)*calconstant)+massoffset);            %Calibration complete
Xcalnonzeroi=find(mq>0,1);                          %Shows index of first element greater than zero
mqcal=mq(1,Xcalnonzeroi:2500);                      %Creates vector of relevant x data to correct length
Ycalnonzero=data(Xcalnonzeroi:2500,(itsel+1));      %Creates vector of relevant y data to correct length
mqcalmax=max(mqcal);                                %find maximum mqcal value
mqcalmin=min(mqcal);                                %fine minimum mqcal value

%Scaler to mass offset set

scalercal=(scaler*handles.Xmax);         %Show left mass charge peak time
scalelcal=(scalel*handles.Xmax);         %Show right mass charge peak time

%Calculate maximum Y values
Ymingate= min(Ycalnonzero);
Ymaxgate= max(Ycalnonzero);

%Plot data
plot(handles.axes1,mqcal,Ycalnonzero,'.','MarkerSize',5)  %Plots m/q versus voltage
axes(handles.axes1);
if Ymingate<0 && Ymaxgate>0;
    axis([mqcalmin mqcalmax Ymingate Ymaxgate]);
elseif Ymingate<0 && Ymaxgate<0
    axis([mqcalmin mqcalmax Ymingate 0.0001]);
elseif Ymingate>0 && Ymaxgate>0
    axis([mqcalmin mqcalmax -0.0001 Ymaxgate]);
end
xlabel(handles.axes1,'m/q');ylabel(handles.axes1,'Intensity (V)')
mqcal=mqcal(:);




%Building calibration data matrix
caldatesize=2500-(Xcalnonzeroi-1);          % Sets length of calibration data matrix
caldata=zeros(caldatesize,2);               % Creates 2 collumn matrix
caldata(:,1)= mqcal(:,1);                   % Inserts x data into first collumn
caldata(:,2)= Ycalnonzero(:,1);             % inserts y data into second collumn

handles.mqcal=mqcal;
handles.Ycalnonzero=Ycalnonzero;
handles.Xcalnonzeroi=Xcalnonzeroi;
handles.Ymingate=Ymingate;
handles.Ymaxgate=Ymaxgate;
handles.scalercal=scalercal;
handles.scalelcal=scalelcal;
handles.calconstant=calconstant;
handles.massoffset=massoffset;
handles.caldata=caldata;
handles.mqcalmax=mqcalmax;
handles.mqcalmin=mqcalmin;
handles.calcomp=1;

%set-up vertical zero-offset slider
scalev=0;
Av=linspace(mqcalmin,mqcalmax,50);      % Cursor hight set by mqcalmax and mqcalmin
Bv=(ones(1,50)*scalev*handles.Ymax);         % Single location X data
axes(handles.axes1);
vertslider=line(Av,Bv,'linestyle','-','Color',[1 0 0],'Tag','vertical slider');
if Ymingate<0 && Ymaxgate>0;
    set(handles.verticalslider,'Min',handles.Ymin,'Max',handles.Ymax);
elseif Ymingate<0 && Ymaxgate<0
    set(handles.verticalslider,'Min',handles.Ymin,'Max',0.0001);
elseif Ymingate>0 && Ymaxgate>0
    set(handles.verticalslider,'Min',-0.0001,'Max',handles.Ymax);
end
guidata(hObject, handles);

% Left peak mass to charge ratio value
function lpmassbox_Callback(hObject, eventdata, handles)

lpmass=str2double(get(hObject,'String'));                          %get the new left peak mass to charge ratio value
if isnan(lpmass);                                                  %if it's not a number
    lpmass = handles.lpmass;                                       %reset value
    set(hObject, 'String', lpmass);                                %reset editbox
    errordlg('Mass to charge ratio must be a number','Error');     %display an error message
end
if sign(lpmass)<0;                                                     % if it's not positive and greater than zero
    lpmass = handles.lpmass;                                         %reset value
    set(hObject, 'String', lpmass);                                       %reset editbox
    errordlg('Mass to charge ratio must be positive','Error');    %display an error message
end
handles.lpmass = lpmass;
guidata(hObject, handles);

function lpmassbox_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%Right Peak mass to charge ratio value
function rpmassbox_Callback(hObject, eventdata, handles)
rpmass=str2double(get(hObject,'String'));                          %get the new right peak mass to charge ratio value
if isnan(rpmass);                                                  %if it's not a number
    rpmass = handles.rpmass;                                       %reset value
    set(hObject, 'String', rpmass);                                %reset editbox
    errordlg('Mass to charge ratio must be a non-zero number','Error');     %display an error message
end
if sign(rpmass)<=0;                                                     % if it's not positive and greater than zero
    rpmass = handles.rpmass;                                         %reset value
    set(hObject, 'String', rpmass);                                       %reset editbox
    errordlg('Mass to charge ratio must be positive and greater than zero','Error');    %display an error message
end
handles.rpmass = rpmass;
guidata(hObject, handles);

function rpmassbox_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% Selected itteration to observe for calibration
function itsel_Callback(hObject, eventdata, handles)
cla(handles.axes4);
itterations=handles.itterations;
itsel=str2double(get(hObject,'String'));                          %get the new itteration selected value
if isnan(itsel);                                                  %if it's not a number
    itsel = handles.itsel;                                        %reset value
    set(hObject, 'String', itsel);                                %reset editbox
    errordlg('Itteration selected value must be a number','Error');     %display an error message
end
if round(itsel)-itsel~=0;                                         %if it's not an integer
    itsel = handles.itsel;                                        %reset value
    set(hObject, 'String', itsel);                                %reset editbox
    errordlg('Itteration selected value must be an integer','Error');    %display an error message
end
if sign(itsel)<=0.9;                                               %if it's not positive and greater than zero
    itsel = handles.itsel;                                         %reset value
    set(hObject, 'String', itsel);                                 %reset editbox
    errordlg('Itteration selacted value must be positive and greater than zero','Error');    %display an error message
end
if itsel>itterations ;                                             %if itsel exceeds number of itterations
    itsel = handles.itsel;                                         %reset value
    set(hObject, 'String', itsel);                                 %reset editbox
    errordlg('Itteration selected value must not exceed number of itterations','Error');    %display an error message
end
handles.itsel=itsel;
plot(handles.axes4,handles.Xnorm,handles.data(1:2500,(itsel+1)),'.','MarkerSize',5)  % Plots against voltage
xlabel('Normalised Time (arb.)');ylabel('Voltage(V)');

%Set-up cursors for callibration
scalel=0;
Al=(ones(1,50)*scalel);
Bl=linspace(handles.Ymin,handles.Ymax,50);
lowslider=line(Al,Bl,'linestyle','-','Color',[1 0 0],'Tag','left slider');

scaler=1;
Ar=(ones(1,50)*scaler);
Br=linspace(handles.Ymin,handles.Ymax,50);
highslider=line(Ar,Br,'linestyle','-','Color',[1 0 0],'Tag','right slider');

guidata(hObject, handles);

function itsel_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%vertical offset
function yaxisoffset_Callback(hObject, eventdata, handles)
if handles.calcomp==0
    errordlg('Must callibrate before setting offset','Error');    %display an error message
    return
end
handles.verticaloffsetnew=get(handles.verticalslider,'Value');
handles.verticaloffsetold=handles.verticaloffsetold+handles.verticaloffsetnew;
handles.Ycalnonzero=handles.Ycalnonzero-handles.verticaloffsetnew;
%Plot data
cla(handles.axes4)
plot(handles.axes4,handles.mqcal,handles.Ycalnonzero,'.','MarkerSize',5)  %Plots m/q versus voltage
axes(handles.axes4);
Ymingate=min(handles.Ycalnonzero);
Ymaxgate=max(handles.Ycalnonzero);
axis([handles.mqcalmin handles.mqcalmax Ymingate Ymaxgate]);
xlabel(handles.axes4,'m/q');ylabel(handles.axes4,'Intensity (V)')
set(handles.offsetupdate,'String', [num2str(handles.verticaloffsetold) 'V']);
handles.vertoffcomp=1;
guidata(hObject, handles);









% Value to a variable the user wishes to use and name in title
function uservariablevalue_Callback(hObject, eventdata, handles)
uservariable=str2double(get(handles.uservariablevalue,'String'))            %get the new user variable value
if isnan(uservariable);                                    %if it's not a number
    uservariable = handles.uservariable;                      %reset value
    set(hObject, 'String', uservariable);                  %reset editbox
    errordlg('User Variable must be a number','Error');    %display an error message
end
handles.uservariable=uservariable;
guidata(hObject, handles);

function uservariablevalue_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%Save function
function Save_Callback(hObject, eventdata, handles)

%Check for filename
filename=handles.filename;                                %Takes data from filename set
if isempty(filename)                                      %Checks if edit box is empty
    errordlg('Must name file before running','Error');    %display an error message
    return
end
if ~isempty(regexp(filename, '[/\*:?"<>|]', 'once'))            %Checks for illegal characters in filename
    errordlg('Illegal characters in filename');                 % display an error message
    return
end
handles.filename= filename;

filelocation=handles.filelocation;
directorycheck=get(handles.filelocation,'String');          %Takes data from filelocation set
if isempty (directorycheck)                                 %Checks if edit box is empty
    errordlg('Must set directory before running','Error');  %display an error message
    return
end
if exist(directorycheck)~=7;                           % Checks to make sure user dosen't just press cancle on directory
    errordlg('Nonexsistant or invalid directory selected','Error');
    return
end
handles.filelocation=filelocation;


%set up handles to check which options chosen to save
excell=handles.excell;
rdat=handles.rdat;
osccalset=handles.osccalset;

%Other required handles to save how we wish
itterations=handles.itterations;


%saving Raw data
if rdat==1;
    if handles.data==0                                              % if no raw data is present
    errordlg('Must have raw data in order to save it','Error');    %display an error message
    return
end
  if itterations==1       %data file names by single or multi itterations
      filenamedatatxt=strcat(handles.filename,'_',num2str(handles.uservariable),'_',handles.timestamp,'_Raw_Data_Single','.dat');
  else
      filenamedatatxt=strcat(handles.filename,'_',num2str(handles.uservariable),'_',handles.timestamp,'_Raw_Data_Multi','.dat');
  end
  rawdataname=fullfile(handles.filedirectory,filenamedatatxt);              %Includes file directory
  dlmwrite(rawdataname, handles.data, 'delimiter','\t') %Save data to txt file, tabs delimiter to separate collumns
end

%Save All Settings
if osccalset == 1;
    if handles.calcomp == 0;   
        osccalsettings =[0 0; handles.channelnum handles.voltnumone; handles.averagenum handles.timebasenum; handles.voltnumtwo handles.verticaloffsetold; handles.aqmodenumber handles.uservariable];
        handles.osccalsettings=osccalsettings;
        if itterations==1       %settings file names by single or multi itterations
            filenameosccalsettingstxt=strcat(handles.filename,'_',num2str(handles.uservariable),'_',handles.timestamp,'_Oscilloscope_Settings_Single','.txt');
        else
            filenameosccalsettingstxt=strcat(handles.filename,'_',num2str(handles.uservariable),'_',handles.timestamp,'_Oscilloscope_Settings_Multi','.txt');
        end
        osccalsettingsname=fullfile(handles.filedirectory,filenameosccalsettingstxt);      %Incldudes file directory
        dlmwrite( osccalsettingsname, handles.osccalsettings, 'delimiter','\t') %Save settings to settings file, tabs delimiter to separate collumns
    elseif handles.calcomp == 1;
        osccalsettings = [handles.calconstant handles.massoffset; handles.channelnum handles.voltnumone; handles.averagenum handles.timebasenum; handles.voltnumtwo handles.verticaloffsetold; handles.aqmodenumber handles.uservariable; handles.lpmass handles.rpmass; handles.scalelcal handles.scalercal; handles.itterations handles.itsel; handles.delaytime 0];
        handles.osccalsettings=osccalsettings;
        if itterations==1       %calibration settings file names by single or multi itterations
            filenameosccalsettingstxt=strcat(handles.filename,'_',num2str(handles.uservariable),'_',handles.timestamp,'_Oscilloscope_and_Calibration_Settings_Single','.settings');
        else
            filenameosccalsettingstxt=strcat(handles.filename,'_',num2str(handles.uservariable),'_',handles.timestamp,'_Oscilloscope_and_Calibration_Settings_Multi','.settings');
        end
        osccalsettingsname=fullfile(handles.filedirectory,filenameosccalsettingstxt);      %Incldudes file directory
        dlmwrite( osccalsettingsname, handles.osccalsettings, 'delimiter','\t') %Save settings to settings file, tabs delimiter to separate collumns
    end
    handles.settingsdescriptionfilename=fullfile(handles.filedirectory,'settings_description.txt');
    if exist (handles.settingsdescriptionfilename)~=2
        settingsdescription = {'Calibration Constant', 'Mass Offset'; 'Channel Number', 'Channel 1 Volts/Div (V)'; 'Number of Averages', 'Timebase (s)'; 'Channel 2 Volts/Div (V)', 'Voltage Offset (V)'; 'Acquisition Mode Type', 'Input User Variable'; 'm/q left peak', 'm/q right peak'; 'Left peak time (s)', 'Right peak time (s)'; 'Itterations', 'Itteration number'; 'Delaytime (s)', ''};
        handles.settingsdescription=settingsdescription;
        %Convert to char for text file as numbers and strings, requires ex_func and exfunc_2, files found at http://www.mathworks.com/matlabcentral/answers/99632-how-do-i-save-a-cell-array-that-contains-both-strings-and-numbers-to-an-ascii-file-in-matlab
        ex2desc = cellfun(@ex1,settingsdescription,'UniformOutput',0);
        size_ex2desc = cellfun(@length,ex2desc,'UniformOutput',0);
        str_lengthdesc = max(max(cell2mat(size_ex2desc)));
        ex3desc = cellfun(@(x) ex2(x,str_lengthdesc),ex2desc,'uniformoutput',0);
        charsettingsdesc = cell2mat(ex3desc);
        fid = fopen(handles.settingsdescriptionfilename,'wt');     %Save settings to txt file,  
        fprintf(fid,'%s %s\n',charsettingsdesc(1,1:str_lengthdesc),charsettingsdesc(1,(str_lengthdesc+1):(2*str_lengthdesc)));
        fprintf(fid,'%s %s\n',charsettingsdesc(2,1:str_lengthdesc),charsettingsdesc(2,(str_lengthdesc+1):(2*str_lengthdesc)));
        fprintf(fid,'%s %s\n',charsettingsdesc(3,1:str_lengthdesc),charsettingsdesc(3,(str_lengthdesc+1):(2*str_lengthdesc)));
        fprintf(fid,'%s %s\n',charsettingsdesc(4,1:str_lengthdesc),charsettingsdesc(4,(str_lengthdesc+1):(2*str_lengthdesc)));
        fprintf(fid,'%s %s\n',charsettingsdesc(5,1:str_lengthdesc),charsettingsdesc(5,(str_lengthdesc+1):(2*str_lengthdesc)));
        fprintf(fid,'%s %s\n',charsettingsdesc(6,1:str_lengthdesc),charsettingsdesc(6,(str_lengthdesc+1):(2*str_lengthdesc)));
        fprintf(fid,'%s %s\n',charsettingsdesc(7,1:str_lengthdesc),charsettingsdesc(7,(str_lengthdesc+1):(2*str_lengthdesc)));
        fprintf(fid,'%s %s\n',charsettingsdesc(8,1:str_lengthdesc),charsettingsdesc(8,(str_lengthdesc+1):(2*str_lengthdesc)));
        fprintf(fid,'%s %s\n',charsettingsdesc(9,1:str_lengthdesc),charsettingsdesc(9,(str_lengthdesc+1):(2*str_lengthdesc)));
        fclose(fid);
    end
end

 %If Excell save selected
 if excell==1
     if handles.data==0;                                              % if no raw data is present
        errordlg('Must have raw data in order to save it','Error');    %display an error message
        return
     end
     if itterations==1                                   %checks if single measurement or multiple itterations for title
         filenameexcell=strcat(handles.filename,'_',num2str(handles.uservariable),'_',datestr(now,'ddmmyyyy_HHMMSS'),'_Single','.xlsx'); 
     else
         filenameexcell=strcat(handles.filename,'_',num2str(handles.uservariable),'_',datestr(now,'ddmmyyyy_HHMMSS'),'_Multi','.xlsx');
     end
     excellname=fullfile(handles.filedirectory,filenameexcell);         %Includes file directory
     xlswrite(excellname,{'Raw Data'},1,'A1')            %curly brackets to specify single cell for data
     xlswrite(excellname,{'Xdata (s)'},1,'A2')
     xlswrite(excellname,1:handles.itterations,1,'B2')
     xlswrite(excellname,handles.data,1,'A3')
     xlswrite(excellname,{'Settings'},2,'A1')
     xlswrite(excellname,handles.osccalsettings,2,'A2')
 end
 guidata(hObject, handles)
 
    
%Raw data save check
function rdat_Callback(hObject, eventdata, handles)
rdat= get(hObject,'Value');                            %checks if selected or not, 1 selected, 0 not
handles.rdat=rdat;
guidata(hObject, handles)


%Save Settings
function osccalset_Callback(hObject, eventdata, handles)
osccalset= get(hObject,'Value');                            %checks if selected or not, 1 selected, 0 not
handles.osccalset=osccalset;
guidata(hObject, handles);


%Save to excell check
function excell_Callback(hObject, eventdata, handles)
excell= get(hObject,'Value');                            %checks if selected or not, 1 selected, 0 not
handles.excell=excell;
guidata(hObject, handles);





%Export data to second GUI
function export_Callback(hObject, eventdata, handles)

%Check for filename
filename=handles.filename;                                %Takes data from filename set
if isempty(filename)                                      %Checks if edit box is empty
    errordlg('Must name file before exporting','Error');    %display an error message
    return
end
if ~isempty(regexp(filename, '[/\*:?"<>|]', 'once'))            %Checks for illegal characters in filename
    errordlg('Illegal characters in filename');                 % display an error message
    return
end
handles.filename= filename;

filelocation=handles.filelocation;
directorycheck=get(handles.filelocation,'String');          %Takes data from filelocation set
if isempty (directorycheck)                                 %Checks if edit box is empty
    errordlg('Must set directory before exporting','Error');  %display an error message
    return
end
if exist(directorycheck)~=7;                           % Checks to make sure user dosen't just press cancle on directory
    errordlg('Nonexsistant or invalid directory selected','Error');
    return
end
handles.filelocation=filelocation;

%Create matrix of settings and initial data depending on with or without calibration
if handles.calcomp == 1;
    datasettings=[handles.calconstant,handles.massoffset;handles.channelnum,handles.voltnumone;handles.averagenum,handles.timebasenum;handles.voltnumtwo,handles.verticaloffsetold;handles.aqmodenumber,0];
    tofrundata=[datasettings;handles.caldata];
    filenametofrundatatxt=strcat(handles.filename,'_',num2str(handles.uservariable),'_',handles.timestamp,'_cal_TOFRUN','.txt');
elseif handles.calcomp == 0;
    datasettings=[0,0;handles.channelnum,handles.voltnumone;handles.averagenum,handles.timebasenum;handles.voltnumtwo,handles.verticaloffsetold;handles.aqmodenumber,0];
    %sort data into selected itteration only for export
    datayvalues = handles.data(:,(handles.itsel+1));
    dataxvalues = handles.data(:,1);
    exportdata = [dataxvalues,datayvalues];
    tofrundata=[datasettings;exportdata];
    filenametofrundatatxt=strcat(handles.filename,'_',num2str(handles.uservariable),'_',handles.timestamp,'_nocal_TOFRUN','.txt');
end

%Save data for export to use again later
tofrundataname=fullfile(handles.filedirectory,filenametofrundatatxt);              %Includes file directory
dlmwrite(tofrundataname, tofrundata, 'delimiter','\t') %Save data to txt file, tabs delimiter to separate collumns

%Create temporary file with information 
temporaryfilename='temporaryfile.txt';
dlmwrite(temporaryfilename, tofrundata, 'delimiter','\t') %Save data to txt file, tabs delimiter to separate collumns


%Open TOFRUN
TOFRUN2
disconnect(handles.oscDevObj);
guidata(hObject, handles)


%Exit and Save
function exitandsave_Callback(hObject, eventdata, handles)
previoussessionsettings= {handles.itterations; handles.delaytime; handles.averagenum; handles.timebasenum; handles.voltnumone; handles.voltnumtwo; handles.aqmodenumber; handles.channelnum; handles.scans};
previoussessionsettingsname='Previous_Sessions_Settings.settings';
dlmwrite(previoussessionsettingsname, previoussessionsettings) %Save settings to .settings file
if exist ('previous_settings_description.txt')~=2
        previoussettingsdescription = {'Itterations'; 'Delay Time (s)'; 'Number of averages'; 'Timebase (s)'; 'Volts/Div channel 1'; 'Volts/Div channel 2'; 'Acquisition Mode Type'; 'Channel'; 'Scans per Itteration'};
        handles.previoussettingsdescription=previoussettingsdescription;
        %Convert to char for text file as numbers and strings, requires ex_func and exfunc_2, files found at http://www.mathworks.com/matlabcentral/answers/99632-how-do-i-save-a-cell-array-that-contains-both-strings-and-numbers-to-an-ascii-file-in-matlab
        ex2prev = cellfun(@ex1,previoussettingsdescription,'UniformOutput',0);
        size_ex2prev = cellfun(@length,ex2prev,'UniformOutput',0);
        str_lengthprev = max(max(cell2mat(size_ex2prev)));
        ex3prev = cellfun(@(x) ex2(x,str_lengthprev),ex2prev,'uniformoutput',0);
        charprevsettings = cell2mat(ex3prev);
        fid = fopen('previous_settings_description.txt','wt');     %Save settings to txt file,  
        fprintf(fid,'%s\n',charprevsettings(1,1:str_lengthprev));
        fprintf(fid,'%s\n',charprevsettings(2,1:str_lengthprev));
        fprintf(fid,'%s\n',charprevsettings(3,1:str_lengthprev));
        fprintf(fid,'%s\n',charprevsettings(4,1:str_lengthprev));
        fprintf(fid,'%s\n',charprevsettings(5,1:str_lengthprev));
        fprintf(fid,'%s\n',charprevsettings(6,1:str_lengthprev));
        fprintf(fid,'%s\n',charprevsettings(7,1:str_lengthprev));
        fprintf(fid,'%s\n',charprevsettings(8,1:str_lengthprev));
        fprintf(fid,'%s\n',charprevsettings(9,1:str_lengthprev));
        fclose(fid);
end   
guidata(hObject, handles)
close





%Toolbar
% --------------------------------------------------------------------

%Save Figure to PDF
function uipushtool1_ClickedCallback(hObject, eventdata, handles)
if isempty(handles.filename)                                      %Checks if edit box is empty
    errordlg('Must name file before running','Error');    %display an error message
    return
end
if ~isempty(regexp(handles.filename, '[/\*:?"<>|]', 'once'))            %Checks for illegal characters in filename
    errordlg('Illegal characters in filename');                 % display an error message
    return
end
directorycheck=get(handles.filelocation,'String');          %Takes data from filelocation set
if isempty (directorycheck)                                 %Checks if edit box is empty
    errordlg('Must set directory before exporting','Error');  %display an error message
    return
end
if exist(directorycheck)~=7;                           % Checks to make sure user dosen't just press cancle on directory
    errordlg('Nonexsistant or invalid directory selected','Error');
    return
end
handles.filenamepdfimage=strcat(handles.filename,'_',handles.timestamp,'_Scan_Image.jpg');
handles.savingimagefilename=fullfile(handles.filedirectory,handles.filenamepdfimage);
f = figure('Visible', 'off');               %Don't show new figure popping up
if handles.vertoffcomp == 1;
    copyobj(handles.axes4,f);                   %Copy axis into new figure
elseif handles.vertoffcomp == 0;
    copyobj(handles.axes1,f);                   %Copy axis into new figure
end
set(gcf, 'Units', 'normalized', 'Position', [0, 0, 1, 1])       %Make figure big to see whole graph
pause(0.1)                                  %Give it time to do so
export_fig (handles.savingimagefilename);   %http://www.mathworks.com/matlabcentral/fileexchange/23629-export-fig          export the file
guidata(hObject, handles)


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in DisableAutoScale.
function DisableAutoScale_Callback(hObject, eventdata, handles)
% hObject    handle to DisableAutoScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DisableAutoScale
DisableAS= get(hObject,'Value');                  %checks if selected or not, 1 selected, 0 not
handles.DisableAS=DisableAS;
guidata(hObject, handles)


function minYScale_Callback(hObject, eventdata, handles)
% hObject    handle to minYScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minYScale as text
%        str2double(get(hObject,'String')) returns contents of minYScale as a double


% --- Executes during object creation, after setting all properties.
function minYScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minYScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxYScale_Callback(hObject, eventdata, handles)
% hObject    handle to maxYScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxYScale as text
%        str2double(get(hObject,'String')) returns contents of maxYScale as a double


% --- Executes during object creation, after setting all properties.
function maxYScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxYScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function DisableAutoScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DisableAutoScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function offsetupdate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to offsetupdate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function rdat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rdat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over osccalset.
function osccalset_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to osccalset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on DisableAutoScale and none of its controls.
function DisableAutoScale_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to DisableAutoScale (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
