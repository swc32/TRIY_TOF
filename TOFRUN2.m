function varargout = TOFRUN2(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TOFRUN2_OpeningFcn, ...
                   'gui_OutputFcn',  @TOFRUN2_OutputFcn, ...
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

function TOFRUN2_OpeningFcn(hObject, eventdata, handles, varargin)


%Check for existance of temporary file
if exist('temporaryfile.txt')==2
    handles.loadeddata=1;               % For main run, fail safe to ensure settings loaded
else
    handles.loadeddata=0;
end

if exist('temporaryfile.txt')==2
    warndlg('Wait for arduino to connect before continuing','Error');         %Tell user to load data if not
    initialsettings = importdata('temporaryfile.txt');    %Imports data from temporary text file
    handles.initialsettings = initialsettings;
    handles.channelnum = initialsettings(2,1);            %Create handles
    if handles.channelnum == 1;
        handles.channelname = 'channel1';
    elseif handles.channelnum == 2;
        handles.channelname = 'channel2';
    end
    handles.voltnum1 = initialsettings(2,2);
    handles.averagenum = initialsettings(3,1);
    handles.timebasenum = initialsettings(3,2);
    handles.voltnum2 = initialsettings(4,1);
    handles.voltageoffset=initialsettings(4,2);
    handles.aqmodenumber=initialsettings(5,1);
    delete 'temporaryfile.txt';                         %Deletes temporary text file
    
    handles.calconstant = initialsettings(1,1);                    % Create handles for callibration constants
    handles.massoffset = initialsettings(1,2);
    
    handles.numberofdatapoints=numel(initialsettings(6:end,1));
    handles.datamaxx=max(initialsettings(6:end,1));              % Find max x of calibration data
    handles.datamaxy=max(initialsettings(6:end,2));              % Find max y of calibration data
    handles.dataminx=min(initialsettings(6:end,1));              % Find min x of calibration data
    handles.dataminy=min(initialsettings(6:end,2));              % Find min y of calibration data
    plot(handles.axes11,initialsettings(6:end,1),initialsettings(6:end,2),'.','MarkerSize',3)
    if handles.calconstant ~= 0;
        xlabel(handles.axes11,'m/q');
    elseif handles.calconstant == 0;
        xlabel(handles.axes11,'Time (s)');
    end
    axes(handles.axes11);
    if handles.dataminy~=handles.datamaxy;                                      % Checks if y max equals min for setting axes parameter
        axis([handles.dataminx handles.datamaxx handles.dataminy handles.datamaxy]);
    end   
    else
    warndlg('Load set-up for oscilloscope','Error');         %Tell user to load data if not
    handles.channelnum = 1;                                %Standard handles if no file loaded
    handles.channelname = 'channel1';
    handles.voltnum1 = 0.0200;
    handles.voltnum2 = 0.0200;
    handles.averagenum = 4;
    handles.timebasenum=5.0000e-009;
end

%handles for run
handles.filename = '';
handles.pumpbackground = 1;
handles.probebackground = 1;
handles.stagebackwards = 0;
handles.shutterpausetime = 4;
handles.noshutterpausetime = 0.8;
handles.scans = 6;
assignin('base', 'stopnow', false);

% Set delay stage default variables
handles.valuescanfromvalue = -500;            % Scan from value in femtoseconds
handles.valuexvalues  = []; 
handles.valuescantovalue = 500;               % Scan to value in femtoseconds  
handles.valueyvalues = []; 
handles.valuescannumb = 1;                    % Number of loops to scan
handles.valuestepsize = 100;                  % Stepsize between to and from stage values
handles.stagestepsize = 100;                  % Sets stage step size initially to 100 fs
handles.valueexpsteptovalue = 0;              % Sets initial exp step end point as 0 fs
handles.valueexpnoofstepsvalue = 0;           % Sets initial number of exponential steps to zero
handles.exponentialstepsvalue = 0;
handles.stagespeedvalue = 1;                    %Sets initial stage speed

%%


%reopen communication with oscilloscope
closeinstruments    %% is a function which close any instruments left open form previous sessions

%Create a VISA-USB object if it exists. my laptop
 handles.oscIntObj = instrfind('Type', 'visa-usb', 'RsrcName', 'USB0::0x0699::0x0366::C063853::INSTR' , 'Tag', '');



% Create the VISA-USB object if it does not exist
% otherwise use the object that was found.
if isempty(handles.oscIntObj)
    try
    handles.oscIntObj = visa('ni', 'USB0::0x0699::0x0366::C063853::INSTR');
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


%input initial settings with error warning if oscilloscope is not connected
try connect(handles.oscDevObj);
    set(handles.textdisplay,'String',['Oscilloscope Connected!']);
    disconnect(handles.oscDevObj);
        catch                                                                       % if there is an error this stops the whole program exiting
         handles.osc=[];                                                             % if there is no oscilloscope
         handles.oscFlag=0;                                                          % set to 0 to signal that oscilloscope is not connected
         warndlg('No Oscilloscope Connected. Please connect oscilloscope and restart programme', 'Warning !!');
end
connect(handles.oscDevObj);
set(handles.oscDevObj.Acquisition(1), 'Timebase', handles.timebasenum)
set(handles.oscDevObj.Channel(1), 'Scale', handles.voltnum1)
set(handles.oscDevObj.Channel(2), 'Scale', handles.voltnum2)
set(handles.oscDevObj.Trigger(1), 'Source', 'external')
set(handles.oscDevObj.Acquisition(1), 'NumberOfAverages', handles.averagenum)
disconnect(handles.oscDevObj);


%%


%Set boxes for exponential setps to be greyed out on opening as tick box not selected
set(handles.expstepto,'enable','off');
set(handles.expnoofsteps,'enable','off');
set(handles.text43,'enable','off');
set(handles.text44,'enable','off');

%Hides all items relevent to shutters
set(handles.uipanel8,'visible','off');
set(handles.uipanel2,'visible','off');
set(handles.text34,'visible','off');
set(handles.axes20,'visible','off');
set(handles.text35,'visible','off');
set(handles.axes22,'visible','off');
set(handles.text25,'visible','off');
set(handles.axes13,'visible','off');
set(handles.text26,'visible','off');
set(handles.axes14,'visible','off');

handles.arduinoc = 0; %value which confirms not to look for shutters in run

handles.output = hObject;

guidata(hObject, handles);

function varargout = TOFRUN2_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% Disconnect arduino and stage when the programme is closed
function figure1_CloseRequestFcn(hObject, eventdata, handles)
global stage                                                    % get hardware handles
delete(hObject);                                                % close window
if ~isempty(stage)
    CloseConnection(stage);
    stage=[];
end                                                             % stop stage
delete(instrfind({'Port'},{'COM7'}));                           % disconnect arduino


%%



%Load data to set up run
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
[file,path,filterIndex]=uigetfile('*.txt');
if file~=0;                                         % If file seclected
    loadsettings=load(fullfile(path,file));
    handles.loadsettings=loadsettings;
    handles.channelnum = loadsettings(2,1);         % Create handles for oscilloscope settings
    if handles.channelnum == 1;
        handles.channelname = 'channel1';
    elseif handles.channelnum == 2;
        handles.channelname = 'channel2';
    end
    handles.voltnum1 = loadsettings(2,2);
    handles.averagenum = loadsettings(3,1);
    handles.timebasenum = loadsettings(3,2);
    handles.voltnum2 = loadsettings(4,1);
    handles.voltageoffset = loadsettings(4,2);
    handles.aqmodenumber = loadsettings(5,1);

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
    set(handles.oscDevObj.Channel(1), 'Scale', handles.voltnum1)
    set(handles.oscDevObj.Channel(2), 'Scale', handles.voltnum2)
    set(handles.oscDevObj.Trigger(1), 'Source', 'external') 
    set(handles.oscDevObj.Acquisition(1), 'NumberOfAverages', handles.averagenum)
    if handles.aqmodenumber == 1;
        set(handles.oscDevObj.Acquisition(1), 'Mode', 'SAMPLE');
    elseif handles.aqmodenumber == 2;
        set(handles.oscDevObj.Acquisition(1), 'Mode', 'AVERAGE');
    end
    disconnect(handles.oscDevObj);
    
    cla (handles.axes11);                       % Clear axis from previous run
    cla (handles.axes13);
    cla (handles.axes14);
    cla (handles.axes19);
    cla (handles.axes20);
    cla (handles.axes22);
    
    handles.calconstant = loadsettings(1,1);                    % Create handles for callibration constants
    handles.massoffset = loadsettings(1,2);
    
    handles.numberofdatapoints=numel(loadsettings(6:end,1));
    handles.datamaxx=max(loadsettings(6:end,1));              % Find max x of calibration data
    handles.datamaxy=max(loadsettings(6:end,2));              % Find max y of calibration data
    handles.dataminx=min(loadsettings(6:end,1));              % Find min x of calibration data
    handles.dataminy=min(loadsettings(6:end,2));              % Find min y of calibration data
    plot(handles.axes11,loadsettings(6:end,1),loadsettings(6:end,2),'.','MarkerSize',3)
    axes(handles.axes11);
    if handles.dataminy~=handles.datamaxy;                                      % Checks if y max equals min for setting axes parameter
        axis([handles.dataminx handles.datamaxx handles.dataminy handles.datamaxy]);
    end
end
handles.loadeddata=1;           % For main run, fail safe to say data has been loaded successfully
guidata(hObject, handles);


% Choose to have shutters connected or not
function arduinochoice_Callback(hObject, eventdata, handles)
button_state = get(hObject,'Value');
if button_state == get(hObject,'Max') % toggle button is pressed
    set(handles.uipanel8,'visible','on'); %Turns on all items relevent to shutters
    set(handles.uipanel2,'visible','on');
    set(handles.text34,'visible','on');
    set(handles.axes20,'visible','on');
    set(handles.text35,'visible','on');
    set(handles.axes22,'visible','on');
    set(handles.text25,'visible','on');
    set(handles.axes13,'visible','on');
    set(handles.text26,'visible','on');
    set(handles.axes14,'visible','on');
    set(handles.uipanel9,'visible','off'); %Turns off no shutter pause time
    set(hObject,'String','With Arduino'); %Sets text of toggle button
    handles.arduinoc = 1;
    errordlg('Please wait for arduino to connect before continuing');
    %Connect arduino and servo
    global inten 
    try
        handles.a = arduino('COM7');    %   define arduino on comport
        servoAttach(handles.a,9);       %   attach servo 1 on pin 9
        servoAttach(handles.a,10);      %   attach servo 2 on pin 10
        pause(0.1)
        servoWrite(handles.a,9,45); servoWrite(handles.a,10,135);    % turn all servos (ie.: reset to start position, both closed) [adjust angles as required after mounting]
        set(handles.textdisplay,'String',['Arduino Connected!']);                                 % show message that arduino connected successfully
    catch
        err = lasterror;
        errordlg(['Arduino Connection Error: ' err.message]);           %error message displayed when arduino fails to connect
        set(handles.arduinochoice,'Value',0); %Resets toggle 
        set(handles.uipanel8,'visible','off'); %Turns off all items relevent to shutters
        set(handles.uipanel2,'visible','off');
        set(handles.text34,'visible','off');
        set(handles.axes20,'visible','off');
        set(handles.text35,'visible','off');
        set(handles.axes22,'visible','off');
        set(handles.text25,'visible','off');
        set(handles.axes13,'visible','off');
        set(handles.text26,'visible','off');
        set(handles.axes14,'visible','off');
        set(handles.uipanel9,'visible','on'); %Turns on no shutter pause time
        set(hObject,'String','No Arduino'); %Sets text of toggle button
        handles.arduinoc = 0;
    end
elseif button_state == get(hObject,'Min') % toggle button is not pressed
    set(handles.uipanel8,'visible','off'); %Turns off all items relevent to shutters
    set(handles.uipanel2,'visible','off');
    set(handles.text34,'visible','off');
    set(handles.axes20,'visible','off');
    set(handles.text35,'visible','off');
    set(handles.axes22,'visible','off');
    set(handles.text25,'visible','off');
    set(handles.axes13,'visible','off');
    set(handles.text26,'visible','off');
    set(handles.axes14,'visible','off');
    set(handles.uipanel9,'visible','on'); %Turns on no shutter pause time
    set(hObject,'String','No Arduino'); %Sets text of toggle button
    handles.arduinoc = 0;
end
guidata(hObject, handles);


%%


% Connect the shutters manually
function reconnect_Callback(hObject, eventdata, handles)
try
    handles.a = arduino('COM7');               % Connects arduino on button press
    servoAttach(handles.a,9);                  % Connects to servo 9
    servoAttach(handles.a,10);                 % Connects to servo 10
    set(handles.textdisplay,'String',['Arduino Connected']);
    pause(0.1)
    servoWrite(handles.a,9,45); servoWrite(handles.a,10,135);    % turn all servos (ie.: reset to start position, both closed) [adjust angles as required after mounting]
catch
    err = lasterror;                                        % If connection fails
    errordlg(['Arduino Connection Error' err.message]);     % Create error message
end
guidata(hObject, handles);


% Disconnect the shutters manually
function discon1_Callback(hObject, eventdata, handles)
try
     delete(instrfind({'Port'},{'COM7'}));                  % Disconnects arduino on button press
catch
    err = lasterror;                                        % If disconnect fails
    errorldg(['Arduino Connection Error' err.message]);     % Create error message
end
guidata(hObject, handles);




% Set-up stage
function err=setupstage(handles)
global stage stageaxis stagevelocityindicator

err='';c='';b=10;
if isempty(stage)                                   %only do this if there isn't a stage already
    set(handles.stagetextdisplay,'String','setting up stage...')
    stage = Mercury_Controller();
    stage = InterfaceSetupDlg(stage);
    stage = InitializeController(stage);
    stageaxis = qSAI_ALL(stage);                    %talk to stage controller
    CST(stage,stageaxis,'M-403.62S')                %connect to stage 12S on other stage
    INI(stage,stageaxis);                           %initialise stage
    REF(stage,stageaxis);                           %move stage till it trips a reference switch(so it knows where it is)
    c=TranslateError(stage,qERR(stage));
    if qERR(stage)==1, c='Please restart MATLAB',end
    if ~IsConnected(stage)
        err=['Stage not connected: ' c];            %if it's not working, 
        %set(handles.runexp,'UserData') = 1;             %exit
    end
    while stage.isreferencing(stageaxis)
        pause(0.5),b=b-1;set(handles.stagevalue,'String',['wait...' num2str(b,'%11.0f')])
    end
    try load stagehome
    catch, home = qTMX(stage,stageaxis)/2;end
    MOV(stage,stageaxis,home)                       %go to default home
    stagepos(handles)                               %get stage position function
    DFH(stage,stageaxis);                           %Define this point as Home
    VEL(stage,stageaxis,3);                           %set velocity to max (3)
elseif stagevelocityindicator == 1;   %so as to not return to zero position when altering stage speed after setup
    stagevelocityindicator = 0;
else
    set(handles.stageslider,'Min',qTMN(stage,stageaxis))%set up slider.
    set(handles.stageslider,'Max',qTMX(stage,stageaxis))
    set(handles.stagevalue,'String','0'),set(handles.stageslider, 'Value' ,0)
end 

% Sends the stage to a position which the user specifies in femtoseconds
function gotoposition_Callback(hObject, eventdata, handles)
global stage stageaxis
err=setupstage(handles);%go to setupstage function
if isempty(err); 
    GoToCC=str2double(get(hObject,'String'))*-0.0002998; %get the value in mm
    min=round(qTMN(stage,stageaxis));            	%get min and max stage values
    max=round(qTMX(stage,stageaxis));
    if isnan(GoToCC)||GoToCC<min||GoToCC>max;
        errordlg('Input must be a number not larger than the ends of the stage','Error');
    end
    MOV(stage,stageaxis,GoToCC); stagepos(handles)	%move stage
end

function gotoposition_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%Temporarily changes stage speed
function stagespeed_Callback(hObject, eventdata, handles)
global stage stageaxis stagevelocityindicator
stagevelocityindicator = 1;         %to specify to setupstage not to return stage to zero position when changing velocity
err=setupstage(handles);                            % go to setupstage function
if isempty(err)                                     % if everything is good
    VEL(stage,stageaxis,(3*handles.stagespeedvalue));   
else set(handles.stagetextdisplay,'String',err)          % display error on UI
end
guidata(hObject,handles)


%Set value for stage speed
function setspeedvalue_Callback(hObject, eventdata, handles)
stagespeedvalue=str2double(get(hObject,'String'));                       % Get input exp end point
if isnan(stagespeedvalue);                                               % if it's not a number
    stagespeedvalue = handles.stagespeedvalue;                    % reset value
    set(hObject, 'String', stagespeedvalue);                             % reset editbox
    errordlg('Stage speed must be a number','Error');           % display an error message
end
if sign(stagespeedvalue)<=0 || stagespeedvalue>1;                                             % if it's negative or not a number
    stagespeedvalue = handles.stagespeedvalue;                    % reset value
    set(hObject, 'String', stagespeedvalue);                             % reset editbox
    errordlg('Stage speed must be positive and equal to or less than 1','Error');           % display an error message
end
handles.stagespeedvalue = stagespeedvalue;                        % Set handle for the value
guidata(hObject,handles)
function setspeedvalue_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




%%

%Stage slider
function stageslider_Callback(hObject, eventdata, handles)
global stage stageaxis
pos=get(hObject,'Value');                           % get slider value
err=setupstage(handles);                            % go to setupstage function
if isempty(err)                                     % if everything is good
    MOV(stage,stageaxis,-pos);                      % move stage to the slider position
    stagepos(handles)                               % go to the stagepos function
else set(handles.stagetextdisplay,'String',err)          % display error on UI
end

function stageslider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% Stage home button
function stagehome_Callback(hObject, eventdata, handles)
global stage stageaxis
err=setupstage(handles);                            % go to setupstage function
if isempty(err)                                     % if everything is good
    GOH(stage,stageaxis);                           % go to home position
    stagepos(handles)                               % go to the stagepos function
else set(handles.stagetextdisplay,'String',err)          % display the error on the UI
end


% Set new home position
function stagesethome_Callback(hObject, eventdata, handles)
global stage stageaxis
h=questdlg('Set the current stage position as the new Zero point?','','Yes, for this session only','Yes, and set as new default value','No','Yes, for this session only');
if ~strcmp(h,'No')
    err=setupstage(handles);                        % go to setupstage function
    if isempty(err)                                 % if everything is good
        DFH(stage,stageaxis);                       % Define Home
        stagepos(handles)                          	% go to the stagepos function
        if strcmp(h,'Yes, and set as new default value')
            home=-qTMN(stage,stageaxis);          	% Get new home value
            save stagehome home                    	% save new value
        end
    end
end

% Size of stage step
function stagestepsizebox_Callback(hObject, eventdata, handles)
stagestepsize=str2double(get(hObject,'String'));                        % Get input stage step size
if isnan(stagestepsize);                                                % if it's not a number
    stagestepsize = handles.stagestepsize;                              % reset value
    set(hObject, 'String', stagestepsize);                              % reset editbox
    errordlg('Stage step size must be a number','Error');               % display an error message
end
if round(stagestepsize)-stagestepsize~=0;                               % if not an integer
    stagestepsize = handles.stagestepsize;                              % reset value
    set(hObject, 'String', stagestepsize);                              % reset editbox
    errordlg('Stage step size must be an integer','Error');             % display an error message
end
handles.stagestepsize = stagestepsize;           % Save the new stage step size
guidata(hObject,handles)

function stagestepsizebox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Sets value for stage to travel to
function scantovalue_Callback(hObject, eventdata, handles)
scantovalue=str2double(get(hObject,'String'));      % get the new scantovalue value
if isnan(scantovalue)                               % if it's not a number
    scantovalue = handles.valuescantovalue;        % reset value
    set(hObject, 'String', scantovalue);            % reset editbox
    errordlg('Input must be a number','Error');     % display an error message
end
handles.valuescantovalue = scantovalue;            % Save the new scantovalue
guidata(hObject,handles)

function scantovalue_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% Sets value for stage to travel from
function scanfromvalue_Callback(hObject, eventdata, handles)
scanfromvalue=str2double(get(hObject,'String'));  	% get the new scanfromvalue value
if isnan(scanfromvalue)                             % if it's not a number
    scanfromvalue = handles.valuescanfromvalue;    % reset value
    set(hObject, 'String', scanfromvalue);          % reset editbox
    errordlg('Input must be a number','Error');     % display an error message
end
handles.valuescanfromvalue = scanfromvalue;        % Save the new scanfromvalue value
guidata(hObject,handles)

function scanfromvalue_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% Sets size of step between start and end point of scan
function stepsize_Callback(hObject, eventdata, handles)
stepsize=str2double(get(hObject,'String'));                             % get the new stepsize value
if isnan(stepsize)||stepsize<=0.5                                       % if it's negative or not a number
    stepsize = handles.valuestepsize;                                  % reset value
    set(hObject, 'String', stepsize);                                   % reset editbox
    errordlg('Input must be a number greater than 0.5 fs','Error');     % display an error message
end
handles.valuestepsize = stepsize; guidata(hObject,handles)             % Save the new stepsize value
%stagepos(handles)

function stepsize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Set number of scans to be taken
function scannumb_Callback(hObject, eventdata, handles)
scannumb=str2double(get(hObject,'String'));                             % Get input scan number
if isnan(scannumb);                                                     % if it's not a number
    scannumb = handles.valuescannumb;                                  % reset value
    set(hObject, 'String', scannumb);                                   % reset editbox
    errordlg('Number of scans must be a number','Error');               % display an error message
end
if round(scannumb)-scannumb~=0;                                         % if not an integer
    scannumb = handles.valuescannumb;                                  % reset value
    set(hObject, 'String', scannumb);                                   % reset editbox
    errordlg('Number of scans must be an integer','Error');             % display an error message
end
if sign(scannumb)<=0.9;                                                 % if it's negative or not a number
    scannumb = handles.valuescannumb;                                  % reset value
    set(hObject, 'String', scannumb);                                   % reset editbox
    errordlg('Number of scans must be a positive integer','Error');     % display an error message
end
handles.valuescannumb = scannumb;                                      % Set handle for the value
guidata(hObject,handles)

function scannumb_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%%




% Checks if user is wanting to add exponential steps to the run
function exponentialsteps_Callback(hObject, eventdata, handles)
exponentialstepsvalue= get(hObject,'Value');                             %checks if selected or not, 1 selected, 0 not
handles.exponentialstepsvalue=exponentialstepsvalue;
if exponentialstepsvalue==1,
    set(handles.expstepto,'enable','on');
    set(handles.expnoofsteps,'enable','on');
    set(handles.text43,'enable','on');
    set(handles.text44,'enable','on');
else
    set(handles.expstepto,'enable','off');
    set(handles.expnoofsteps,'enable','off');
    set(handles.text43,'enable','off');
    set(handles.text44,'enable','off');
end 
guidata(hObject, handles);

% Set end point for exponential steps
function expstepto_Callback(hObject, eventdata, handles)
valueexpsteptovalue=str2double(get(hObject,'String'));                          % Get input exp end point
if isnan(valueexpsteptovalue);                                                  % if it's not a number
    valueexpsteptovalue = handles.valueexpsteptovalue;                          % reset value
    set(hObject, 'String', valueexpsteptovalue);                                % reset editbox
    errordlg('Exponential steps end point must be a number','Error');           % display an error message
end
if round(valueexpsteptovalue)-valueexpsteptovalue~=0;                           % if not an integer
    valueexpsteptovalue = handles.valueexpsteptovalue;                          % reset value
    set(hObject, 'String', valueexpsteptovalue);                                % reset editbox
    errordlg('Exponential steps end point must be an integer','Error');         % display an error message
end
handles.valueexpsteptovalue = valueexpsteptovalue;                              % Set handle for the value
guidata(hObject,handles)

function expstepto_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function expnoofsteps_Callback(hObject, eventdata, handles)
valueexpnoofstepsvalue=str2double(get(hObject,'String'));                       % Get input exp end point
if isnan(valueexpnoofstepsvalue);                                               % if it's not a number
    valueexpnoofstepsvalue = handles.valueexpnoofstepsvalue;                    % reset value
    set(hObject, 'String', valueexpnoofstepsvalue);                             % reset editbox
    errordlg('Exponential number of steps must be a number','Error');           % display an error message
end
if round(valueexpnoofstepsvalue)-valueexpnoofstepsvalue~=0;                     % if not an integer
    valueexpnoofstepsvalue = handles.valueexpnoofstepsvalue;                    % reset value
    set(hObject, 'String', valueexpnoofstepsvalue);                             % reset editbox
    errordlg('Exponential number of steps must be an integer','Error');         % display an error message
end
if sign(valueexpnoofstepsvalue)<=0;                                             % if it's negative or not a number
    valueexpnoofstepsvalue = handles.valueexpnoofstepsvalue;                    % reset value
    set(hObject, 'String', valueexpnoofstepsvalue);                             % reset editbox
    errordlg('Exponential number of steps must be positive','Error');           % display an error message
end
handles.valueexpnoofstepsvalue = valueexpnoofstepsvalue;                        % Set handle for the value
guidata(hObject,handles)

function expnoofsteps_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%%

% Set-up stage position tracker
function stagepos(handles)                          %get stage position function
global stage stageaxis                              %set up variables
%set up slider
max=-qTMN(stage,stageaxis);                         %get min and max stage values
min=-qTMX(stage,stageaxis);
step=handles.stagestepsize*0.0002998/(max-min);      %get slider step size
set(handles.stageslider,'Min',min)                  %set min and max stage values
set(handles.stageslider,'Max',max)
set(handles.stageslider,'SliderStep',[step step*10])%set slider step size

%display dynamic position while stage is moving
while stage.ismoving(stageaxis)
    a=qPOS(stage,stageaxis);                        %get current position in mm
    set(handles.stagevalue,'String',num2str(a/-0.0002998,'%11.0f')) %%%%%%%%%%%%%%%%%%%%%%%note changed from 0.00015
    set(handles.stageslider,'Value',-a)             %display it on slider and txt
    pause(0.05);                                    %wait until stage has finished moving
end

%%display position and limits once stage has stopped
a=qPOS(stage,stageaxis);                            %get final position in mm
set(handles.stageslider,'Value',-a)                 %set slider
set(handles.stagevalue,'String',num2str(a/-0.0002998,'%11.0f'))%display position
b=TranslateError(stage,qERR(stage));                %get any errors
set(handles.stagetextdisplay,'String',['Final Position: ' num2str(a/-0.0002998,'%11.0f') ...
    ' fs. Stage can be moved between: ' num2str(min/0.0002998,'%11.0f')...
    ' and ' num2str(max/0.0002998,'%11.0f') '. ' b])  	%display stage limits





%Shutter control
%Pump Shutter
function pumpshutter_Callback(hObject, eventdata, handles)
button_state = get(hObject,'Value');
if button_state == get(hObject,'Max') % toggle button is pressed
    pause(0.1);
    servoWrite(handles.a,9,135);    % turns pump shutter to open
    pause(0.1);
    set(hObject,'String','Pump Open'); %Sets text of toggle button
elseif button_state == get(hObject,'Min') % toggle button is not pressed
    pause(0.1);
    servoWrite(handles.a,9,45);     % turns pump shutter to closed
    pause(0.1);
    set(hObject,'String','Pump Closed'); % Sets text of toggle button
end

% Probe Shutter
function probeshutter_Callback(hObject, eventdata, handles)
button_state = get(hObject,'Value');
if button_state == get(hObject,'Max') % toggle button is pressed
    pause(0.1);
    servoWrite(handles.a,10,45);    % turns probe shutter to open
    pause(0.1);
    set(hObject,'String','Probe Open'); %Sets text of toggle button
elseif button_state == get(hObject,'Min') % toggle button is not pressed
    pause(0.1);
    servoWrite(handles.a,10,135);     % turns probe shutter to closed
    pause(0.1);
    set(hObject,'String','Probe Closed'); % Sets text of toggle button
end

%Background readings options
%Pump background selection for rum
function pumpbackground_Callback(hObject, eventdata, handles)
pumpbackground= get(hObject,'Value');                            %checks if selected or not, 1 selected, 0 not
handles.pumpbackground=pumpbackground;
if handles.pumpbackground==1;   %only shows axes if plotting pump background
    set(handles.axes13,'visible','on')
    set(handles.text25,'visible','on')
    set(handles.axes20,'visible','on')
    set(handles.text34,'visible','on')
else
    set(handles.axes13,'visible','off') 
    set(handles.text25,'visible','off')
    set(handles.axes20,'visible','off')
    set(handles.text34,'visible','off')
end
guidata(hObject, handles);


%Probe background selection for run
function probebackground_Callback(hObject, eventdata, handles)
probebackground= get(hObject,'Value');                            %checks if selected or not, 1 selected, 0 not
handles.probebackground=probebackground;
if handles.probebackground==1;  %only shows axes if plotting probe background
    set(handles.axes14,'visible','on')
    set(handles.text26,'visible','on')
    set(handles.axes22,'visible','on')
    set(handles.text35,'visible','on')
else
    set(handles.axes14,'visible','off') 
    set(handles.text26,'visible','off')
    set(handles.axes22,'visible','off')
    set(handles.text35,'visible','off')
end
guidata(hObject, handles);

%Run the stage in reverse to values entered option
function stagebackwards_Callback(hObject, eventdata, handles)
stagebackwards= get(hObject,'Value');                             %checks if selected or not, 1 selected, 0 not
handles.stagebackwards=stagebackwards;
guidata(hObject, handles);


%Shutter pause time set by the user, after movement, before continuing with run and
%collecting date
function shutterpausetime_Callback(hObject, eventdata, handles)
shutterpausetime=str2double(get(hObject,'String'));                             % Get input shutter pause time
if isnan(shutterpausetime);                                                     % if it's not a number
    shutterpausetime = handles.shutterpausetime;                                % reset value
    set(hObject, 'String', shutterpausetime);                                   % reset editbox
    errordlg('Shutter pause time must be a number','Error');                    % display an error message
end
if sign(shutterpausetime)<=0.1;                                                 % if it's negative or not a number
    shutterpausetime = handles.shutterpausetime;                                % reset value
    set(hObject, 'String', shutterpausetime);                                   % reset editbox
    errordlg('Shutter pause time must be greater than 0.1s','Error');           % display an error message
end
handles.shutterpausetime = shutterpausetime;                                    % Set handle for the value
guidata(hObject,handles)

function shutterpausetime_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Pause time if shutters not in set-up
function noshutterpausetime_Callback(hObject, eventdata, handles)
noshutterpausetime=str2double(get(hObject,'String'));                             % Get input shutter pause time
if isnan(noshutterpausetime);                                                     % if it's not a number
    noshutterpausetime = handles.noshutterpausetime;                                % reset value
    set(hObject, 'String', noshutterpausetime);                                   % reset editbox
    errordlg('Pause time must be a number','Error');                    % display an error message
end
if sign(noshutterpausetime)<=0.1;                                                 % if it's negative or not a number
    noshutterpausetime = handles.noshutterpausetime;                                % reset value
    set(hObject, 'String', noshutterpausetime);                                   % reset editbox
    errordlg('Pause time must be greater than 0.1s','Error');           % display an error message
end
handles.noshutterpausetime = noshutterpausetime;                                    % Set handle for the value
guidata(hObject,handles)

function noshutterpausetime_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%
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













% Stops experiment run
function expstop_Callback(hObject, eventdata, handles)
h=questdlg('How would you like to stop?','Stop at end of run','Stop at end of run','Stop immediately','Cancel','Cancel');
if strcmp(h,'Stop at end of run');
    set(handles.runexp,'UserData',0);                                                         %sets user data to show stop button has been pressed  
    set(handles.textdisplay,'string',['Stop button pressed, completing most recent scan'])    %states that stop button has been pressed and will complete last scan
elseif strcmp(h,'Stop immediately');
    assignin('base','stopnow', true);
    set(handles.runexp,'UserData',0);  
    set(handles.textdisplay,'string',['Stop button pressed, scan stopped immediately'])    
elseif strcmp(h,'Cancel');
end
guidata(hObject, handles);

% Runs main experiment
function runexp_Callback(hObject, eventdata, handles)
global stage stageaxis 
assignin('base', 'stopnow', false); %reset stop check
if handles.loadeddata==0;
    errordlg('Must load settings before running','Error');    %display an error message
    return
end 
if handles.valuescannumb==0;                                         % if scan number set to zero still
    errordlg('Must set number of scans before running','Error');    %display an error message
    return
end
if handles.valuescanfromvalue==0 && handles.valuescantovalue==0;              % if scan to and from  both zero
    errordlg('Must set scan to and from values before running','Error');    %display an error message
    return
elseif handles.valuescanfromvalue==handles.valuescantovalue;                  % If scan to and from equal
    errordlg('Must set different scan to and from values before running','Error');    %display an error message
    return
end
if handles.valuestepsize==0;                                        % if stepsize set to zero 
    errordlg('Must set scan stepsize value before running','Error');    %display an error message
    return
end

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

%Timesteps
handles.timestep=handles.valuescanfromvalue : handles.valuestepsize : handles.valuescantovalue;          % Create timestep array
handles.timestep=handles.timestep(:);                                                                    % Collumn for saving    
[timesteplength,timestepwidth]=size(handles.timestep);
handles.nolinearsteps=timesteplength;
% Set-up tick labels for main plot
handles.timestepyticklabels=cell(timesteplength,1);                                                      % Empty cell array the same length as timestep
if handles.stagebackwards==1;
    timestepcell=num2cell(((-1)*(handles.timestep)));
else
    timestepcell=num2cell(handles.timestep);
end
handles.timestepyticklabels(1:4:timesteplength)=timestepcell(1:4:timesteplength);                        % Inserts values every 4th tick mark for plotting
% Exponential steps
if handles.exponentialstepsvalue == 1;                                                                        % If additional exponential steps selected
    if handles.valuescantovalue == 0;
        additionalexponentialsteps = round(logspace(log10(1),log10(handles.valueexpsteptovalue),handles.valueexpnoofstepsvalue));  %Create specified number of log steps from just above zero to exp step end point
    else
        additionalexponentialsteps = round(logspace(log10(handles.valuescantovalue),log10(handles.valueexpsteptovalue),handles.valueexpnoofstepsvalue));  %Create specified number of log steps from end of scan to exp step end point
    end
    additionalexponentialsteps = additionalexponentialsteps(:,2:end);                                    % remove repeated last point
    additionalexponentialsteps=additionalexponentialsteps(:);                                            % Collumn vector
    [additionalexponentialstepslength,additionalexponentialstepswidth]=size(additionalexponentialsteps); % Size of additional steps vector
    handles.timestepyticklabelsexp=cell(additionalexponentialstepslength,1);                             % Empty cell to store tick labels
    if handles.stagebackwards==1
        additionalexponentialsteps=-additionalexponentialsteps;
        handles.timestepyticklabelsexp(1:4:additionalexponentialstepslength) = num2cell(additionalexponentialsteps(1:4:additionalexponentialstepslength));      % Every 4th value of log steps included on scale
        additionalexponentialsteps=-additionalexponentialsteps;
    else
        handles.timestepyticklabelsexp(1:4:additionalexponentialstepslength) = num2cell(additionalexponentialsteps(1:4:additionalexponentialstepslength));      % Every 4th value of log steps included on scale
    end
    handles.timestep = [handles.timestep;additionalexponentialsteps];                                    % add exponential steps to end of current steps
    handles.timestepyticklabels =[handles.timestepyticklabels;handles.timestepyticklabelsexp;cell(1,1)]; % Concatanates cells with empty cell at end
    [timesteplength,timestepwidth]=size(handles.timestep);                                               % Gets the new size for timesteps with exponential steps
    handles.timestepyticklabels(timesteplength)=num2cell(handles.valueexpsteptovalue);                   % Ensure exp scan to value shows on plot
    timesteppcolorvalues = handles.valuescanfromvalue : handles.valuestepsize : handles.valuescantovalue;   %For saving timesteps later in main run
    timesteppcolorvalues = timesteppcolorvalues(:);
    timesteppcolorvalues = [timesteppcolorvalues; additionalexponentialsteps];
else
    handles.timestepyticklabels =[handles.timestepyticklabels;cell(1,1)];
    timesteppcolorvalues = handles.valuescanfromvalue : handles.valuestepsize : handles.valuescantovalue;
end

a = -0.0002998*(handles.timestep);            % Set-up time steps from femtoseconds to micrometers
if handles.stagebackwards==1 % if the stage is set to run backwards, the values must be reversed for the stage to read
    a=-a;
end

try connect(handles.oscDevObj);
    disconnect(handles.oscDevObj);
        catch                                                                       % if there is an error this stops the whole program exiting
        handles.osc=[];                                                             % if there is no oscilloscope
        handles.oscFlag=0;                                                          % set to 0 to signal that oscilloscope is not connected
        errordlg('No Oscilloscope Connected. Please connect oscilloscope and run again', 'Warning !!');
    return
end

% Get x data for plots
connect(handles.oscDevObj);
[X] = invoke(handles.oscDevObj.Waveform(1), 'readxwaveform', handles.channelname);
disconnect(handles.oscDevObj);
X=X(:);
Xmin=min(X);                                    % Find X min
Xpos=X-Xmin;                                    % Make scale positive
if handles.calconstant ~= 0;
    handles.xdata=((((Xpos((2501-handles.numberofdatapoints):end)).^2)*handles.calconstant)+handles.massoffset);  % Select relevent region of x data and convert to m/q
elseif handles.calconstant == 0;
    handles.xdata=X((2501-handles.numberofdatapoints):end);  % Select relevent region of x data with no conversion
end
handles.xdatamax=max(handles.xdata);
handles.xdatamin=min(handles.xdata);


%arduino check
if handles.arduinoc==1;
    try
        servoWrite(handles.a,9,135); servoWrite(handles.a,10,135);    % turn all servos to 135 deg (ie.: reset to start position, both closed) [adjust angles as required after mounting]
    catch
        err = lasterror;
        errordlg(['Arduino Connection Error: ' err.message]);           %error message displayed when arduino fails to connect
    end
end

cla (handles.axes11);                            % Clear axis from previous run
cla (handles.axes13);
cla (handles.axes14);
cla (handles.axes19);
cla (handles.axes20);
cla (handles.axes22);

%Set up handles for main run

%handles to store gated region data in collumnvectors. Each collumn is the
%y data at a particular translation stage position.
if handles.pumpbackground==1 && handles.arduinoc==1;
    handles.previouspumpdata=zeros(handles.numberofdatapoints,1);
end
if handles.probebackground==1 && handles.arduinoc==1;
    handles.previousprobedata=zeros(handles.numberofdatapoints,1);
end
handles.previouspumpprobedata=zeros(handles.numberofdatapoints,1);


%handles to store continuous ovservation of each gated region integration
%over all timesteps, so as to observe any decay of the signal
if handles.pumpbackground==1 && handles.arduinoc==1;
    handles.previouspumpintegrateddata=[0];
end
if handles.probebackground==1 && handles.arduinoc==1;
    handles.previousprobeintegrateddata=[0];
end
handles.previouspumpprobeintegrateddata=[0];

%handles for saving data and intensity plot
handles.itterationdata=zeros(handles.numberofdatapoints,(3*timesteplength));
handles.plotdata=zeros(handles.numberofdatapoints,(timesteplength+1));
handles.continuousreadingplotxdata=zeros(1,timesteplength);

% Name file for timestep data
yfilenamedatatxt=strcat(handles.filename,'_',datestr(now,'dd_mm_yyyy'),'_timestepdata','.txt');
yrawdataname=fullfile(handles.filedirectory,yfilenamedatatxt);              %Includes file directory
    
%Set stagestepsizebox equal to valuestepsizevalue for the duaration of the
%run
handles.stagestepsize=handles.valuestepsize;


if get(handles.runexp,'UserData')==1, 
    return; 
end
set(handles.runexp,'UserData',1);
VEL(stage,stageaxis,3);                     %set stagespeed to max   
set(handles.setspeedvalue,'string',1);
set(handles.setspeedvalue,'enable','off'); %don't allow changes to stage speed in middle of run
set(handles.stagespeed,'enable','off');

j=1;
%start routine loop
while j<= handles.valuescannumb && (get(handles.runexp,'UserData') ~= 0);                           %checks if number of steps has been reached or stop button pressed
    set(handles.textdisplay,'string',['Scan ' num2str(j) ' of ' num2str(handles.valuescannumb)])    %display scan number in text display
for  i=1:length(a)
    %Check imediate stop
    if evalin('base', 'stopnow') == true;
        set(handles.setspeedvalue,'enable','on'); %reallow changing stage seppd
        set(handles.stagespeed,'enable','on');
        return
    end
    %move stage
      MOV(stage,stageaxis,a(i))                       %move the stage to next position
      while stage.ismoving(stageaxis)                  %Check if stage is moving
        pause(0.05)                                         %wait a bit
      end
      pos=qPOS(stage,stageaxis);                      %get current position in mm
      stagepos(handles)
    
      %Check imediate stop
    if evalin('base', 'stopnow') == true;
        set(handles.setspeedvalue,'enable','on'); %reallow changing stage speed
        set(handles.stagespeed,'enable','on');
        return
    end

%step 1 (pump shutter open) 
    if handles.pumpbackground==1 && handles.arduinoc==1;
    servoWrite(handles.a,9,135); servoWrite(handles.a,10,135);   %shutter routine (for commented version see shutter section)
    set(handles.pumpshutter,'Value',1); set(handles.probeshutter,'Value',0)
    set(handles.pumpshutter,'String','Pump Open'); set(handles.probeshutter,'String','Probe Closed')
    pause(handles.shutterpausetime)
    connect(handles.oscDevObj);
    [Y] = invoke(handles.oscDevObj.Waveform(1), 'readwaveforms', handles.channelname, handles.scans);
    disconnect(handles.oscDevObj);
    if handles.scans > 1;
        Y=mean(Y);
    end
    Y=Y(:);
    handles.Ydatapump=Y((2501-handles.numberofdatapoints):end);        % Select relevent region of y data         
    handles.Ydatapump=handles.Ydatapump-handles.voltageoffset;        %account for zero offset
    handles.Ydatapumpmax=max(handles.Ydatapump);
    handles.Ydatapumpmin=min(handles.Ydatapump);
    cla(handles.axes13);
    plot(handles.axes13,handles.xdata,handles.Ydatapump,'.','MarkerSize',3)  %Plots m/q versus voltage
    if handles.calconstant ~= 0;
        xlabel(handles.axes13,'m/q');
    elseif handles.calconstant == 0;
        xlabel(handles.axes13,'Time (s)');
    end
    ylabel(handles.axes13,'Intensity (V)');
    axes(handles.axes13);
    axis([handles.xdatamin handles.xdatamax handles.Ydatapumpmin handles.Ydatapumpmax]);
   %Continuous plot of average pump
    handles.pumpintegratedydata=sum(handles.Ydatapump);                                 %sum y to get area under curve of pump
    handles.pumpintegrateddata=[handles.previouspumpintegrateddata,handles.pumpintegratedydata];
    handles.previouspumpintegrateddata=handles.pumpintegrateddata;
    plot(handles.axes20,handles.previouspumpintegrateddata(2:end))            %Plots pump integration continuously 
    set(handles.axes20, 'XTickLabelMode', 'manual', 'XTickLabel', []);
    set(handles.axes20, 'YTickLabelMode', 'manual', 'XTickLabel', []);
    handles.pumpdata=[handles.previouspumpdata,handles.Ydatapump];            %add to set of previous data for pump
    handles.previouspumpdata=handles.pumpdata;
    hold on
    end
    
    pause(0.1)
    
    %Check imediate stop
    if evalin('base', 'stopnow') == true;
        set(handles.setspeedvalue,'enable','on'); %reallow changing stage speed
        set(handles.stagespeed,'enable','on');
        return
    end 
 %step 2 (probe shutter open)
    if handles.probebackground==1 && handles.arduinoc==1;
    servoWrite(handles.a,9,45); servoWrite(handles.a,10,45);
    set(handles.pumpshutter,'Value',0); set(handles.probeshutter,'Value',1)
    set(handles.pumpshutter,'String','Pump Closed'); set(handles.probeshutter,'String','Probe Open')
    pause(handles.shutterpausetime)
    connect(handles.oscDevObj);
    [Y] = invoke(handles.oscDevObj.Waveform(1), 'readwaveforms', handles.channelname, handles.scans);
    disconnect(handles.oscDevObj);
    if handles.scans > 1;
        Y=mean(Y);
    end
    Y=Y(:);
    handles.Ydataprobe=Y((2501-handles.numberofdatapoints):end);                                                % Select relevent region of y data         
    handles.Ydataprobe=handles.Ydataprobe-handles.voltageoffset;      %account for zero offset
    handles.Ydataprobemax=max(handles.Ydataprobe);
    handles.Ydataprobemin=min(handles.Ydataprobe);
    cla (handles.axes14);
    plot(handles.axes14,handles.xdata,handles.Ydataprobe,'.','MarkerSize',3)  %Plots m/q versus voltage
    if handles.calconstant ~= 0;
        xlabel(handles.axes14,'m/q');
    elseif handles.calconstant == 0;
        xlabel(handles.axes14,'Time (s)');
    end
    ylabel(handles.axes14,'Intensity (V)');
    axes(handles.axes14);
    axis([handles.xdatamin handles.xdatamax handles.Ydataprobemin handles.Ydataprobemax]);   
    %Continuous plot of average probe
    handles.probeintegratedydata=sum(handles.Ydataprobe);                                 %sum y to get area under curve
    handles.probeintegrateddata=[handles.previousprobeintegrateddata,handles.probeintegratedydata];
    handles.previousprobeintegrateddata=handles.probeintegrateddata;
    plot(handles.axes22,handles.previousprobeintegrateddata(2:end))            %Plots probe integration continuously 
    set(handles.axes22, 'XTickLabelMode', 'manual', 'XTickLabel', []);
    set(handles.axes22, 'YTickLabelMode', 'manual', 'XTickLabel', []);
    handles.probedata=[handles.previousprobedata,handles.Ydataprobe];            %add to set of previous data for probe
    handles.previousprobedata=handles.probedata;
    hold on
    end
    pause(0.1)
    
    %Check imediate stop
    if evalin('base', 'stopnow') == true;
        set(handles.setspeedvalue,'enable','on');  %reallow changing stage speed
        set(handles.stagespeed,'enable','on');
        return
    end
 %step 3 (Pump and Probe shutters open) 
    if handles.arduinoc==1;
        servoWrite(handles.a,9,135); servoWrite(handles.a,10,45);   %shutter routine (for commented version see shutter section)
        set(handles.pumpshutter,'Value',1); set(handles.probeshutter,'Value',1);
        set(handles.pumpshutter,'String','Pump Open'); set(handles.probeshutter,'String','Probe Open');
        pause(handles.shutterpausetime);
    else
        pause(handles.noshutterpausetime);
    end
    connect(handles.oscDevObj);
    [Y] = invoke(handles.oscDevObj.Waveform(1), 'readwaveforms', handles.channelname, handles.scans);
    disconnect(handles.oscDevObj);
    if handles.scans > 1;
        Y=mean(Y);
    end
    Y=Y(:);
    handles.Ydata=Y((2501-handles.numberofdatapoints):end);                                                % Select relevent region of y data         
    handles.Ydata=handles.Ydata-handles.voltageoffset;  %account for zero offset
    handles.Ydatamax=max(handles.Ydata);              % Find max of y data
    handles.Ydatamin=min(handles.Ydata);              % Find min of y data
    cla(handles.axes11);
    plot(handles.axes11,handles.xdata,handles.Ydata,'.','MarkerSize',3)  %Plots m/q versus voltage full trace
    axes(handles.axes11);
    axis([handles.xdatamin handles.xdatamax handles.Ydatamin handles.Ydatamax]);      % Resize axis to max and min values of x and y
    if handles.calconstant ~= 0;
        xlabel(handles.axes11,'m/q');
    elseif handles.calconstant == 0;
        xlabel(handles.axes11,'Time (s)');
    end
    ylabel(handles.axes11,'Intensity (V)');
    %Continuous plot of average pump-probe
    handles.pumpprobeintegratedydata=sum(handles.Ydata);                                 %sum y to get area under curve
    handles.pumpprobeintegrateddata=[handles.previouspumpprobeintegrateddata,handles.pumpprobeintegratedydata];
    handles.previouspumpprobeintegrateddata=handles.pumpprobeintegrateddata;
    plot(handles.axes19,handles.previouspumpprobeintegrateddata(2:end))            %Plots probe integration continuously 
    set(handles.axes19, 'XTickLabelMode', 'manual', 'XTickLabel', []);
    set(handles.axes19, 'YTickLabelMode', 'manual', 'XTickLabel', []);
    handles.pumpprobedata=[handles.previouspumpprobedata,handles.Ydata];            %add to set of previous data for probe
    handles.previouspumpprobedata=handles.pumpprobedata;
    hold on
    pause(0.1)
    %Save the data (x values) depending on with/without calibration
    % FUCK THis calibration bullshit, taken out by O.G. only save raw
    % timesteps from now on, user supplies calibration in analysis- fuckin'
    % stoopid
    xfilenamedatatxt=strcat(handles.filename,'_',datestr(now,'dd_mm_yyyy'),'_tdata','.txt');
    directory=get(handles.filelocation);
    xrawdataname=fullfile(handles.filedirectory,xfilenamedatatxt);              %Includes file directory
    rawxdata = X((2501-handles.numberofdatapoints):end);  % just saves raw value from oscilloscope
    if exist(xrawdataname)~=2
        dlmwrite(xrawdataname, rawxdata, 'delimiter','\t') %Save data to txt file, tabs delimiter to separate collumns
    end
    
    %Intensity plot
    handles.addingvector=zeros(handles.numberofdatapoints,timesteplength); %Creates a zeros vector in which one row will be created to add to a main plot matrix
    if handles.arduinoc==1; %if arduino connected
        if handles.pumpbackground==1 && handles.probebackground==1;
            handles.addingvector(:,i)=(handles.Ydata-(handles.Ydatapump+handles.Ydataprobe));
        elseif handles.pumpbackground==1 && handles.probebackground==0;
            handles.addingvector(:,i)=(handles.Ydata-(handles.Ydatapump));
        elseif handles.pumpbackground==0 && handles.probebackground==1;
            handles.addingvector(:,i)=(handles.Ydata-(handles.Ydataprobe));
        elseif handles.pumpbackground==0 && handles.probebackground==0;
            handles.addingvector(:,i)=(handles.Ydata);
        end
    elseif handles.arduinoc==0; %if arduino not connected
        handles.addingvector(:,i)=(handles.Ydata);
    end
    data=handles.xdata;
    timesteppcolor=1:1:(timesteplength+1);
    
    
    %Save the timestep data (y values)
    if exist(yrawdataname)~=2          %Includes file directory
        dlmwrite(yrawdataname, timesteppcolorvalues, 'delimiter','\t'); %Save data to txt file, tabs delimiter to separate collumns
    end
    

    timestep=handles.valuescanfromvalue:handles.valuestepsize:handles.valuescantovalue;
    timestep=timestep(:);
    if handles.exponentialstepsvalue == 1; 
        timestep = [timestep;additionalexponentialsteps];
    end
    timestep=1:1:length(timestep);
    intensity=handles.plotdata;
    intensity(:,i)=(intensity(:,i)-handles.addingvector(:,i));
    intensity=transpose(intensity);
    %intensity=-intensity;
    ph=pcolor(handles.axes23,data,timesteppcolor,intensity);
    set(handles.axes23,'YTick',timesteppcolor);
    set(handles.axes23,'YTickLabel',handles.timestepyticklabels);
    if handles.calconstant ~= 0;
        xlabel(handles.axes23,'m/q');
    elseif handles.calconstant == 0;
        xlabel(handles.axes23,'Time (s)');
    end
    ylabel(handles.axes23,'Timestep (fs)');
    set(ph,'edgecolor','none');
    colormap jet
    shading interp
    intensity=transpose(intensity);
    handles.continuousreadingplotxdata=sum(intensity(:,1:timesteplength),1); %Sums up each collumn of the data matrix for side plot of live updata.
    plot(handles.axes24,handles.continuousreadingplotxdata,timestep);
    set(handles.axes24,'YTick',timestep);
    set(handles.axes24,'YTickLabel',handles.timestepyticklabels);
    xlabel(handles.axes24,'Timestep Average');ylabel(handles.axes24,'Timestep (fs)');
    handles.itterationdata(:,(3*i))=handles.Ydata;              %set every third row to pump probe data (3,6,9,...)
    if handles.probebackground==1 && handles.arduinoc==1;
        handles.itterationdata(:,((3*i)-1))=handles.Ydataprobe;     %set every third row to probe data (2,5,8,...)
    end
    if handles.pumpbackground==1 && handles.arduinoc==1;
        handles.itterationdata(:,((3*i)-2))=handles.Ydatapump;      %set every third row to pump data (1,4,7,...)
    end
    handles.plotdata=intensity;
end
%Save data at end of each loop itteration
filenamedatatxt=strcat(handles.filename,'_',datestr(now,'dd_mm_yyyy'),'_scan_',[num2str(j)],'.txt');
rawdataname=fullfile(handles.filedirectory,filenamedatatxt);              %Includes file directory
dlmwrite(rawdataname, handles.itterationdata, 'delimiter','\t') %Save data to txt file, tabs delimiter to separate collumns

if (get(handles.runexp,'UserData') ~= 0); % Only increase j if the stop button has not been pressed  
    j=j+1;
end
guidata(hObject, handles)
end
if j==(handles.valuescannumb+1);
    j=j-1;
end
set(handles.textdisplay,'string',[num2str(j) ' scans of ' num2str(handles.valuescannumb) ' completed successfully'])    %display scan number in text display
pause(0.1)
if handles.arduinoc==1;
    servoWrite(handles.a,9,45); servoWrite(handles.a,10,135); %Close shutters at end of run
    set(handles.pumpshutter,'Value',0); set(handles.probeshutter,'Value',0)
    set(handles.pumpshutter,'String','Pump Closed'); set(handles.probeshutter,'String','Probe Closed')
end
handles.stagestepsize=str2double(get(handles.stagestepsizebox,'String'));               % reset stage step size to the one set in stage step size box
set(handles.setspeedvalue,'enable','on');   %reallow changing stage speed
set(handles.stagespeed,'enable','on');
set(handles.runexp,'UserData',0);            %states stop condition so can run when prompted next time
guidata(hObject, handles);




% Shows the set file location
function filelocation_Callback(hObject, eventdata, handles)
get(hObject,'string');  %Gets input file location

function filelocation_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% Input name to save file as
function namefile_Callback(hObject, eventdata, handles)
filename=get(hObject,'string');
handles.filename=filename;
guidata(hObject, handles);

function namefile_CreateFcn(hObject, eventdata, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Sets location for save files
function filedirectory_Callback(hObject, eventdata, handles)
filedirectory=uigetdir('C:\');                      % Opens up directory box
set(handles.filelocation, 'string',filedirectory);  % States the file location in the file directory edit box 
handles.filedirectory=filedirectory;
guidata(hObject, handles);

%Quits MATLAB instantly
function quitmatlab_Callback(hObject, eventdata, handles)
exit
