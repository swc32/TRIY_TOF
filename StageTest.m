function varargout = StageTest(varargin)
% STAGETEST MATLAB code for StageTest.fig
%      STAGETEST, by itself, creates a new STAGETEST or raises the existing
%      singleton*.
%
%      H = STAGETEST returns the handle to a new STAGETEST or the handle to
%      the existing singleton*.
%
%      STAGETEST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STAGETEST.M with the given input arguments.
%
%      STAGETEST('Property','Value',...) creates a new STAGETEST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before StageTest_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to StageTest_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help StageTest

% Last Modified by GUIDE v2.5 30-Mar-2015 15:17:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @StageTest_OpeningFcn, ...
                   'gui_OutputFcn',  @StageTest_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before StageTest is made visible.
function StageTest_OpeningFcn(hObject, eventdata, handles, varargin)

handles.stagestepsize = 100;                  % Sets stage step size initially to 100 fs


handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes StageTest wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = StageTest_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% Set-up stage
function err=setupstage(handles)
global stage stageaxis

err='';c='';b=10;
if isempty(stage)                                   %only do this if there isn't a stage already
    %set(handles.stagetextdisplay,'String','setting up stage...')
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
else
    set(handles.stageslider,'Min',qTMN(stage,stageaxis));%set up slider.
    set(handles.stageslider,'Max',qTMX(stage,stageaxis));
    set(handles.stagevalue,'String','0'),set(handles.stageslider, 'Value' ,0)
end 




%Stage slider
function stageslider_Callback(hObject, eventdata, handles)
global stage stageaxis
pos=get(hObject,'Value');                           % get slider value
err=setupstage(handles);                            % go to setupstage function
if isempty(err)                                     % if everything is good
    MOV(stage,stageaxis,-pos);                      % move stage to the slider position
    stagepos(handles)                               % go to the stagepos function
    get(handles.stageslider,'Min')%set up slider.
    get(handles.stageslider,'Max')
%else set(handles.stagetextdisplay,'String',err)          % display error on UI
end

function stageslider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


%Move Stage Home
function stagehome_Callback(hObject, eventdata, handles)
global stage stageaxis
err=setupstage(handles);                            % go to setupstage function
if isempty(err)                                     % if everything is good
    GOH(stage,stageaxis);                           % go to home position
    stagepos(handles)                               % go to the stagepos function
%else set(handles.stagetextdisplay,'String',err)          % display the error on the UI
end


%Set New Home Position
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



%Set Step size
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


% Got to a position
function gotoposition_Callback(hObject, eventdata, handles)
global stage stageaxis
err=setupstage(handles);%go to setupstage function
if isempty(err); 
    GoToCC=str2double(get(hObject,'String'))*-0.0002998 %get the value in mm
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
%set(handles.stagetextdisplay,'String',['Final Position: ' num2str(a/-0.0002998,'%11.0f') ...
    %' fs. Stage can be moved between: ' num2str(min/0.0002998,'%11.0f')...
    %' and ' num2str(max/0.0002998,'%11.0f') '. ' b])  	%display stage limits