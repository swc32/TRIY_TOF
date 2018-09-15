function varargout = TOFANALYSE2(varargin)
% TOFANALYSE2 MATLAB code for TOFANALYSE2.fig
%      TOFANALYSE2, by itself, creates a new TOFANALYSE2 or raises the existing
%      singleton*.
%
%      H = TOFANALYSE2 returns the handle to a new TOFANALYSE2 or the handle to
%      the existing singleton*.
%
%      TOFANALYSE2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TOFANALYSE2.M with the given input arguments.
%
%      TOFANALYSE2('Property','Value',...) creates a new TOFANALYSE2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TOFANALYSE2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TOFANALYSE2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TOFANALYSE2

% Last Modified by GUIDE v2.5 27-Apr-2017 17:05:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TOFANALYSE2_OpeningFcn, ...
                   'gui_OutputFcn',  @TOFANALYSE2_OutputFcn, ...
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


% --- Executes just before TOFANALYSE2 is made visible.
function TOFANALYSE2_OpeningFcn(hObject, eventdata, handles, varargin)
global Decays PreviousDecays CCT PreviousTimeCon PreviousSRT PreviousBack GaussianFit azglobal elglobal UserFitOffset PreviousUserFitOffset
%Set-up Handles
handles.Yoffsetvalue = 0; %Stating that there is no initial Time offset
handles.CaptureSidePlotActive = 0; %States that side capture is not on


%Fitting Things
Decays = [0,1,0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]; %States initial fitting conditions on opening (1 gaussian, 2-8 to fit,9-15 squential risetimes,16-22 fixing decay timeconstants,23-29 backwards, 30-36 fixed user risetimes,37-43 unknown rise times, 44-50 rise time only)
PreviousDecays = [0,1,0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]; %States Previous Fits  fitting conditions on opening (1 gaussian, 2-8 to fit,9-15 squential risetimes,16-22 fixing decay timeconstants,23-29 backwards, 30-36 fixed user risetimes,37-43 unknown rise times, 44-50 rise time only)
handles.PreviousFit = 0; %States at present there is no fit to the data and used to hold the data from the previous fit for comparisson
CCT = (str2num(get(handles.cc,'string')))*1000; %States the Initial value of cross correlation    
handles.TimeCons =[str2num(get(handles.t1,'string')),str2num(get(handles.t1Rise,'string'));str2num(get(handles.t2,'string')),str2num(get(handles.t2Rise,'string'));str2num(get(handles.t3,'string')),str2num(get(handles.t3Rise,'string'));str2num(get(handles.t4,'string')),str2num(get(handles.t4Rise,'string'));str2num(get(handles.t5,'string')),str2num(get(handles.t5Rise,'string'));str2num(get(handles.t6,'string')),str2num(get(handles.t6Rise,'string'));str2num(get(handles.t7,'string')),str2num(get(handles.t7Rise,'string'))];  %Keeps a record of current user timeconstants
PreviousTimeCon=[0,0,0,0,0,0,0,0];%Used to decipher if timeconstants have been changed by user in the fit
PreviousSRT=[0,0,0,0,0,0,0];%Used to determine risetime information and see if the fit has changed.
PreviousBack=[0,0,0,0,0,0,0];%Used to determine backwards fitting information and see if the fit has changed.
GaussianFit=0; %Used on the sideplot to establish if fitting a gaussian
azglobal=-37.5; %azglobal and el global used as views for 3d plots and retrieving previous angle of view
elglobal=30;
UserFitOffset=0; %Used as a manual offset in the fit data
PreviousUserFitOffset=0; %Used to remember manual offset for last fit

%Selecting Regions Things
%handles.GlobalSliderCell={[1,0,0],'LeftSlider1','RightSlider1';[0,1,0],'LeftSlider2','RightSlider2';[1,1,1],'LeftSlider3','RightSlider3';[1,0,1],'LeftSlider4','RightSlider4';[1,1,0],'LeftSlider5','RightSlider5'};
handles.GlobalSliderCell={[1,0,0],'LeftSlider1','RightSlider1','handles.Slider1Min','handles.Slider1Max';[0,1,0],'LeftSlider2','RightSlider2','handles.Slider2Min','handles.Slider2Max';[1,1,1],'LeftSlider3','RightSlider3','handles.Slider3Min','handles.Slider3Max';[1,0,1],'LeftSlider4','RightSlider4','handles.Slider4Min','handles.Slider4Max';[1,1,0],'LeftSlider5','RightSlider5','handles.Slider5Min','handles.Slider5Max'};

handles.NoRegionsSelection=[1,0,0,0]; %States the initial orientation of the radio buttons in the 'No.of Regions' sub-menu, used for knowing number of global regions to select
handles.SelectedRegion=[1,0,0,0,0]; %States the initial orientation of the radio buttons in the 'Selected Region' sub-menu, used for knowing which cursors to control
handles.DoNotFit=[0,0,0,0,0]; %States which user chosen mass regions are not to be fitted, even if they are user has specified a region.
handles.GlobalDivPeak=[1,0,0,0,0]; %States which user chosen mass regions are to be included in a summed background division removal
handles.ThreeDPlot=0; %Used for checking whether to plot the main graph in 2D or 3D

HandlesVisibleArray=[handles.uipanel5,handles.uipanel11,handles.uipanel13,handles.axes4, handles.SidePlotOptions,handles.CCInfo,handles.axes5,handles.CumulativeScansChoices];
set(HandlesVisibleArray,'visible','off');       %Hides selected features on opening
HandlesEnableArray=[handles.DataManipulation,handles.DataFitting,handles.Calibrate,handles.Region3Button,handles.Region4Button,handles.Region5Button,handles.DoNotFitRegion3,handles.DoNotFitRegion4,handles.DoNotFitRegion5,handles.DivPeak1,handles.DivPeak2,handles.DivPeak3,handles.DivPeak4,handles.DivPeak5,handles.PumpSub,handles.ProbeSub,handles.PaPSub,handles.PumpDiv,handles.ProbeDiv,handles.PaPDiv, handles.PumpSignal,handles.ProbeSignal,handles.CumulativeScans,handles.CumulativePumpButton,handles.CumulativeProbeButton,handles.text41,handles.SelectedScans];
set(HandlesEnableArray,'Enable','off');       %Disables selected features on opening
HandlesFittingEnableArray=[handles.t1Rise,handles.t1Risevary,handles.t2,handles.t2vary,handles.t2Rise,handles.t2Risevary,handles.t2start,handles.URT2,handles.RTO2,handles.t2back,handles.t3,handles.t3vary,handles.t3Rise,handles.t3Risevary,handles.t3start,handles.URT3,handles.RTO3,handles.t3back,handles.t4,handles.t4vary,handles.t4Rise,handles.t4Risevary,handles.t4start,handles.URT4,handles.RTO4,handles.t4back,handles.t5,handles.t5vary,handles.t5Rise,handles.t5Risevary,handles.t5start,handles.URT5,handles.RTO5,handles.t5back,handles.t6,handles.t6vary,handles.t6Rise,handles.t6Risevary,handles.t6start,handles.URT6,handles.RTO6,handles.t6back,handles.t7,handles.t7vary,handles.t7Rise,handles.t7Risevary,handles.t7start,handles.URT7,handles.RTO7,handles.t7back,handles.SaveFit];
set(HandlesFittingEnableArray,'Enable','off');       %Disables selected fitting features on opening
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TOFANALYSE2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TOFANALYSE2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Load.
function Load_Callback(hObject, eventdata, handles)
global DataIsNowFitted DivisionVector %TimeStepFullPlusOffset
%TimeStepFullPlusOffset= handles.Timestep;  %Used in cross correlation calculation when y values limited by user

%Load Scan data
try
    [Filenames, handles.PathName] = uigetfile({'*.txt','Text files (*.txt)'},['Select the Scan files'], 'MultiSelect', 'on');   %Select files
catch
    if exist(handles.MyData)==1;
        MyData= handles.MyData; %remembers mydata originally if cancel opening files
    end
end

%Check for relavent errors
if ErrorCheck(Filenames,0,0,0,0,0,0,0,0,1)==1
    return
end

handles.DataAlreadyCalibrated = 0;          %State data is not callibrated for the purposes of the programme
DataIsNowFitted=0;                          %State data is not currently fitted for the purposes of the programme

cla(handles.axes1);     %clear plot axes
cla(handles.axes2);
cla(handles.axes3);
cla(handles.axes4);
cla(handles.axes5);

%Load Data from files
Filenames = cellstr(Filenames); %naming conventions for loading files in sequence
RootNames = cellstr(Filenames);
InfoNames = cellstr(Filenames);  % preallocation
for n = 1:length(Filenames);
    RootNames{n}=Filenames{n}(1,1:length(Filenames{n})-11);
    InfoNames{n}=[RootNames{n}, '.dat'];
    MyData{n,1} = load(fullfile(handles.PathName,Filenames{n}));    %Load data here in a cell structure
end

handles.MyData=MyData;                      %Save MyData to handles for cases where loading fails so as not to crash the whole GUI

%load timestep and mqcal data
CompFilename=fullfile(handles.PathName,RootNames{1});   % ensuring loading even if not current working directory
if exist (strcat(CompFilename,'_mqcaldata.txt'));       %load x axis values
    handles.TData=load( [CompFilename,'_mqcaldata.txt'] );
else
    handles.TData=load( [CompFilename,'_tdata.txt'] );
end
handles.Timestep=load ( [CompFilename,'_timestepdata.txt'] );   %load y axis values (timestep)
if size(handles.Timestep,2) > size(handles.Timestep,1)   %Ensure timestep data is always alligned the same way (saved differently for lin log and linear)
    handles.Timestep = handles.Timestep.';
end

%Disable background subtraction options before checking if they are usable for the data as well as cumulative summations for pump and probe alone
HandlesEnableArray=[handles.PumpSub,handles.ProbeSub,handles.PaPSub,handles.PumpDiv,handles.ProbeDiv,handles.PaPDiv,handles.PumpSignal,handles.ProbeSignal,handles.CumulativePumpButton,handles.CumulativeProbeButton];
set(HandlesEnableArray,'Enable','off');       %Disables selected features
set(handles.NoSubOrDiv,'Enable','on','value',1);       %Sets so as no background subtraction
set(handles.CumulativePaPButton,'Enable','on','value',1);      %Sets to show pump and probe summation on axes five if using

%Gets Y axis values and positions
[handles.LinearYTickLabels,handles.LinLogYTickLabels,handles.LinLogScale] = YAxisLabels(handles.Timestep+handles.Yoffsetvalue,str2double(get(handles.LinLogMultiplier,'String')));

%Concatanate the data and subtract an average of the first 50 datapoints in
%each collumn. This is to prevent a 'double base-line subtraction'.
MyData=cat(3,MyData{:});
for i=1:size(MyData,3)
    MyData(:,:,i)= bsxfun(@minus,MyData(:,:,i),mean(MyData(1:50,:,i)));
end

handles.MyData=MyData;                      %Save MyData to handles for cases where loading fails so as not to crash the whole GUI

handles.TotalData=((sum(MyData,3))*-1); %Sums the data into 2d array and multiplies by -1 to make peaks positive

%Data for cumulative summing of points
handles.CumulativePaP= MyData(:,3:3:(3*length(handles.Timestep)),:);
handles.CumulativePaP=-1*(sum(reshape(handles.CumulativePaP,size(handles.CumulativePaP,1),(length(handles.Timestep)*size(handles.CumulativePaP,3))),1));


%Separates Pump, Probe and Pump-Probe Data and Arranges for Plotting, applying offsets where appropriate, as well as summing data to see integrated traces for pump and probe alone data to give an idea of signal
handles.PumpData=handles.TotalData(:,1:3:((3*length(handles.Timestep))-2)); %seperates pump data
if any(any(handles.PumpData))~=0;
    set([handles.PumpSub,handles.PumpSignal,handles.CumulativePumpButton],'Enable','on');     %If non-zero, allow pump subtraction option
    handles.CumulativePump= MyData(:,1:3:(3*length(handles.Timestep))-2,:);
    handles.CumulativePump=-1*(sum(reshape(handles.CumulativePump,size(handles.CumulativePump,1),(length(handles.Timestep)*size(handles.CumulativePump,3))),1));
end
handles.ProbeData=handles.TotalData(:,2:3:((3*length(handles.Timestep))-1));    %separates probe data
if any(any(handles.ProbeData)) ~=0 ;
    set([handles.ProbeSub,handles.ProbeSignal,handles.CumulativeProbeButton],'Enable','on');    %If non-zero, allow probe subtraction option
    handles.CumulativeProbe= MyData(:,2:3:(3*length(handles.Timestep))-1,:);
    handles.CumulativeProbe=-1*(sum(reshape(handles.CumulativeProbe,size(handles.CumulativeProbe,1),(length(handles.Timestep)*size(handles.CumulativeProbe,3))),1));
end
handles.PumpAndProbeData=handles.TotalData(:,3:3:(3*length(handles.Timestep))); %separates pump-probe data
if strcmp(get(handles.PumpSub,'Enable'),'on') == 1 && strcmp(get(handles.ProbeSub,'Enable'),'on') == 1;
    set([handles.PaPSub],'Enable','on');      % If both Pump and Probe alone data present, allow subtraction of both option 
end
handles.PlotData=transpose(handles.PumpAndProbeData);

%Takes an average of the first 3 rows as a 'Background' to subtract
handles.BackgroundSubtraction=mean(handles.PlotData(1:3,:));

%Used to set initial axis limits (real numbers), also used by sliders as limit values
handles.MaximumXValue=max(handles.TData);
handles.MinimumXValue=min(handles.TData);
handles.MaximumYValue=max(handles.Timestep)+handles.Yoffsetvalue;
handles.MinimumYValue=min(handles.Timestep)+handles.Yoffsetvalue;

%X Data Index Limits
handles.XMinimumValueI=1;
handles.XMaximumValueI=length(handles.TData);

%Y Data Index limits
handles.YMinimumValueI=1;
handles.YMaximumValueI=length(handles.Timestep);

%Update GUI Features now data has loaded
set(handles.SidePlotOptions,'visible','on');       %Shows side graph options pannel
set(handles.CrossCorrelationFitCheck,'Enable','on');    %Enable Cross correlation after loading 
set(handles.SaveFit,'enable','off');               %New data so no previous fit to save
set(handles.DataFitting,'enable','off')            %New data so needs to recalibrate
HandlesEnableArray=[handles.DataManipulation,handles.Calibrate,handles.CumulativeScans,handles.text41,handles.SelectedScans];
set(HandlesEnableArray,'Enable','on');       %Enables selected features on after data is loaded
HandlesValueArray=[handles.LinLogYAxis,handles.LinLogZAxis,handles.ZAxisBackground];
set(HandlesValueArray,'value',0);          %Sets selected check boxes to zero
guidata(hObject, handles);

%Accesses the main graphs plotting function
MainPlotGraph(handles.TData,handles.Timestep+handles.Yoffsetvalue,handles.PlotData,get(handles.LinLogYAxis,'Value'),handles.DataAlreadyCalibrated,handles.MinimumXValue,handles.MaximumXValue,(handles.Timestep(handles.YMinimumValueI)+handles.Yoffsetvalue),(handles.Timestep(handles.YMaximumValueI)+handles.Yoffsetvalue),handles.ThreeDPlot);

handles.MainXData=handles.TData;
handles.MainYData=(handles.Timestep+handles.Yoffsetvalue);
handles.MainZData=handles.PlotData;


%Sums all of the data in each row to a single point
%handles.ZSumAllMQ= sum(handles.PlotData,2);
guidata(hObject, handles);

%Plots this on the side plot

DivisionVector=ones((handles.YMaximumValueI-handles.YMinimumValueI+1),1); %As not dividing, just equal to a series of ones

SidePlotGraph(handles.PlotData,handles.Timestep+handles.Yoffsetvalue,get(handles.LinLogYAxis,'Value'),1,length(handles.TData),DivisionVector)

%sums all the data in each collumn to a single point
%handles.ZSumAllTime=sum(handles.PlotData);
guidata(hObject, handles);

%Plots this on the bottom plot
BottomPlotGraph(handles.TData,handles.PlotData);

%Update the slider positions and limits
SliderUpdateReset(handles.MinimumXValue,handles.MaximumXValue,handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors

%X Data Index Limits
handles.XMinimumValueI=1;
handles.XMaximumValueI=length(handles.TData);

%Set no of data sets limits
handles.PreviousNoOfScans=[1:size(handles.MyData,3)];
handles.PreviousScansString=strcat('[1:', num2str(size(handles.MyData,3)),']');
set(handles.SelectedScans,'string',handles.PreviousScansString);

handles.FullZData=handles.PlotData;

%If cumulative scans on, plot
if get(handles.CumulativeScans,'Value')==1
    plot(handles.axes5,handles.CumulativePaP)
    set(handles.axes5,'YTick',[],'XTick',[]);         %Remove all labels from cumulative plot
    xlim(handles.axes5,[1 length(handles.CumulativePaP)]);
end

%Change to single fitting and hide global fitting panel
set(handles.GlobalFitButton,'Value',0);
set(handles.SingleRegionButton,'Value',1);
set(handles.uipanel17,'visible','off');

%Resets averaging to no averaging
set(handles.NoAveragingBut,'Value',1)
guidata(hObject, handles);




% --- Executes on slider movement.
function RightSlider_Callback(hObject, eventdata, handles)
% Find the rightslider, update x and y position

% % If Lin-Log Y-axis
% if get(handles.LinLogYAxis,'Value')==1;
%     set((findobj(gcf,'Tag','right slider')),'Xdata',((ones(1,length(handles.Timestep))*get(hObject,'value'))),'YData',(1:1:length(handles.Timestep)));
% % If Linear Y-axis
% else
%     set((findobj(gcf,'Tag','right slider')),'Xdata',((ones(1,length(handles.Timestep))*get(hObject,'value'))),'YData',(handles.Timestep+handles.Yoffsetvalue));
% end
zmax=max(max(handles.MainZData)); %Used to position bars just above data

if get(handles.GlobalFitButton,'value') == 1;
    if handles.ThreeDPlot==0
        set((findobj(gcf,'Tag',handles.GlobalSliderCell{handles.CurrentSliders,3})),'Xdata',((ones(1,length(handles.Timestep))*get(hObject,'value'))),'YData',(handles.Timestep+handles.Yoffsetvalue));
    elseif handles.ThreeDPlot==1
        set((findobj(gcf,'Tag',handles.GlobalSliderCell{handles.CurrentSliders,3})),'Xdata',((ones(1,length(handles.Timestep))*get(hObject,'value'))),'YData',(handles.Timestep+handles.Yoffsetvalue),'Zdata',((ones(1,length(handles.Timestep))*(zmax*1.1))));
    end
    set(handles.(['Slider' num2str(handles.CurrentSliders) 'Max']),'string',num2str(get(hObject,'value')));
    handles.MaxAndMinRegions(handles.CurrentSliders,2)=get(hObject,'value');
else
    if handles.ThreeDPlot==0
        set((findobj(gcf,'Tag','right slider')),'Xdata',((ones(1,length(handles.Timestep))*get(hObject,'value'))),'YData',(handles.Timestep+handles.Yoffsetvalue));
    elseif handles.ThreeDPlot==1
        set((findobj(gcf,'Tag','right slider')),'Xdata',((ones(1,length(handles.Timestep))*get(hObject,'value'))),'YData',(handles.Timestep+handles.Yoffsetvalue),'Zdata',((ones(1,length(handles.Timestep))*(zmax*1.1))));
    end
end

guidata(hObject, handles);

%Plot data again
[handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2);

%Set-Up Cursors Again
if handles.DataAlreadyCalibrated==0;
    SliderUpdateReset(handles.TData(handles.XMinimumValueI),handles.TData(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
else
    if get(handles.GlobalFitButton,'value') == 1;
        GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    else
        SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    end    
end

guidata(hObject, handles);


function RightSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function LeftSlider_Callback(hObject, eventdata, handles)
% Find the leftslider, update x and y position

% % If Lin-Log Y-axis
% if get(handles.LinLogYAxis,'Value')==1;
%     set((findobj(gcf,'Tag','left slider')),'Xdata',((ones(1,length(handles.Timestep))*get(hObject,'value'))),'YData',(1:1:length(handles.Timestep)));
% % If Linear Y-axis
% else
%     set((findobj(gcf,'Tag','left slider')),'Xdata',((ones(1,length(handles.Timestep))*get(hObject,'value'))),'YData',(handles.Timestep+handles.Yoffsetvalue));
% end

zmax=max(max(handles.MainZData)); %Used to position bars just above data

if get(handles.GlobalFitButton,'value') == 1;
    if handles.ThreeDPlot==0
        set((findobj(gcf,'Tag',handles.GlobalSliderCell{handles.CurrentSliders,2})),'Xdata',((ones(1,length(handles.Timestep))*get(hObject,'value'))),'YData',(handles.Timestep+handles.Yoffsetvalue));
    elseif handles.ThreeDPlot==1
        set((findobj(gcf,'Tag',handles.GlobalSliderCell{handles.CurrentSliders,2})),'Xdata',((ones(1,length(handles.Timestep))*get(hObject,'value'))),'YData',(handles.Timestep+handles.Yoffsetvalue),'Zdata',((ones(1,length(handles.Timestep))*(zmax*1.1))));
    end
    set(handles.(['Slider' num2str(handles.CurrentSliders) 'Min']),'string',num2str(get(hObject,'value')));
    handles.MaxAndMinRegions(handles.CurrentSliders,1)=get(hObject,'value');
else
    if handles.ThreeDPlot==0
        set((findobj(gcf,'Tag','left slider')),'Xdata',((ones(1,length(handles.Timestep))*get(hObject,'value'))),'YData',(handles.Timestep+handles.Yoffsetvalue));
    elseif handles.ThreeDPlot==1
        set((findobj(gcf,'Tag','left slider')),'Xdata',((ones(1,length(handles.Timestep))*get(hObject,'value'))),'YData',(handles.Timestep+handles.Yoffsetvalue),'Zdata',((ones(1,length(handles.Timestep))*(zmax*1.1))));
    end
end

guidata(hObject, handles);

%Plot data again
[handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2);

%Set-Up Cursors Again
if handles.DataAlreadyCalibrated==0;
    SliderUpdateReset(handles.TData(handles.XMinimumValueI),handles.TData(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
else
    if get(handles.GlobalFitButton,'value') == 1;
        GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    else
        SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    end    
end

guidata(hObject, handles);


function LeftSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



%Calibrate Data by either loading in a calibration file or manually
function Calibrate_Callback(hObject, eventdata, handles)

global DataIsNowFitted %global to state if data is fitted or not

%If data is not calibrated
if handles.DataAlreadyCalibrated==0;
    % Construct a questdlg with three options
    choice =  questdlg('How would you like to calibrate the data?', ...
        'Calibration Method', ...
        'Load Calibration','Create Calibration','Cancel','Cancel');
    % Handle response
    switch choice
        case 'Load Calibration'
            %Load Calibration
            try
                [FileName, PathName] = uigetfile({'*.cal','Calibration files (*.cal)'},['Select Calibration File'],strcat(handles.PathName,'tof_calib.cal'));   %Select calibration file
            catch
                if ErrorCheck(Filenames,0,0,0,0,0,0,0,0,1)==1   %Check for relavent errors
                    return
                end
            end

            %If calibration file not selected, cancels rest of run
            if FileName==0 & PathName==0
                errordlg('No calibration file was selected','Error');    %display an error message
                return
            end


            %Load Cliabration File
            Cal=load( [PathName,FileName] );
            guidata(hObject, handles);

        case 'Create Calibration'

             InterfaceObj=findobj(gcf,'Enable','on'); %Finds figure
             set(InterfaceObj,'Enable','off');  %Disables everything
             [Cal,ExportDataStatus]=Callibration(handles.TData,handles.FullZData,handles.PathName);
             set(InterfaceObj,'Enable','on'); %Renables everything on closing calibration
             if ExportDataStatus==0 %If no file created
                errordlg('No Calibration Created','Error');    %display an error message
                return
             end

             guidata(hObject, handles);

        case 'Cancel'
    end

    %Reset background subtraction options as data starts double subtracting
    HandlesEnableArray=[handles.PumpSub,handles.ProbeSub,handles.PaPSub,handles.PumpDiv,handles.ProbeDiv,handles.PaPDiv];
    set(HandlesEnableArray,'value',0);       %Disables selected features
    set(handles.NoSubOrDiv,'value',1);       %Disables selected features

    %Callibrate data
    if exist('Cal')==1
        MQ = (((handles.TData-Cal(2))./Cal(1)).^2);

        %Shows index of first element equal to or greater than zero
        handles.MQZeroCutoff=find(MQ==min(MQ),1,'last');

        %Creates vector of relevant x data from zero to max and similar for background subtraction option
        handles.MQCal=MQ(handles.MQZeroCutoff:end); 
        handles.BackgroundSubtraction=mean(handles.PlotData(1:3,:));
        handles.BackgroundSubtraction=handles.BackgroundSubtraction(handles.MQZeroCutoff:end);
        %Limits data on plot for calibrated x axis values and creates pump and probe alone equivalents
        handles.PlotData=transpose(handles.PumpAndProbeData);
        handles.ZCalNonZero=handles.PlotData(:,handles.MQZeroCutoff:end);
        Pump=transpose(handles.PumpData);
        handles.PumpCal=Pump(:,handles.MQZeroCutoff:end);
        Probe=transpose(handles.ProbeData);
        handles.ProbeCal=Probe(:,handles.MQZeroCutoff:end);


        %sets x index limits to length of calibrated data
        handles.XMinimumValueI=1;
        handles.XMaximumValueI=length(handles.MQCal);

        %handles.plotoffset= handles.Xminimumvaluei-1;             %Offset for plot data so as to be able to control x axis location from mq calibration
        guidata(hObject, handles);

        %Update plots
        %[handles.ZSumAllMQ,handles.ZSumAllTime]=PlotUpdate(1);
        [handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(1);

        %MainPlotGraph(handles.MQCal,handles.Timestep,handles.ZCalNonZero,get(handles.LinLogYAxis,'Value'),handles.DataAlreadyCalibrated,handles.MinimumXValue,handles.MaximumXValue,handles.Timestep(handles.YMinimumValueI),handles.Timestep(handles.YMaximumValueI))

        guidata(hObject, handles);

        %Update sliders
        SliderUpdateReset(min(handles.MQCal),max(handles.MQCal),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors    

        %State data is now calibrated
        handles.DataAlreadyCalibrated=1;

        %Enable data fitting option and background division
        set(handles.DataFitting,'Enable','on'); %Enable data fitting now that data calibrated

        %Enable background divions
        if strcmp(get(handles.PumpSub,'Enable'),'on') == 1
            set(handles.PumpDiv,'Enable','on') 
        end
        if strcmp(get(handles.ProbeSub,'Enable'),'on') == 1;
            set(handles.ProbeDiv,'Enable','on') 
        end        
        if strcmp(get(handles.PumpSub,'Enable'),'on') == 1 && strcmp(get(handles.ProbeSub,'Enable'),'on') == 1;
            set(handles.PaPDiv,'Enable','on')
        end

        guidata(hObject, handles);
    end
    
elseif handles.DataAlreadyCalibrated==1;
    
    %Reset background subtraction options as data starts double subtracting
    HandlesEnableArray=[handles.PumpSub,handles.ProbeSub,handles.PaPSub,handles.PumpDiv,handles.ProbeDiv,handles.PaPDiv];
    set(HandlesEnableArray,'value',0);       %Disables selected features
    set(handles.NoSubOrDiv,'value',1);       %Disables selected features
    
    %set minimum and maximum x indicies so that entire data set is shown
    handles.XMinimumValueI=1;
    handles.XMaximumValueI=length(handles.TData);
    
    %state data is not fitted
    DataIsNowFitted=0;
    
    %Takes an average of the first 3 rows as a 'Background' to subtract
    handles.BackgroundSubtraction=mean(handles.PlotData(1:3,:));

    guidata(hObject, handles);
    
    %Update Plots
    %[handles.Zsumallmq,handles.Zsumalltime]=PlotUpdate(2);
    [handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(1);
    
    %State data is no longer calibrated
    handles.DataAlreadyCalibrated=0;

    %Set-up cursors
    SliderUpdateReset(min(handles.TData),max(handles.TData),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors

    % Turn off otions for fitting data if not calibrated
    set(handles.DataFitting,'Enable','off'); %Disbale data fitting until data calibrated
    
    %Disable division background
    set([handles.PumpDiv,handles.ProbeDiv,handles.PaPDiv],'Enable','off');
    
    %Change to single fitting and hide global fitting panel
    set(handles.GlobalFitButton,'Value',0);
    set(handles.SingleRegionButton,'Value',1);
    set(handles.uipanel17,'visible','off');
    
    %Resets averaging to no averaging
    set(handles.NoAveragingBut,'Value',1)
    
    cla(handles.axes4);                     %Clear Optimistation Plot Axis
end

%Update maximum and minimum x values
handles.MinimumXValue=str2num(get(handles.MinimumX,'string'));
handles.MaximumXValue=str2num(get(handles.MaximumX,'string'));

%Reset for 2 colour signal and not either background being shown
set(handles.TwoCSignal,'Value',1)
set([handles.PumpSignal,handles.ProbeSignal],'Value',0)
%Reset Background Options
set(handles.NoSubOrDiv,'Enable','on')
if any(any(handles.PumpData))~=0;
    set([handles.PumpSub],'Enable','on');     %If non-zero, allow pump subtraction option
end
if any(any(handles.ProbeData))~=0;
    set([handles.ProbeSub],'Enable','on');     %If non-zero, allow probe subtraction option
end
if strcmp(get(handles.PumpSub,'Enable'),'on') == 1 && strcmp(get(handles.ProbeSub,'Enable'),'on') == 1;
    set([handles.PaPSub],'Enable','on');     %If non-zero, allow pump and probe subtraction option
end
if handles.DataAlreadyCalibrated==1; %if data is claibrated
    %Reset Background Division Options
    if any(any(handles.PumpData))~=0;
        set([handles.PumpDiv],'Enable','on');     %If non-zero, allow pump division option
    end
    if any(any(handles.ProbeData))~=0;
        set([handles.ProbeDiv],'Enable','on');     %If non-zero, allow probe division option
    end
    if strcmp(get(handles.PumpSub,'Enable'),'on') == 1 && strcmp(get(handles.ProbeSub,'Enable'),'on') == 1;
        set([handles.PaPDiv],'Enable','on');     %If non-zero, allow pump and probe division option
    end
end
guidata(hObject, handles);



function [ErrorOutput] = ErrorCheck(UserInputValue,CompareValue1,CompareValue2,CompareValue3,Question1,Question2,Question3,Question4,Question5,Question6)

handles= guidata(gcbo);    %load in handles as this is a function, not a callback

%Initially state no errors found
ErrorOutput = 0;

%Check if user input variables are numbers
if Question1 == 1
    for i=1:length(UserInputValue) 
        if isnan(UserInputValue(i)) == 1
            errordlg('A user input box required for this function is empty or not a number','Error');    %display an error message
            ErrorOutput = 1;
            return
        end
    end
end

%Check if user input variable is greater than zero
if Question2 == 1
    for i=1:length(UserInputValue) 
        if UserInputValue(i) < 0
            errordlg('Most recent variable change must be greater than zero','Error');    %display an error message
            ErrorOutput = 1;
            return
        end
    end
end

%Check if right slider to the right of left slider
if Question3 == 1
    if CompareValue2<=CompareValue1
        errordlg('Right slider position must be greater than left slider position','Error');    %display an error message
        ErrorOutput = 1;
        return
    end
end

%Check if mass peak left less than mass peak right
if Question4 == 1
    if UserInputValue(2)<=UserInputValue(1)
        errordlg('Right limit must be greater than left limit','Error');    %display an error message
        ErrorOutput = 1;
        return
    end
end

%Check if the values selected are in boundary limits
if Question5 == 1
    if CompareValue1<CompareValue2 || CompareValue1>CompareValue3
        errordlg(['Input value outwith range, reset to maximum'],'Error');    %display an error message
        ErrorOutput = 1;
        return
    end
end
    
if Question6 == 1
    if isa(UserInputValue,'double') == 1; %If no files selected, cancels rest of run
        errordlg('No files selected to load','Error');    %display an error message
        ErrorOutput = 1;
        return
    end

end


function [LinearYTickLabels,LinLogYTickLabels,LinLogScale] = YAxisLabels(Timestep,LogMultiplier)
%Timestep: Timestep data loaded in or manually offset
%LinearYTickLabels: Y values to show on axis
%LinLogYTickLabels: Inices of Y axis labels, used in conjunction with LinearYTickLabels to show values in LinLog plots

%Used to generate a linlog y axis with mixed spacing for linear and log points for presentation
j=[];
for i=1:(length(Timestep)-1) %Used to find difference between data points
    j=[j,(Timestep(i+1)-Timestep(i))];
end
cut=find(j>(Timestep(2)-Timestep(1)),1); %Find point lin goes to log
if isempty(cut)==1
    LinLogScale=1:1:length(Timestep);
else
    LogPoints=length(Timestep)-cut; %Finds number of log steps
    LinearPoints=1:1:cut; %Creates spacing for linear section 
    %Creates the linlog scale
    AlteredLogPoints=linspace(1,LogPoints,LogPoints);
    AlteredLogPoints=AlteredLogPoints*LogMultiplier;
    AlteredLogPoints=AlteredLogPoints+cut;
    LinLogScale=[LinearPoints,AlteredLogPoints];
end

%gets a rough estimate of the number of y labels to put on axis for both linear and lin-log cases
%puts on first number, zero, linlog break and end point
TimestepYTickLabels=[Timestep(1),0];
if isempty(cut)==0
    TimestepYTickLabels=[TimestepYTickLabels,Timestep(cut),Timestep(end)];
else
    TimestepYTickLabels=[TimestepYTickLabels,Timestep(end)];
end
%Gets the y label values with respect to the data (nearest to ther values set above) 
LinearYTickLabels=[];
LinLogYTickLabels=[];
for i=1:length(TimestepYTickLabels)
    [c index] = min(abs(Timestep-TimestepYTickLabels(i)));
    LinLogYTickLabels = [LinLogYTickLabels,LinLogScale(index)];                      %Time value at that point
    LinearYTickLabels = [LinearYTickLabels,Timestep(index)];            %Data point number for label
end

%Incase the user starts scan from zero or needs to pass zero in original scan for some reason
if LinLogYTickLabels(1) == LinLogYTickLabels(2);
    LinLogYTickLabels=LinLogYTickLabels(2:end);
    LinearYTickLabels= LinearYTickLabels(2:end);
end

%Used as a multiplier in linlog axis scaling
function LinLogMultiplier_Callback(hObject, eventdata, handles)

if ErrorCheck(str2double(get(hObject,'String')),0,0,0,1,1,0,0,0,0) == 1;  %Checks if the number is valid
   set(hObject, 'String', 1); %If it fails, reset editbox 
elseif str2double(get(hObject,'String')) <= 0
   errordlg('Most recent variable change must be greater than zero','Error');    %display an error message
else
    [handles.LinearYTickLabels,handles.LinLogYTickLabels,handles.LinLogScale] = YAxisLabels(handles.Timestep+handles.Yoffsetvalue,str2double(get(hObject,'String')));
    guidata(hObject, handles);
    [handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2); %Plot data again
    %Set-Up Cursors Again
    if handles.DataAlreadyCalibrated==0;
        SliderUpdateReset(handles.TData(handles.XMinimumValueI),handles.TData(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    else
        if get(handles.GlobalFitButton,'value') == 1;
            GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
        else
            SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
        end    
    end
    guidata(hObject, handles);
end
guidata(hObject, handles);


function LinLogMultiplier_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%Used to see which data should be plotted (2 colour, pump alone or probe alone)
function MainDataSwitch_SelectionChangeFcn(hObject, eventdata, handles)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'TwoCSignal'   %If looking at 2 colour signal
        %Reset Background Options
        set(handles.NoSubOrDiv,'Enable','on')
        if any(any(handles.PumpData))~=0;
            set([handles.PumpSub],'Enable','on');     %If non-zero, allow pump subtraction option
        end
        if any(any(handles.ProbeData))~=0;
            set([handles.ProbeSub],'Enable','on');     %If non-zero, allow probe subtraction option
        end
        if strcmp(get(handles.PumpSub,'Enable'),'on') == 1 && strcmp(get(handles.ProbeSub,'Enable'),'on') == 1;
            set([handles.PaPSub],'Enable','on');     %If non-zero, allow pump and probe subtraction option
        end
        %Choose Plot data
        SelectionCheck=get(get(handles.uipanel23,'SelectedObject'),'Tag'); %Used to check which subtraction option is currently selected
        if handles.DataAlreadyCalibrated==0; %if data is not claibrated
            if strcmp(SelectionCheck,'PaPSub')==1 
                handles.PlotData=(transpose(handles.PumpAndProbeData))-((transpose(handles.ProbeData))+(transpose(handles.PumpData)));
            elseif strcmp(SelectionCheck,'PumpSub')==1 
                handles.PlotData=(transpose(handles.PumpAndProbeData))-(transpose(handles.PumpData));
            elseif strcmp(SelectionCheck,'ProbeSub')==1 
                handles.PlotData=(transpose(handles.PumpAndProbeData))-(transpose(handles.ProbeData));
            else
                handles.PlotData=(transpose(handles.PumpAndProbeData));
            end
        else %if data is claibrated
            if strcmp(SelectionCheck,'PaPSub')==1 
                handles.ZCalNonZero=(handles.PlotData(:,handles.MQZeroCutoff:end))-(handles.ProbeCal+handles.PumpCal);
            elseif strcmp(SelectionCheck,'PumpSub')==1 
                handles.ZCalNonZero=(handles.PlotData(:,handles.MQZeroCutoff:end))-(handles.PumpCal);
            elseif strcmp(SelectionCheck,'ProbeSub')==1 
                handles.ZCalNonZero=(handles.PlotData(:,handles.MQZeroCutoff:end))-(handles.ProbeCal);
            else
                handles.ZCalNonZero=(handles.PlotData(:,handles.MQZeroCutoff:end));
            end
            set(handles.DataFitting,'Enable','on'); %Enable data fitting again
            %Reset Background Division Options
            if any(any(handles.PumpData))~=0;
                set([handles.PumpDiv],'Enable','on');     %If non-zero, allow pump division option
            end
            if any(any(handles.ProbeData))~=0;
                set([handles.ProbeDiv],'Enable','on');     %If non-zero, allow probe division option
            end
            if strcmp(get(handles.PumpSub,'Enable'),'on') == 1 && strcmp(get(handles.ProbeSub,'Enable'),'on') == 1;
                set([handles.PaPDiv],'Enable','on');     %If non-zero, allow pump and probe division option
            end
        end
        %Reset Background Options
        guidata(hObject, handles)        
        [handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2); %Plot data again
        %Set-Up Cursors Again
        if handles.DataAlreadyCalibrated==0;
            SliderUpdateReset(handles.TData(handles.XMinimumValueI),handles.TData(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
        else
            if get(handles.GlobalFitButton,'value') == 1;
                GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
            else
                SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
            end    
        end
        guidata(hObject, handles);
    case 'PumpSignal'   %If looking at pump alone signal
        DisableArray=[handles.NoSubOrDiv,handles.PumpSub,handles.ProbeSub,handles.PaPSub,handles.PumpDiv,handles.ProbeDiv,handles.PaPDiv];
        set(DisableArray,'Enable','off')  %Enable background removal options
        if handles.DataAlreadyCalibrated==0; %if data is not claibrated
            handles.PlotData=(transpose(handles.PumpData));
        else %if data is claibrated
            handles.ZCalNonZero=(handles.PumpCal);
        end
        set(handles.DataFitting,'Enable','off'); %Disable data fitting on pump or probe alone signal
        guidata(hObject, handles)        
        [handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2); %Plot data again
        %Set-Up Cursors Again
        if handles.DataAlreadyCalibrated==0;
            SliderUpdateReset(handles.TData(handles.XMinimumValueI),handles.TData(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
        else
            if get(handles.GlobalFitButton,'value') == 1;
                GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
            else
                SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
            end    
        end
        guidata(hObject, handles);
    case 'ProbeSignal'   %If looking at pump alone signal
        DisableArray=[handles.NoSubOrDiv,handles.PumpSub,handles.ProbeSub,handles.PaPSub,handles.PumpDiv,handles.ProbeDiv,handles.PaPDiv];
        set(DisableArray,'Enable','off')  %Enable background removal options
        if handles.DataAlreadyCalibrated==0; %if data is not claibrated
            handles.PlotData=(transpose(handles.ProbeData));
        else %if data is claibrated
            handles.ZCalNonZero=(handles.ProbeCal);
        end
        set(handles.DataFitting,'Enable','off'); %Disable data fitting on pump or probe alone signal
        guidata(hObject, handles)        
        [handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2); %Plot data again
        %Set-Up Cursors Again
        if handles.DataAlreadyCalibrated==0;
            SliderUpdateReset(handles.TData(handles.XMinimumValueI),handles.TData(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
        else
            if get(handles.GlobalFitButton,'value') == 1;
                GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
            else
                SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
            end    
        end
        guidata(hObject, handles);
end


%Used to show cumulative integrated scans of pump, probe or PaP scans
function CumulativeScans_Callback(hObject, eventdata, handles)
if get(hObject,'value')==1
    set([handles.CumulativeScansChoices,handles.axes5],'Visible','on');
    if get(handles.CumulativePumpButton,'value') == 1
        plot(handles.axes5,handles.CumulativePump);
        set(handles.axes5,'YTick',[],'XTick',[]);         %Remove all labels from cumulative plot
        xlim(handles.axes5,[1 length(handles.CumulativePump)]);
    elseif get(handles.CumulativeProbeButton,'value') == 1
        plot(handles.axes5,handles.CumulativeProbe);
        set(handles.axes5,'YTick',[],'XTick',[]);         %Remove all labels from cumulative plot
        xlim(handles.axes5,[1 length(handles.CumulativeProbe)]);
    else
        plot(handles.axes5,handles.CumulativePaP);
        set(handles.axes5,'YTick',[],'XTick',[]);         %Remove all labels from cumulative plot
        xlim(handles.axes5,[1 length(handles.CumulativePaP)]);
    end
else
    set([handles.CumulativeScansChoices,handles.axes5],'Visible','off');
    cla(handles.axes5)
end
guidata(hObject, handles);


%Switch choice to show pump, probe or PaP on cumulative scans axes 5
function CumulativeScansChoices_SelectionChangeFcn(hObject, eventdata, handles)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case'CumulativePumpButton'
        plot(handles.axes5,handles.CumulativePump);
    	set(handles.axes5,'YTick',[],'XTick',[]);         %Remove all labels from cumulative plot
        xlim(handles.axes5,[1 length(handles.CumulativePump)]);
    case'CumulativeProbeButton'
        plot(handles.axes5,handles.CumulativeProbe);
        set(handles.axes5,'YTick',[],'XTick',[]);         %Remove all labels from cumulative plot
        xlim(handles.axes5,[1 length(handles.CumulativeProbe)]);
    case'CumulativePaPButton'
        plot(handles.axes5,handles.CumulativePaP);
        set(handles.axes5,'YTick',[],'XTick',[]);         %Remove all labels from cumulative plot
        xlim(handles.axes5,[1 length(handles.CumulativePaP)]);
end





%Plot options for main graph
function MainPlotGraph(xdata,ydata,zdata,yaxislabel,xaxislabel,minimumx,maximumx,minimumy,maximumy,ThreeD)
%xdata/ydata/zdata- data for the main plot
%yaxislabel- checks lin-log or lin timescale with appropriate labels
%xaxislabel- data calibration check for correct x axis labeling
%minimumx/maximumx- set x axis limits
global azglobal elglobal
handles= guidata(gcbo);    %load in handles as this is a function, not a callback

assignin('base', 'x', xdata);
assignin('base', 'y', ydata);
assignin('base', 'z', zdata);

% Plot data and apply correct y axis values
if ThreeD==0
    pcolor(handles.axes1,xdata,ydata,zdata)
elseif ThreeD==1
    [az el] = view; %Gets the view point
    if az==0 & el==90 %If previuosly in 2D, reset to default view
        az=azglobal;
        el=elglobal;
    else
        azglobal=az; %else saves new values
        elglobal=el;
    end   
    surf(handles.axes1,xdata,ydata,zdata)
    axes(handles.axes1)
    view([az el])
    zlim([((min(min(handles.MainZData)))-(0.02*(min(min(zdata))))) (1.12*max(max(zdata)))])
    xlim([minimumx maximumx])
    if yaxislabel==0;
        ylim([(minimumy+handles.Yoffsetvalue) (maximumy+handles.Yoffsetvalue)])
    elseif yaxislabel==1
        ylim([minimumy maximumy])
    end
end

if yaxislabel==0;
    set(handles.axes1,'YTick',handles.LinearYTickLabels);
    set(handles.axes1,'YTickLabel',handles.LinearYTickLabels);
    set(handles.MinimumY,'String', (minimumy))%+handles.Yoffsetvalue)) %Update maximum y to actual value
    set(handles.MaximumY,'String', (maximumy))%+handles.Yoffsetvalue)) %Update minimum y to actual value
elseif yaxislabel==1;
    if handles.LinLogYTickLabels(end)~= ydata(end) || handles.LinLogYTickLabels(1)~= ydata(1)
        LinLogYTickLabels=[handles.LinLogYTickLabels,ydata(end),ydata(1)];
        LinearYTickLabels=[handles.LinearYTickLabels,handles.Timestep(find(handles.LinLogScale==max(ydata)))+handles.Yoffsetvalue,handles.Timestep(find(handles.LinLogScale==min(ydata)))+handles.Yoffsetvalue];
        LinLogYTickLabels=unique(LinLogYTickLabels);
        LinearYTickLabels=unique(LinearYTickLabels);
    end
    set(handles.axes1,'YTick',LinLogYTickLabels);
    set(handles.axes1,'YTickLabel',LinearYTickLabels);
    set(handles.MinimumY,'String', (handles.Timestep(find(handles.LinLogScale==minimumy))+handles.Yoffsetvalue)); %Update maximum y to actual value
    set(handles.MaximumY,'String', (handles.Timestep(find(handles.LinLogScale==maximumy))+handles.Yoffsetvalue)); %Update minimum y to actual value
end

%x and y axis labels
if xaxislabel==0;
    xlabel(handles.axes1,'Time of Flight (s)');
else
    xlabel(handles.axes1,'m/q');
end
ylabel(handles.axes1,'Timestep (fs)');

%Update the boundaries of the plots
set(handles.MinimumX,'String', minimumx)                        %Update maximum x to actual value
set(handles.MaximumX,'String', maximumx)                        %Update minimum x to actual value

%Format the plot for no lines and correct colours
axes(handles.axes1)
colormap jet
shading interp  %stops lines appearing on plot

guidata(gcbo,handles)    







%Plot options for side graph
function SidePlotGraph(xdata,ydata,yaxislabel,xminlimit,xmaxlimit,DivisionVector)
%function SidePlotGraph(datafitted,xdata,ydata,yaxislabel,sideplotchoice,xfitdata,yfitdata)
global GaussianFit
%datafitted- Checks if data is fitted
% xdata and ydata- integrated time data
% yaxislabel- Checks if on lin or lin-log timescale
% sideplot choice- checks which side plot is chosen (integrated time, residual etc..)
% xfit and yfit data- fit data

handles= guidata(gcbo);    %load in handles as this is a function, not a callback

cla(handles.axes3);
%Sum xdata
%xdata=(str2num(get(handles.SideGraphPlotScale,'string')))*(sum(xdata(:,xminlimit:xmaxlimit),2));%-min(sum(xdata,2)));
xdata=(sum(xdata(:,xminlimit:xmaxlimit),2))./DivisionVector;
%Plot with user defined limits
if GaussianFit==0
    plot(handles.axes3,xdata,ydata,'-b');
    set(handles.CCInfo,'visible','off')  %Hides cross correlation info
elseif GaussianFit==1;
    %1=Time Offset , 2=FWHM, 3=Y-Offset, 4=Amplitude
    Timesteps=handles.Timestep(handles.YMinimumValueI:handles.YMaximumValueI)+handles.Yoffsetvalue;
    input = [Timesteps(find(xdata == max(xdata)))/1000,0.1 ,min(abs(xdata)),max(xdata)];
    lb=[ min(Timesteps)/1000 , 0.01, min(abs(xdata))*0.5, max(abs(xdata))*0.3];
    ub =[ max(Timesteps)/1000, 0.5, max(abs(xdata))*1.2, max(abs(xdata))*1.4];
    opt  = optimset('TolX',1e-6,'TolFun',1e-6,'MaxFunEvals',3400,'MaxIter',800,'Algorithm','levenberg-marquardt','ScaleProblem','Jacobian','Display','none'); %set the fitting options (note: remove 'Display','off' to see fitting statistics)
    [coeffs,resnorm,residual,exitflag,output,lambda,jacobian]=lsqcurvefit(@ccfit,input,Timesteps,xdata,lb,ub,opt);
    xfit = ccfit(coeffs,Timesteps);    % get fitted fn values
    plot(handles.axes3,xdata,ydata,'ob',xfit,ydata,'-r')%,xdata,ydata);
    conf_int = nlparci(coeffs,residual,'jacobian',jacobian,'alpha',0.05); %Get 95% confidence bound
    set(handles.CCInfo,'visible','on')  %Show box with cross correlation info and update values
    set(handles.text1,'string',['FWHM = ' num2str((round(coeffs(2)*10000))/10) ' fs ' char(177) ' ' num2str((round((abs(conf_int(2,2)-conf_int(2,1)))*10000))/10) ' fs'])
    set(handles.text2,'string',['Time-Offset = ' num2str((round(coeffs(1)*10000))/10) ' fs ' char(177) ' ' num2str((round((abs(conf_int(1,2)-conf_int(1,1)))*10000))/10) ' fs'])
    set(handles.text3,'string',['Y-Offset = ' num2str((round(coeffs(3)*10))/10) ' (arb.) ' char(177) ' ' num2str((round((abs(conf_int(3,2)-conf_int(3,1)))*10))/10) ' (arb.)'])
    set(handles.text4,'string',['Amplitude = ' num2str((round(coeffs(4)*10))/10) ' (arb.) ' char(177) ' ' num2str((round((abs(conf_int(4,2)-conf_int(4,1)))*10))/10) ' (arb.)'])
end    

%Set-up Y-axis labels, Ticks and Limits
if yaxislabel==0;
    set(handles.axes3,'YTick',handles.LinearYTickLabels,'YTickLabel',handles.LinearYTickLabels);
    ylim(handles.axes3,[((handles.Timestep(handles.YMinimumValueI))+handles.Yoffsetvalue) ((handles.Timestep(handles.YMaximumValueI))+handles.Yoffsetvalue)])
elseif yaxislabel==1;
    if handles.LinLogYTickLabels(end)~= ydata(end) || handles.LinLogYTickLabels(1)~= ydata(1)
        LinLogYTickLabels=[handles.LinLogYTickLabels,ydata(end),ydata(1)];
        LinearYTickLabels=[handles.LinearYTickLabels,handles.Timestep(find(handles.LinLogScale==max(ydata)))+handles.Yoffsetvalue,handles.Timestep(find(handles.LinLogScale==min(ydata)))+handles.Yoffsetvalue];
        LinLogYTickLabels=unique(LinLogYTickLabels);
        LinearYTickLabels=unique(LinearYTickLabels);
    end
    set(handles.axes3,'YTick',LinLogYTickLabels,'YTickLabel',LinearYTickLabels);
    ylim(handles.axes3,[handles.LinLogScale(handles.YMinimumValueI) handles.LinLogScale(handles.YMaximumValueI)])
end


% cla(handles.axes3);
% if handles.CaptureSidePlotActive==1;
%     xdata=cat(2,handles.CaptureSidePlotData,((get(handles.SideGraphPlotScale,'value'))*xdata));
%     if yaxislabel==1;
%         ydata=repmat(ydata,[size(xdata,2),1])';
%     elseif yaxislabel==0;
%         ydata=repmat(ydata,[1,size(xdata,2)]);
%     end
% elseif handles.CaptureSidePlotActive==0;
%     xdata=(str2num(get(handles.SideGraphPlotScale,'string')))*xdata;
% end
% 
% xdata=(str2num(get(handles.SideGraphPlotScale,'string')))*xdata;
% if yaxislabel==1;
%     ydata=(1:1:length(ydata));
% end
% if datafitted==0;
%     xdata=((xdata-(min(xdata)))/(max(xdata)-min(xdata)));
%     plot(handles.axes3,xdata,ydata);
% elseif datafitted==1;
%     if sideplotchoice==1;
%         plot(handles.axes3,xdata,ydata,((str2num(get(handles.SideGraphPlotScale,'string')))*xfitdata/(max(xfitdata))),yfitdata,'o');
%         xlim(handles.axes3,[((str2num(get(handles.SideGraphPlotScale,'string')))*(-0.1)) ((str2num(get(handles.SideGraphPlotScale,'string')))*1)])
%     elseif sideplotchoice==2;
%         plot(handles.axes3,((get(handles.SideGraphPlotScale,'value'))*residual),yfitdata,'-');
%         xlim(handles.axes3,[((str2num(get(handles.SideGraphPlotScale,'string')))*(-0.1)) ((str2num(get(handles.SideGraphPlotScale,'string')))*1)])
%     end
% end
% if yaxislabel==0;
%     set(handles.axes3,'YTick',handles.LinearYTickLabels);
%     set(handles.axes3,'YTickLabel',handles.LinearYTickLabels);
%     ylim(handles.axes3,[handles.LinearYTickLabels(handles.MinimumYValueI) handles.LinearYTickLabels(handles.MaximumYValueI)])
% elseif yaxislabel==1;
%     set(handles.axes3,'YTick',handles.LinLogYTickLabels);
%     set(handles.axes3,'YTickLabel',handles.LinearYTickLabels);
%     ylim(handles.axes3,[handles.LinLogYTickLabels(1) handles.LinLogYTickLabels(end)])
% end



%Plot on the bottom graph
function BottomPlotGraph(xdata,ydata)
%xdata and ydata self explanatory
handles= guidata(gcbo);    %load in handles as this is a function, not a callback
plot(handles.axes2,xdata,sum(ydata),'-b')%(handles.YMinimumValueI:handles.YMaximumValueI,handles.XMinimumValueI:handles.XMaximumValueI)));
xlim(handles.axes2,[xdata(1) xdata(end)]);
guidata(gcbo,handles)





function [xdata,ydata,zdata,FullZData]=PlotUpdate(situation) %[Zsumallmq,Zsumalltime]=PlotUpdate(situation)
global DivisionVector
handles= guidata(gcbo);    %load in handles as this is a function, not a callback

%Situation(1)=Calibration
%Situation(2)=Asthetic changes (i.e. changing to lin-log scales, altering limits etc...)

%NOTE: loggeddatasubtract used when background subtract and log Z chosen due
%to when subtracting some values are below zero and require offste to make
%minimal zero, which is then set to 1e-4 to prevent -inf


%MainPlotGraph(xdata,ydata,zdata,yaxislabel,xaxislabel,minimumx,maximumx,minimumy,maximumy)
if situation==1;        %If step is to calibrate the data
%X-data and z-data choices    
if handles.DataAlreadyCalibrated==0;
    xdata=handles.MQCal(handles.XMinimumValueI:handles.XMaximumValueI);
    xaxislabel=1;
    minimumx=handles.MQCal(handles.XMinimumValueI);
    maximumx=handles.MQCal(handles.XMaximumValueI);
    if get(handles.ZAxisBackground,'value') == 1;
       zdata=bsxfun(@minus,handles.ZCalNonZero(handles.YMinimumValueI:handles.YMaximumValueI,handles.XMinimumValueI:handles.XMaximumValueI),handles.BackgroundSubtraction(handles.XMinimumValueI:handles.XMaximumValueI));
       FullZData=bsxfun(@minus,handles.ZCalNonZero(handles.YMinimumValueI:handles.YMaximumValueI,:),handles.BackgroundSubtraction);
       if min(min(FullZData)) < 0   %If the minimum value drops below zero, re-offset to whole data
           zdata=zdata-min(min(FullZData));
           FullZData=FullZData-min(min(FullZData));
       end
    else
       zdata=handles.ZCalNonZero(handles.YMinimumValueI:handles.YMaximumValueI,handles.XMinimumValueI:handles.XMaximumValueI);
       FullZData=handles.ZCalNonZero(handles.YMinimumValueI:handles.YMaximumValueI,:);
    end 
else
    xdata=handles.TData(handles.XMinimumValueI:handles.XMaximumValueI);
    xaxislabel=0;
    minimumx=handles.TData(handles.XMinimumValueI);
    maximumx=handles.TData(handles.XMaximumValueI);
    if get(handles.ZAxisBackground,'value') == 1;
       zdata=bsxfun(@minus,handles.PlotData(handles.YMinimumValueI:handles.YMaximumValueI,handles.XMinimumValueI:handles.XMaximumValueI),handles.BackgroundSubtraction(handles.XMinimumValueI:handles.XMaximumValueI));
       FullZData=bsxfun(@minus,handles.PlotData(handles.YMinimumValueI:handles.YMaximumValueI,:),handles.BackgroundSubtraction);
       if min(min(FullZData)) < 0   %If the minimum value drops below zero, re-offset to whole data
           zdata=zdata-min(min(FullZData));
           FullZData=FullZData-min(min(FullZData));
       end
    else
       zdata=handles.PlotData(handles.YMinimumValueI:handles.YMaximumValueI,handles.XMinimumValueI:handles.XMaximumValueI);
       FullZData=handles.PlotData(handles.YMinimumValueI:handles.YMaximumValueI,:);
    end
end

%Log z-data choice
if get(handles.LinLogZAxis,'value') == 1;
    zdata=log((zdata-min(min(zdata)))+1);
    FullZData=log((FullZData-min(min(FullZData)))+1);
end

%Y-data choices
if get(handles.LinLogYAxis,'value') == 0;
    ydata=(handles.Timestep(handles.YMinimumValueI:handles.YMaximumValueI))+handles.Yoffsetvalue;
    minimumy=(handles.Timestep(handles.YMinimumValueI))+handles.Yoffsetvalue;
    maximumy=(handles.Timestep(handles.YMaximumValueI))+handles.Yoffsetvalue;
    yaxislabel=0;
else
    ydata=handles.LinLogScale(handles.YMinimumValueI:handles.YMaximumValueI);
    minimumy=handles.LinLogScale(handles.YMinimumValueI);
    maximumy=handles.LinLogScale(handles.YMaximumValueI);
%     ydata=handles.YMinimumValueI:1:handles.YMaximumValueI;
%     minimumy=handles.YMinimumValueI;
%     maximumy=handles.YMaximumValueI;
    yaxislabel=1;
end

%MainPlot Update
MainPlotGraph(xdata,ydata,zdata,yaxislabel,xaxislabel,minimumx,maximumx,minimumy,maximumy,handles.ThreeDPlot)

%Select y data for side plot
if get(handles.LinLogYAxis,'value') == 0;
    sydata=handles.Timestep+handles.Yoffsetvalue;
else
    sydata=handles.LinLogScale;
    %sydata=1:1:length(handles.Timestep);
end    

%As not divide subtraction during calibration/recalibraton, DivisionVector is just ones
DivisionVector=ones((handles.YMaximumValueI-handles.YMinimumValueI+1),1);

%SidePlot Update
SidePlotGraph(zdata,sydata,get(handles.LinLogYAxis,'value'),handles.XMinimumValueI,handles.XMaximumValueI,DivisionVector)

%Select x data for bottom plot
if handles.DataAlreadyCalibrated==0;
    bxdata=handles.MQCal;
else
    bxdata=handles.TData;
end

%BottomPlot Update
BottomPlotGraph(bxdata,zdata)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif situation==2;        %If step is to change asthetics of the data

%X-data and z-data choices    
if handles.DataAlreadyCalibrated==0;
    xdata=handles.TData(handles.XMinimumValueI:handles.XMaximumValueI);
    xaxislabel=0;
    minimumx=handles.TData(handles.XMinimumValueI);
    maximumx=handles.TData(handles.XMaximumValueI);
    if get(handles.ZAxisBackground,'value') == 1;
       zdata=bsxfun(@minus,handles.PlotData(handles.YMinimumValueI:handles.YMaximumValueI,handles.XMinimumValueI:handles.XMaximumValueI),handles.BackgroundSubtraction(handles.XMinimumValueI:handles.XMaximumValueI));
       FullZData=bsxfun(@minus,handles.PlotData(handles.YMinimumValueI:handles.YMaximumValueI,:),handles.BackgroundSubtraction);
       if min(min(FullZData)) < 0   %If the minimum value drops below zero, re-offset to whole data
           zdata=zdata-min(min(FullZData));
           FullZData=FullZData-min(min(FullZData));
       end
    else
       zdata=handles.PlotData(handles.YMinimumValueI:handles.YMaximumValueI,handles.XMinimumValueI:handles.XMaximumValueI);
       FullZData=handles.PlotData(handles.YMinimumValueI:handles.YMaximumValueI,:);
    end
else
    xdata=handles.MQCal(handles.XMinimumValueI:handles.XMaximumValueI);
    xaxislabel=1;
    minimumx=handles.MQCal(handles.XMinimumValueI);
    maximumx=handles.MQCal(handles.XMaximumValueI);
    if get(handles.ZAxisBackground,'value') == 1;
       zdata=bsxfun(@minus,handles.ZCalNonZero(handles.YMinimumValueI:handles.YMaximumValueI,handles.XMinimumValueI:handles.XMaximumValueI),handles.BackgroundSubtraction(handles.XMinimumValueI:handles.XMaximumValueI));
       FullZData=bsxfun(@minus,handles.ZCalNonZero(handles.YMinimumValueI:handles.YMaximumValueI,:),handles.BackgroundSubtraction);          
       if min(min(FullZData)) < 0   %If the minimum value drops below zero, re-offset to whole data
           zdata=zdata-min(min(FullZData));
           FullZData=FullZData-min(min(FullZData));
       end
    else
       zdata=handles.ZCalNonZero(handles.YMinimumValueI:handles.YMaximumValueI,handles.XMinimumValueI:handles.XMaximumValueI);
       FullZData=handles.ZCalNonZero(handles.YMinimumValueI:handles.YMaximumValueI,:);
    end 
end

%Averaging zdata and FullZData
switch get(get(handles.PointAveragingPanel,'SelectedObject'),'Tag') % Get Tag of selected object.
    case 'NoAveragingBut'
        zdata=zdata;
        FullZData=FullZData;
    case 'ThreePointAveragingBut'
        j=zdata; %zdata 3 Point Average
        l=(j(1,:)+j(2,:))/2;
        for i =2:size(zdata,1)-1
            l=[l;((j(i-1,:)+j(i,:)+j(i+1,:))/3)];
        end
        zdata=[l;((j(end-1,:)+j(end,:))/2)];
        k=FullZData; %FullZData 3 Point Average
        m=(k(1,:)+k(2,:))/2;
        for i =2:size(FullZData,1)-1
            m=[m;((k(i-1,:)+k(i,:)+k(i+1,:))/3)];
        end
        FullZData=[m;((k(end-1,:)+k(end,:))/2)];
    case 'FivePointAveragingBut'
        j=zdata; %zdata 5 Point Average
        l=(j(1,:)+j(2,:)+j(3,:))/3;
        l=[l;((j(1,:)+j(2,:)+j(3,:)+j(4,:))/4)];
        for i =3:size(zdata,1)-2
            l=[l;((j(i-2,:)+j(i-1,:)+j(i,:)+j(i+1,:)+j(i+2,:))/5)];
        end
        l=[l;((j(end-3,:)+j(end-2,:)+j(end-1,:)+j(end,:))/4)];
        zdata=[l;(j(end-2,:)+j(end-1,:)+j(end,:))/3];
        k=FullZData; %FullZData 5 Point Average
        m=(k(1,:)+k(2,:)+k(3,:))/3;
        m=[m;((k(1,:)+k(2,:)+k(3,:)+k(4,:))/4)];
        for i =3:size(FullZData,1)-2
            m=[m;((k(i-2,:)+k(i-1,:)+k(i,:)+k(i+1,:)+k(i+2,:))/5)];
        end
        m=[m;((k(end-3,:)+k(end-2,:)+k(end-1,:)+k(end,:))/4)];
        FullZData=[m;(k(end-2,:)+k(end-1,:)+k(end,:))/3];
end

%Log z-data choice
if get(handles.LinLogZAxis,'value') == 1;
    zdata=log((zdata-min(min(zdata)))+1);  %Incase for some reason there's been a fail and minimum isn't zero
    FullZData=log((FullZData-min(min(FullZData)))+1);
end

%Y-data choices
if get(handles.LinLogYAxis,'value') == 0;
    ydata=(handles.Timestep(handles.YMinimumValueI:handles.YMaximumValueI))+handles.Yoffsetvalue;
    minimumy=(handles.Timestep(handles.YMinimumValueI))+handles.Yoffsetvalue;
    maximumy=(handles.Timestep(handles.YMaximumValueI))+handles.Yoffsetvalue;
    yaxislabel=0;
else
    ydata=handles.LinLogScale(handles.YMinimumValueI:handles.YMaximumValueI);
    minimumy=handles.LinLogScale(handles.YMinimumValueI);
    maximumy=handles.LinLogScale(handles.YMaximumValueI);
%     ydata=handles.YMinimumValueI:1:handles.YMaximumValueI;
%     minimumy=handles.YMinimumValueI;
%     maximumy=handles.YMaximumValueI;
    yaxislabel=1;
end

%Creates Handles of the Main Plot Data
handles.MainXData=xdata;
handles.MainYData=ydata;
handles.MainZData=zdata;
handles.FullZData=FullZData;

%MainPlot Update
MainPlotGraph(xdata,ydata,zdata,yaxislabel,xaxislabel,minimumx,maximumx,minimumy,maximumy,handles.ThreeDPlot)

%Select y data for side plot
if get(handles.LinLogYAxis,'value') == 0;
    sydata=(handles.Timestep(handles.YMinimumValueI:handles.YMaximumValueI)+handles.Yoffsetvalue);
else
    sydata=handles.LinLogScale(handles.YMinimumValueI:handles.YMaximumValueI);
    %sydata=handles.YMinimumValueI:1:handles.YMaximumValueI;
end

%Finds slider regions for side plot data
XDataMinSlider=min(get(handles.LeftSlider,'value'));
XDataMaxSlider=max(get(handles.RightSlider,'value'));
[~,DataLimitLeftIndex]=min(abs(handles.MainXData-XDataMinSlider));
[~,DataLimitRightIndex]=min(abs(handles.MainXData-XDataMaxSlider));

%Create a peak background vector to subtract if pumpdiv, probediv or papdiv active
SelectionCheck=get(get(handles.uipanel23,'SelectedObject'),'Tag'); %Used to check if a region is currently selected outwith the alowed regions (e.g. region 5 when only 4 regions)
if get(handles.GlobalFitButton,'value')==0
    if strcmp(SelectionCheck,'PumpDiv')==1 
        DivisionVector=sum(handles.PumpCal(handles.YMinimumValueI:handles.YMaximumValueI,(DataLimitLeftIndex+handles.XMinimumValueI-1):(DataLimitRightIndex+handles.XMinimumValueI-1)),2);
    elseif strcmp(SelectionCheck,'ProbeDiv')==1 
        DivisionVector=sum(handles.ProbeCal(handles.YMinimumValueI:handles.YMaximumValueI,(DataLimitLeftIndex+handles.XMinimumValueI-1):(DataLimitRightIndex+handles.XMinimumValueI-1)),2);
    elseif strcmp(SelectionCheck,'PaPDiv')==1
        DivisionVector=handles.PumpCal(handles.YMinimumValueI:handles.YMaximumValueI,(DataLimitLeftIndex+handles.XMinimumValueI-1):(DataLimitRightIndex+handles.XMinimumValueI-1))+handles.ProbeCal(handles.YMinimumValueI:handles.YMaximumValueI,(DataLimitLeftIndex+handles.XMinimumValueI-1):(DataLimitRightIndex+handles.XMinimumValueI-1));
        DivisionVector=sum(DivisionVector,2);
    else
        DivisionVector=ones((handles.YMaximumValueI-handles.YMinimumValueI+1),1);
    end
end

if get(handles.GlobalFitButton,'value')==1;
    if strcmp(SelectionCheck,'PumpDiv')==1 || strcmp(SelectionCheck,'ProbeDiv')==1 || strcmp(SelectionCheck,'PaPDiv')==1
        if strcmp(SelectionCheck,'PumpDiv')==1
            BackgroundChoice=handles.PumpCal;
        elseif strcmp(SelectionCheck,'ProbeDiv')==1
            BackgroundChoice=handles.ProbeCal;
        elseif strcmp(SelectionCheck,'PaPDiv')==1
            BackgroundChoice=handles.PumpCal+handles.ProbeCal;
        end
        DivisionVector=[];
        handles.MaxAndMinRegions=[str2num(get(handles.Slider1Min,'string')),str2num(get(handles.Slider1Max,'string'));str2num(get(handles.Slider2Min,'string')),str2num(get(handles.Slider2Max,'string'));str2num(get(handles.Slider3Min,'string')),str2num(get(handles.Slider3Max,'string'));str2num(get(handles.Slider4Min,'string')),str2num(get(handles.Slider4Max,'string'));str2num(get(handles.Slider5Min,'string')),str2num(get(handles.Slider5Max,'string'))]; %Gets the Maximum and Minimum Values set for the sliders
        SummationDivPeaks=find(handles.GlobalDivPeak(1:handles.NoRegions)==1);
        for i=1:length(SummationDivPeaks)
            [~,LeftSliderPosition] = min(abs(handles.MQCal-handles.MaxAndMinRegions(SummationDivPeaks(i),1)));
            [~,RightSliderPosition] = min(abs(handles.MQCal-handles.MaxAndMinRegions(SummationDivPeaks(i),2)));
            DivisionVector=[DivisionVector,sum(BackgroundChoice(handles.YMinimumValueI:handles.YMaximumValueI,LeftSliderPosition:RightSliderPosition),2)];
        end
        DivisionVector=sum(DivisionVector,2);
    else
        DivisionVector=ones((handles.YMaximumValueI-handles.YMinimumValueI+1),1);
    end
end

%Averaging DivisionVector
switch get(get(handles.PointAveragingPanel,'SelectedObject'),'Tag') % Get Tag of selected object.
    case 'NoAveragingBut'
        DivisionVector=DivisionVector;
    case 'ThreePointAveragingBut'
        j=DivisionVector;
        l=(j(1,:)+j(2,:))/2;
        for i =2:size(DivisionVector,1)-1
            l=[l;((j(i-1,:)+j(i,:)+j(i+1,:))/3)];
        end
        DivisionVector=[l;((j(end-1,:)+j(end,:))/2)];
    case 'FivePointAveragingBut'
        j=DivisionVector;
        l=(j(1,:)+j(2,:)+j(3,:))/3;
        l=[l;((j(1,:)+j(2,:)+j(3,:)+j(4,:))/4)];
        for i =3:size(DivisionVector,1)-2
            l=[l;((j(i-2,:)+j(i-1,:)+j(i,:)+j(i+1,:)+j(i+2,:))/5)];
        end
        l=[l;((j(end-3,:)+j(end-2,:)+j(end-1,:)+j(end,:))/4)];
        DivisionVector=[l;(j(end-2,:)+j(end-1,:)+j(end,:))/3];
end


%SidePlot Update
SidePlotGraph(zdata,sydata,get(handles.LinLogYAxis,'value'),DataLimitLeftIndex,DataLimitRightIndex,DivisionVector)

%Select x data for bottom plot
if handles.DataAlreadyCalibrated==0;
    bxdata=handles.TData(handles.XMinimumValueI:handles.XMaximumValueI);
else
    bxdata=handles.MQCal(handles.XMinimumValueI:handles.XMaximumValueI);
end

%BottomPlot Update
BottomPlotGraph(bxdata,zdata)

end

guidata(gcbo,handles)

%Background Removal Options
function uipanel23_SelectionChangeFcn(hObject, eventdata, handles)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'NoSubOrDiv'   %If no background subtraction or division
        set([handles.DivPeak1,handles.DivPeak2,handles.DivPeak3,handles.DivPeak4,handles.DivPeak5],'enable','off') %Turn off division peaks options
        if handles.DataAlreadyCalibrated==0;
            handles.PlotData=transpose(handles.PumpAndProbeData);
        else
            handles.ZCalNonZero=handles.PlotData(:,handles.MQZeroCutoff:end);
        end
        guidata(hObject, handles);
        [handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2);    %Update Plot data
        guidata(hObject, handles);
        %Set-Up Cursors Again
        if handles.DataAlreadyCalibrated==0;
            SliderUpdateReset(handles.TData(handles.XMinimumValueI),handles.TData(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
        else
            if get(handles.GlobalFitButton,'value') == 1;
                GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
            else
                SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
            end
        end
    case 'PumpSub'  %If Pump Background Subtraction
        set([handles.DivPeak1,handles.DivPeak2,handles.DivPeak3,handles.DivPeak4,handles.DivPeak5],'enable','off') %Turn off division peaks options
        if handles.DataAlreadyCalibrated==0;
            handles.PlotData=(transpose(handles.PumpAndProbeData))-(transpose(handles.PumpData));
        else
            handles.ZCalNonZero=(handles.PlotData(:,handles.MQZeroCutoff:end))-handles.PumpCal;
        end
        guidata(hObject, handles);
        [handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2);    %Update Plot data
        guidata(hObject, handles);
        %Set-Up Cursors Again
        if handles.DataAlreadyCalibrated==0;
            SliderUpdateReset(handles.TData(handles.XMinimumValueI),handles.TData(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
        else
            if get(handles.GlobalFitButton,'value') == 1;
                GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
            else
                SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
            end
        end    
    case 'ProbeSub' %If Probe Background Subtraction
        set([handles.DivPeak1,handles.DivPeak2,handles.DivPeak3,handles.DivPeak4,handles.DivPeak5],'enable','off') %Turn off division peaks options
        if handles.DataAlreadyCalibrated==0;
            handles.PlotData=(transpose(handles.PumpAndProbeData))-(transpose(handles.ProbeData));
        else
            handles.ZCalNonZero=(handles.PlotData(:,handles.MQZeroCutoff:end))-handles.ProbeCal;
        end
        guidata(hObject, handles);
        [handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2);    %Update Plot data
        guidata(hObject, handles);
        %Set-Up Cursors Again
        if handles.DataAlreadyCalibrated==0;
            SliderUpdateReset(handles.TData(handles.XMinimumValueI),handles.TData(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
        else
            if get(handles.GlobalFitButton,'value') == 1;
                GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
            else
                SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
            end
        end    
    case 'PaPSub'   %If Pump and Probe Background Subtraction
        set([handles.DivPeak1,handles.DivPeak2,handles.DivPeak3,handles.DivPeak4,handles.DivPeak5],'enable','off') %Turn off division peaks options
        if handles.DataAlreadyCalibrated==0;
            handles.PlotData=(transpose(handles.PumpAndProbeData))-((transpose(handles.ProbeData))+(transpose(handles.PumpData)));
        else
            handles.ZCalNonZero=(handles.PlotData(:,handles.MQZeroCutoff:end))-(handles.ProbeCal+handles.PumpCal);
        end
        guidata(hObject, handles);
        [handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2);    %Update Plot data
        guidata(hObject, handles);
        %Set-Up Cursors Again
        if handles.DataAlreadyCalibrated==0;
            SliderUpdateReset(handles.TData(handles.XMinimumValueI),handles.TData(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
        else
            if get(handles.GlobalFitButton,'value') == 1;
                GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
            else
                SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
            end
        end
    case 'PumpDiv'   %If Pump division, show plots for no subtraction
        for i=1:handles.NoRegions
            set(handles.(['DivPeak' num2str(i)]),'enable','on')
        end
        if handles.DataAlreadyCalibrated==0;
            handles.PlotData=transpose(handles.PumpAndProbeData);
        else
            handles.ZCalNonZero=handles.PlotData(:,handles.MQZeroCutoff:end);
        end
        guidata(hObject, handles);
        [handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2);    %Update Plot data
        guidata(hObject, handles);
        %Set-Up Cursors Again
        if handles.DataAlreadyCalibrated==0;
            SliderUpdateReset(handles.TData(handles.XMinimumValueI),handles.TData(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
        else
            if get(handles.GlobalFitButton,'value') == 1;
                GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
            else
                SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
            end
        end
    case 'ProbeDiv'   %If Probe division, show plots for no subtraction
        for i=1:handles.NoRegions
            set(handles.(['DivPeak' num2str(i)]),'enable','on')
        end
        if handles.DataAlreadyCalibrated==0;
            handles.PlotData=transpose(handles.PumpAndProbeData);
        else
            handles.ZCalNonZero=handles.PlotData(:,handles.MQZeroCutoff:end);
        end
        guidata(hObject, handles);
        [handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2);    %Update Plot data
        guidata(hObject, handles);
        %Set-Up Cursors Again
        if handles.DataAlreadyCalibrated==0;
            SliderUpdateReset(handles.TData(handles.XMinimumValueI),handles.TData(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
        else
            if get(handles.GlobalFitButton,'value') == 1;
                GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
            else
                SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
            end
        end
    case 'PaPDiv'   %If Pump and Probe division, show plots for no subtraction
        for i=1:handles.NoRegions
            set(handles.(['DivPeak' num2str(i)]),'enable','on')
        end
        if handles.DataAlreadyCalibrated==0;
            handles.PlotData=transpose(handles.PumpAndProbeData);
        else
            handles.ZCalNonZero=handles.PlotData(:,handles.MQZeroCutoff:end);
        end
        guidata(hObject, handles);
        [handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2);    %Update Plot data
        guidata(hObject, handles);
        %Set-Up Cursors Again
        if handles.DataAlreadyCalibrated==0;
            SliderUpdateReset(handles.TData(handles.XMinimumValueI),handles.TData(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
        else
            if get(handles.GlobalFitButton,'value') == 1;
                GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
            else
                SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
            end
        end
end


function SliderUpdateReset(minimumx,maximumx,minimumy,maximumy,ThreeD)

handles= guidata(gcbo);    %load in handles as this is a function, not a callback

if get(handles.LinLogYAxis,'value')==1
    minimumy=handles.MainYData(1);
    maximumy=handles.MainYData(end);
end

zmax=max(max(handles.MainZData)); %Used to position bars just above data

%Set-up cursors positions and limits
axes(handles.axes1);
if get(handles.LeftSlider,'Value')<minimumx || get(handles.LeftSlider,'Value')>maximumx || strcmp(get(handles.SidePlotOptions,'visible'),'off')==1
    if ThreeD==0
        LowSlider=line((ones(1,2)*minimumx),[minimumy,maximumy],'linestyle','-','Color',[1 0 0],'Tag','left slider');
    elseif ThreeD==1;
        LowSlider=line((ones(1,2)*minimumx),[minimumy,maximumy],(ones(1,2)*(zmax*1.1)),'linestyle','-','Color',[1 0 0],'Tag','left slider');
    end
    set(handles.LeftSlider,'Min',minimumx,'Max',maximumx,'Value',minimumx);
else
    if ThreeD==0
        LowSlider=line((ones(1,2)*get(handles.LeftSlider,'Value')),[minimumy,maximumy],'linestyle','-','Color',[1 0 0],'Tag','left slider');
    elseif ThreeD==1
        LowSlider=line((ones(1,2)*get(handles.LeftSlider,'Value')),[minimumy,maximumy],(ones(1,2)*(zmax*1.1)),'linestyle','-','Color',[1 0 0],'Tag','left slider');
    end
    set(handles.LeftSlider,'Min',minimumx,'Max',maximumx);
end
if get(handles.RightSlider,'Value')>maximumx || get(handles.RightSlider,'Value')<minimumx || strcmp(get(handles.SidePlotOptions,'visible'),'off')==1 || (get(handles.RightSlider,'Value') <= 1 && maximumx > 10)
    if ThreeD==0
        HighSlider=line((ones(1,2)*maximumx),[minimumy,maximumy],'linestyle','-','Color',[1 0 0],'Tag','right slider');
    elseif ThreeD==1
        HighSlider=line((ones(1,2)*maximumx),[minimumy,maximumy],(ones(1,2)*(zmax*1.1)),'linestyle','-','Color',[1 0 0],'Tag','right slider');
    end
    set(handles.RightSlider,'Min',minimumx,'Max',maximumx,'Value',maximumx);       
else
    if ThreeD==0
        HighSlider=line((ones(1,2)*get(handles.RightSlider,'Value')),[minimumy,maximumy],'linestyle','-','Color',[1 0 0],'Tag','right slider');
    elseif ThreeD==1
        HighSlider=line((ones(1,2)*get(handles.RightSlider,'Value')),[minimumy,maximumy],(ones(1,2)*(zmax*1.1)),'linestyle','-','Color',[1 0 0],'Tag','right slider');
    end
    set(handles.RightSlider,'Min',minimumx,'Max',maximumx);
end
guidata(gcbo,handles)


%Switching Panel (Chooses the correct Panels to show) for the Calibration, Manipulation and Fitting Section
function uipanel2_SelectionChangeFcn(hObject, eventdata, handles)
HandlesVisibleFittingArray = [handles.axes4, handles.uipanel13, handles.uipanel11];
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'LoadDataCalibration'
        set(handles.uipanel1,'visible','on');   %Show load data and calibation panel
        set(handles.uipanel5,'visible','off');  %Hide data manipulation panel
        cla(handles.axes4)
        set(HandlesVisibleFittingArray,'visible', 'off');    %Hide Fitting Panels and Plots
    case 'DataManipulation'
        set(handles.uipanel1,'visible','off');  %Hide load data and calibration panel
        set(handles.uipanel5,'visible','on');   %Show data manipulation panel
        cla(handles.axes4)
        set(HandlesVisibleFittingArray,'visible', 'off');    %Hide Fitting Panels and Plots
    case 'DataFitting'
        set(handles.uipanel1,'visible','off'); %Hide load data and calibration panel
        set(handles.uipanel5,'visible','off'); %Hide data manipulation panel
        set(HandlesVisibleFittingArray,'visible', 'on');    %Hide Fitting Panels and Plots
        set(handles.axes4,'YTick',[],'XTick',[]);         %Remove all labels from opt plot
        axes(handles.axes4), h = plot(0,0); xlim([0 100])
        set(h,'Tag','RSquarePlot');  set(gca,'YTickLabel',[])
        ylabel('');
        xlabel('');
end


%Chooses whether looking at summation or Crosso correlation on side plot
function SidePlotOptions_SelectionChangeFcn(hObject, eventdata, handles)
global GaussianFit
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'IntegratedTimeSideCheck'   %If integrated time
        GaussianFit=0; %Tell it not to fit gaussian
        guidata(hObject, handles)        
        [handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2); %Plot data again
        %Set-Up Cursors Again
        if handles.DataAlreadyCalibrated==0;
            SliderUpdateReset(handles.TData(handles.XMinimumValueI),handles.TData(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
        else
            if get(handles.GlobalFitButton,'value') == 1;
                GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
            else
                SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
            end    
        end
        guidata(hObject, handles);
    case 'CrossCorrelationFitCheck'   %If Cross correlation fit
        GaussianFit=1; %Tell it to fit gaussian
        guidata(hObject, handles)        
        [handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2); %Plot data again
        %Set-Up Cursors Again
        if handles.DataAlreadyCalibrated==0;
            SliderUpdateReset(handles.TData(handles.XMinimumValueI),handles.TData(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
        else
            if get(handles.GlobalFitButton,'value') == 1;
                GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
            else
                SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
            end    
        end
        guidata(hObject, handles);
end

function SideGraphPlotScale_Callback(hObject, eventdata, handles)
% hObject    handle to SideGraphPlotScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SideGraphPlotScale as text
%        str2double(get(hObject,'String')) returns contents of SideGraphPlotScale as a double


% --- Executes during object creation, after setting all properties.
function SideGraphPlotScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SideGraphPlotScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CaptureSidePlot.
function CaptureSidePlot_Callback(hObject, eventdata, handles)
% hObject    handle to CaptureSidePlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in ResetSidePlotCapture.
function ResetSidePlotCapture_Callback(hObject, eventdata, handles)
% hObject    handle to ResetSidePlotCapture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



%Used to change between 2D and 3D on main axis
function DataViewSelection_SelectionChangeFcn(hObject, eventdata, handles)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'TwoDView'
        handles.ThreeDPlot=0;
        rotate3d off
        guidata(hObject, handles);
        [handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2);    %Update Plot data
        guidata(hObject, handles);
        %Set-Up Cursors Again
        if handles.DataAlreadyCalibrated==0;
            SliderUpdateReset(handles.TData(handles.XMinimumValueI),handles.TData(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
        else
            if get(handles.GlobalFitButton,'value') == 1;
                GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
            else
                SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
            end
        end
    case 'ThreeDView'
        handles.ThreeDPlot=1;
        rotate3d on
        guidata(hObject, handles);
        [handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2);    %Update Plot data
        guidata(hObject, handles);
        %Set-Up Cursors Again
        if handles.DataAlreadyCalibrated==0;
            SliderUpdateReset(handles.TData(handles.XMinimumValueI),handles.TData(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
        else
            if get(handles.GlobalFitButton,'value') == 1;
                GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
            else
                SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
            end
        end
end

%On changing aveaging, updates all plots and resets sliders
function PointAveragingPanel_SelectionChangeFcn(hObject, eventdata, handles)

guidata(hObject, handles);
[handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2);              %Update the Plots
guidata(hObject, handles);
    
%Set-Up Cursors Again
if handles.DataAlreadyCalibrated==0;
    SliderUpdateReset(handles.TData(handles.XMinimumValueI),handles.TData(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
else
    if get(handles.GlobalFitButton,'value') == 1;
        GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    else
        SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    end
end

%Alters z-axis between Linear and offsetted logarithmic values
function LinLogZAxis_Callback(hObject, eventdata, handles)
guidata(hObject, handles);
[handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2);              %Update the Plots
guidata(hObject, handles);
    
%Set-Up Cursors Again
if handles.DataAlreadyCalibrated==0;
    SliderUpdateReset(handles.TData(handles.XMinimumValueI),handles.TData(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
else
    if get(handles.GlobalFitButton,'value') == 1;
        GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    else
        SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    end
end


%Subtracts average of first 3 rows from data
function ZAxisBackground_Callback(hObject, eventdata, handles)
guidata(hObject, handles);
[handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2);              %Update the Plots
guidata(hObject, handles);  
%Set-Up Cursors Again
if handles.DataAlreadyCalibrated==0;
    SliderUpdateReset(handles.TData(handles.XMinimumValueI),handles.TData(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
else
    if get(handles.GlobalFitButton,'value') == 1;
        GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    else
        SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    end
end


%Alters y-axis between Linear and Lin-Log
function LinLogYAxis_Callback(hObject, eventdata, handles)

guidata(hObject, handles);
[handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2);              %Update the Plots
guidata(hObject, handles);

    
%Set-Up Cursors Again
if handles.DataAlreadyCalibrated==0;
    SliderUpdateReset(handles.TData(handles.XMinimumValueI),handles.TData(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
else
    if get(handles.GlobalFitButton,'value') == 1;
        GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    else
        SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    end
end


%Selects Maximum Value on the  Y-Axis to Observe
function MaximumY_Callback(hObject, eventdata, handles)

%Check if there are any errors with the user input, then finds closest value in array to user input
if ErrorCheck([str2double(get(handles.MinimumY,'String')),str2double(get(hObject,'String'))],str2double(get(hObject,'String')),(handles.Timestep(1))+handles.Yoffsetvalue,(handles.Timestep(end))+handles.Yoffsetvalue,1,0,0,1,1,0) == 1;
   set(hObject, 'String', num2str((handles.Timestep(end))+handles.Yoffsetvalue)); %reset editbox 
end
[c handles.YMaximumValueI] = min(abs((handles.Timestep+handles.Yoffsetvalue)-str2double(get(hObject,'String'))));
handles.MaximumYValue=(handles.Timestep(handles.YMaximumValueI))+handles.Yoffsetvalue;

%Update editbox and handles
set(hObject, 'String', num2str(handles.MaximumYValue))
guidata(hObject, handles);

%Plot data again
[handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2);

%Set-Up Cursors Again
if handles.DataAlreadyCalibrated==0;
    SliderUpdateReset(handles.TData(handles.XMinimumValueI),handles.TData(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
else
    if get(handles.GlobalFitButton,'value') == 1;
        GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    else
        SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    end    
end

guidata(hObject, handles);


%Creates MaximumY Button on Opening
function MaximumY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MinimumY_Callback(hObject, eventdata, handles)

%Check if there are any errors with the user input, then finds closest value in array to user input
if ErrorCheck([str2double(get(hObject,'String')),str2double(get(handles.MaximumY,'String'))],str2double(get(hObject,'String')),(handles.Timestep(1))+handles.Yoffsetvalue,(handles.Timestep(end))+handles.Yoffsetvalue,1,0,0,1,1,0) == 1;
   set(hObject, 'String', num2str((handles.Timestep(1))+handles.Yoffsetvalue)); %reset editbox 
end
[c handles.YMinimumValueI] = min(abs((handles.Timestep+handles.Yoffsetvalue)-str2double(get(hObject,'String'))));
handles.MinimumYValue=(handles.Timestep(handles.YMinimumValueI))+handles.Yoffsetvalue;

%Update editbox and handles
set(hObject, 'String', num2str(handles.MinimumYValue))
guidata(hObject, handles);

%Plot data again
[handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2);

%Set-Up Cursors Again
if handles.DataAlreadyCalibrated==0;
    SliderUpdateReset(handles.TData(handles.XMinimumValueI),handles.TData(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
else
    if get(handles.GlobalFitButton,'value') == 1;
        GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    else
        SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    end    
end

guidata(hObject, handles);


%Creates MinimumY Button on Opening
function MinimumY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%Selects Maximum Value on the  X-Axis to Observe
function MaximumX_Callback(hObject, eventdata, handles)

%Check if there are any errors with the user input, then finds closest value in array to user input
if handles.DataAlreadyCalibrated == 0
    if ErrorCheck([str2double(get(handles.MinimumX,'String')),str2double(get(hObject,'String'))],str2double(get(hObject,'String')),handles.TData(1),handles.TData(end),1,0,0,1,1,0) == 1;
       set(hObject, 'String', num2str(handles.TData(end))); %reset editbox 
    end
    [c handles.XMaximumValueI] = min(abs(handles.TData-str2double(get(hObject,'String'))));
    handles.MaximumXValue=handles.TData(handles.XMaximumValueI);
else
    if ErrorCheck([str2double(get(handles.MinimumX,'String')),str2double(get(hObject,'String'))],str2double(get(hObject,'String')),handles.MQCal(1),handles.MQCal(end),1,0,0,1,1,0) == 1;
       set(hObject, 'String', num2str(handles.MQCal(end))); %reset editbox 
    end
    [c handles.XMaximumValueI] = min(abs(handles.MQCal-str2double(get(hObject,'String'))));
    handles.MaximumXValue=handles.MQCal(handles.XMaximumValueI);
end

%Update editbox and handles
set(hObject, 'String', num2str(handles.MaximumXValue))
guidata(hObject, handles);

%Plot data again
[handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2);

%Set-Up Cursors Again
if handles.DataAlreadyCalibrated==0;
    SliderUpdateReset(handles.TData(handles.XMinimumValueI),handles.TData(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
else
    if get(handles.GlobalFitButton,'value') == 1;
        GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    else
        SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    end    
end

guidata(hObject, handles);


%Creates MaximumX Button on Opening
function MaximumX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%Selects Minimum Value on the  X-Axis to Observe
function MinimumX_Callback(hObject, eventdata, handles)

%Check if there are any errors with the user input, then finds closest value in array to user input
if handles.DataAlreadyCalibrated == 0
    if ErrorCheck([str2double(get(hObject,'String')),str2double(get(handles.MaximumX,'String'))],str2double(get(hObject,'String')),handles.TData(1),handles.TData(end),1,0,0,1,1,0) == 1;
       set(hObject, 'String', num2str(handles.TData(1))); %reset editbox 
    end
    [c handles.XMinimumValueI] = min(abs(handles.TData-str2double(get(hObject,'String'))));
    handles.MinimumXValue=handles.TData(handles.XMinimumValueI);
else
    if ErrorCheck([str2double(get(hObject,'String')),str2double(get(handles.MaximumX,'String'))],str2double(get(hObject,'String')),handles.MQCal(1),handles.MQCal(end),1,0,0,1,1,0) == 1;
       set(hObject, 'String', num2str(handles.MQCal(1))); %reset editbox 
    end
    [c handles.XMinimumValueI] = min(abs(handles.MQCal-str2double(get(hObject,'String'))));
    handles.MinimumXValue=handles.MQCal(handles.XMinimumValueI);
end

%Update editbox and handles
set(hObject, 'String', num2str(handles.MinimumXValue))
guidata(hObject, handles);

%Plot data again
[handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2);

%Set-Up Cursors Again
if handles.DataAlreadyCalibrated==0;
    SliderUpdateReset(handles.TData(handles.XMinimumValueI),handles.TData(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
else
    if get(handles.GlobalFitButton,'value') == 1;
        GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    else
        SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    end    
end

guidata(hObject, handles);


%Creates MinimumX Button on Opening
function MinimumX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%Allows the user to select which scans to include when looking at the data
function SelectedScans_Callback(hObject, eventdata, handles)
%Gets user input
NumberOfScans=get(handles.SelectedScans,'string');

%If user has forgotten brackets or the last element is a comma, correct for it
if strcmp(NumberOfScans(end),',')==1
    NumberOfScans=NumberOfScans(1:end-1);
end
if strcmp(NumberOfScans(1),'[')==0
    NumberOfScans=strcat('[',NumberOfScans);
end
if strcmp(NumberOfScans(end),']')==0
    NumberOfScans=strcat(NumberOfScans,']');
end
%Converts string to a number and into ascending order
NumberOfScans=unique(sort(str2num(NumberOfScans)));

%If input is not a number vector, reset and leave
if isempty(NumberOfScans)==1;
    NumberOfScans=handles.PreviousNoOfScans
    set(handles.SelectedScans,'String',handles.PreviousScansString)
    errordlg('Not all inputs were valid, reset to previously viewed scans','Error');    %display an error message
    return
end
%Checks maximum is in range of total numer of scans, if not finds nearest number chosen by user

NumberOfScans=NumberOfScans(find(NumberOfScans<=size(handles.MyData,3)));
NumberOfScans=NumberOfScans(find(NumberOfScans>=1));

%If input is a number lower than zero, reset and leave
if isempty(NumberOfScans)==1;
    NumberOfScans=handles.PreviousNoOfScans
    set(handles.SelectedScans,'String',handles.PreviousScansString)
    errordlg('All inputs were out of range, reset to previously viewed scans','Error');    %display an error message
    return
end

%Creates string for presentation This entire for loop just to get values shown in selected scans box. Nothing else!
ScansString='['; %The string to show in the box
for k=1:length(NumberOfScans)
    if k==1
        ScansString=strcat(ScansString, num2str(NumberOfScans(k)));
        if length(NumberOfScans) ~=1
            if NumberOfScans(k+1)-NumberOfScans(k)==1
                ScansString=strcat(ScansString,':');
            else
                ScansString=strcat(ScansString,',');
            end
        end
    elseif k==length(NumberOfScans)
        ScansString=strcat(ScansString, num2str(NumberOfScans(k)));
    else
        if NumberOfScans(k+1)-NumberOfScans(k)==1
            if strcmp(ScansString(end),':')==0
                ScansString=strcat(ScansString,':');
            end
        else
            if NumberOfScans(k)>=10000 %Used to determine how much of the string to look at as numbers of magnitude change this
                x=4;
            elseif NumberOfScans(k)>=1000
                x=3;
            elseif NumberOfScans(k)>=100
                x=2;
            elseif NumberOfScans(k)>=10
                x=1;
            else
                x=0;
            end
            if strcmp(ScansString(end-x:end),num2str((NumberOfScans(k))))==0
                if (k+1)<length(NumberOfScans)
                    ScansString=strcat(ScansString,num2str((NumberOfScans(k))),',',num2str(NumberOfScans(k+1)));
                    
                else
                    ScansString=strcat(ScansString,num2str((NumberOfScans(k))),',');
                end
            else
                if (k+1)<length(NumberOfScans)
                    ScansString=strcat(ScansString,',',num2str(NumberOfScans(k+1)));
                else
                    ScansString=strcat(ScansString,',');
                end
            end
        end
    end
end
ScansString=strcat(ScansString,']');

%Saves handles for next time if inputs are not viable
handles.PreviousScansString=ScansString;
handles.PreviousNoOfScans=NumberOfScans;    

%Updates current string
set(handles.SelectedScans,'String',handles.PreviousScansString)

NewMyData=handles.MyData(:,:,NumberOfScans);


handles.TotalData=((sum(NewMyData,3))*-1); %Sums the data into 2d array and multiplies by -1 to make peaks positive

%Data for cumulative summing of points
handles.CumulativePaP= NewMyData(:,3:3:(3*length(handles.Timestep)),:);
handles.CumulativePaP=-1*(sum(reshape(handles.CumulativePaP,size(handles.CumulativePaP,1),(length(handles.Timestep)*size(handles.CumulativePaP,3))),1));


%Separates Pump, Probe and Pump-Probe Data and Arranges for Plotting, applying offsets where appropriate, as well as summing data to see integrated traces for pump and probe alone data to give an idea of signal
handles.PumpData=handles.TotalData(:,1:3:((3*length(handles.Timestep))-2)); %seperates pump data
if any(any(handles.PumpData))~=0;
    handles.CumulativePump= NewMyData(:,1:3:(3*length(handles.Timestep))-2,:);
    handles.CumulativePump=-1*(sum(reshape(handles.CumulativePump,size(handles.CumulativePump,1),(length(handles.Timestep)*size(handles.CumulativePump,3))),1));
end
handles.ProbeData=handles.TotalData(:,2:3:((3*length(handles.Timestep))-1));    %separates probe data
if any(any(handles.ProbeData)) ~=0 ;
    handles.CumulativeProbe= NewMyData(:,2:3:(3*length(handles.Timestep))-1,:);
    handles.CumulativeProbe=-1*(sum(reshape(handles.CumulativeProbe,size(handles.CumulativeProbe,1),(length(handles.Timestep)*size(handles.CumulativeProbe,3))),1));
end
handles.PumpAndProbeData=handles.TotalData(:,3:3:(3*length(handles.Timestep))); %separates pump-probe data

handles.PlotData=transpose(handles.PumpAndProbeData);

%Takes an average of the first 3 rows as a 'Background' to subtract
handles.BackgroundSubtraction=mean(handles.PlotData(1:3,:));

handles.FullZData=handles.PlotData;

%Needs to reset to No background to stop failures
set(handles.NoSubOrDiv,'value',1);       %Sets so as no background subtraction
set(handles.TwoCSignal,'value',1);       %Viewing main section
if handles.DataAlreadyCalibrated==1
    set(handles.DataFitting,'Enable','on')
end

if handles.DataAlreadyCalibrated==1;
    handles.BackgroundSubtraction=mean(handles.PlotData(1:3,:));
    handles.BackgroundSubtraction=handles.BackgroundSubtraction(handles.MQZeroCutoff:end);
    %Limits data on plot for calibrated x axis values and creates pump and probe alone equivalents
    handles.PlotData=transpose(handles.PumpAndProbeData);
    handles.ZCalNonZero=handles.PlotData(:,handles.MQZeroCutoff:end);
    Pump=transpose(handles.PumpData);
    handles.PumpCal=Pump(:,handles.MQZeroCutoff:end);
    Probe=transpose(handles.ProbeData);
    handles.ProbeCal=Probe(:,handles.MQZeroCutoff:end);
end

guidata(hObject, handles);

%Plot data again
[handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2);

guidata(hObject, handles);

%Set-Up Cursors Again
if handles.DataAlreadyCalibrated==0;
    SliderUpdateReset(handles.TData(handles.XMinimumValueI),handles.TData(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
else
    if get(handles.GlobalFitButton,'value') == 1;
        GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    else
        SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    end    
end

%If cumulative scans on, plot
if get(handles.CumulativeScans,'Value')==1
    SelectionCheck=get(get(handles.CumulativeScansChoices,'SelectedObject'),'Tag'); %Used to check which cumulative scans to view
    if strcmp(SelectionCheck,'CumulativePumpButton')==1
        plot(handles.axes5,handles.CumulativePump)
        set(handles.axes5,'YTick',[],'XTick',[]);         %Remove all labels from cumulative plot
        xlim(handles.axes5,[1 length(handles.CumulativePump)]);
    elseif strcmp(SelectionCheck,'CumulativeProbeButton')==1
        plot(handles.axes5,handles.CumulativeProbe)
        set(handles.axes5,'YTick',[],'XTick',[]);         %Remove all labels from cumulative plot
        xlim(handles.axes5,[1 length(handles.CumulativeProbe)]);
    elseif strcmp(SelectionCheck,'CumulativePaPButton')==1
        plot(handles.axes5,handles.CumulativePaP)
        set(handles.axes5,'YTick',[],'XTick',[]);         %Remove all labels from cumulative plot
        xlim(handles.axes5,[1 length(handles.CumulativePaP)]);
    end
end

guidata(hObject, handles);

function SelectedScans_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%Allows the User to alter the crosscorrelation value for the fit
function cc_Callback(hObject, eventdata, handles)
global CCT
if ErrorCheck(str2double(get(hObject,'String')),0,0,0,1,1,0,0,0,0) == 1;  %Checks if the number is valid
   set(hObject, 'String', 0); %If it fails, reset editbox 
else
    CCT=str2num(get(hObject,'String'))*1000; %Get new cross correlation value
    guidata(hObject, handles);
end

%Create Function for CC value box
function cc_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%Button Pressed to fit the data
function RefitDataItterations_Callback(hObject, eventdata, handles)
disp('Now Fitting Data')
guidata(hObject, handles);
DataFit(1)



%Tells the Fitting Function to Fit Time Constant 1
function t1fit_Callback(hObject, eventdata, handles)
global Decays
Decays(2)=get(hObject,'Value');
%Set enable/disable options depending on if fitted or not
handlesarray=[handles.t1,handles.t1vary,handles.t1Rise,handles.t1Risevary,handles.t1start,handles.URT1,handles.RTO1,handles.t1back];
if Decays(2)==1
    if Decays(37)==1    %If URT
        set(handlesarray,'enable','on');
    elseif Decays(44)==1    %If RTO
        set(handlesarray(3:end),'enable','on');
    else
        set(handlesarray(1:2),'enable','on');
        set(handlesarray(5:8),'enable','on');
    end
elseif Decays(2)==0 %Disable everything if not fitted
    set(handlesarray,'enable','off');
    set(handles.t1start,'value',1);
    Decays(9)=1;
end       
guidata(hObject, handles);
%DataFit(1);

%Tells the Fitting Function to Fit Time Constant 2
function t2fit_Callback(hObject, eventdata, handles)
global Decays
Decays(3)=get(hObject,'Value');
%Set enable/disable options depending on if fitted or not
handlesarray=[handles.t2,handles.t2vary,handles.t2Rise,handles.t2Risevary,handles.t2start,handles.URT2,handles.RTO2,handles.t2back];
if Decays(3)==1
    if Decays(38)==1    %If URT
        set(handlesarray,'enable','on');
    elseif Decays(45)==1    %If RTO
        set(handlesarray(3:end),'enable','on');
    else
        set(handlesarray(1:2),'enable','on');
        set(handlesarray(5:8),'enable','on');
    end
elseif Decays(3)==0 %Disable everything if not fitted
    set(handlesarray,'enable','off');
    set(handles.t2start,'value',1);
    Decays(10)=1;
end       
guidata(hObject, handles);
%DataFit(1);

%Tells the Fitting Function to Fit Time Constant 3
function t3fit_Callback(hObject, eventdata, handles)
global Decays
Decays(4)=get(hObject,'Value');
%Set enable/disable options depending on if fitted or not
handlesarray=[handles.t3,handles.t3vary,handles.t3Rise,handles.t3Risevary,handles.t3start,handles.URT3,handles.RTO3,handles.t3back];
if Decays(4)==1
    if Decays(39)==1    %If URT
        set(handlesarray,'enable','on');
    elseif Decays(46)==1    %If RTO
        set(handlesarray(3:end),'enable','on');
    else
        set(handlesarray(1:2),'enable','on');
        set(handlesarray(5:8),'enable','on');
    end
elseif Decays(4)==0 %Disable everything if not fitted
    set(handlesarray,'enable','off');
    set(handles.t3start,'value',1);
    Decays(11)=1;
end    
guidata(hObject, handles);
%DataFit(1);

%Tells the Fitting Function to Fit Time Constant 4
function t4fit_Callback(hObject, eventdata, handles)
global Decays
Decays(5)=get(hObject,'Value');
%Set enable/disable options depending on if fitted or not
handlesarray=[handles.t4,handles.t4vary,handles.t4Rise,handles.t4Risevary,handles.t4start,handles.URT4,handles.RTO4,handles.t4back];
if Decays(5)==1
    if Decays(40)==1    %If URT
        set(handlesarray,'enable','on');
    elseif Decays(47)==1    %If RTO
        set(handlesarray(3:end),'enable','on');
    else
        set(handlesarray(1:2),'enable','on');
        set(handlesarray(5:8),'enable','on');
    end
elseif Decays(5)==0 %Disable everything if not fitted
    set(handlesarray,'enable','off');
    set(handles.t4start,'value',1);
    Decays(12)=1;
end  
guidata(hObject, handles);
%DataFit(1);

%Tells the Fitting Function to Fit Time Constant 5
function t5fit_Callback(hObject, eventdata, handles)
global Decays
Decays(6)=get(hObject,'Value');
%Set enable/disable options depending on if fitted or not
handlesarray=[handles.t5,handles.t5vary,handles.t5Rise,handles.t5Risevary,handles.t5start,handles.URT5,handles.RTO5,handles.t5back];
if Decays(6)==1
    if Decays(41)==1    %If URT
        set(handlesarray,'enable','on');
    elseif Decays(48)==1    %If RTO
        set(handlesarray(3:end),'enable','on');
    else
        set(handlesarray(1:2),'enable','on');
        set(handlesarray(5:8),'enable','on');
    end
elseif Decays(6)==0 %Disable everything if not fitted
    set(handlesarray,'enable','off');
    set(handles.t5start,'value',1);
    Decays(13)=1;
end  
guidata(hObject, handles);
%DataFit(1);

%Tells the Fitting Function to Fit Time Constant 6
function t6fit_Callback(hObject, eventdata, handles)
global Decays
Decays(7)=get(hObject,'Value');
%Set enable/disable options depending on if fitted or not
handlesarray=[handles.t6,handles.t6vary,handles.t6Rise,handles.t6Risevary,handles.t6start,handles.URT6,handles.RTO6,handles.t6back];
if Decays(7)==1
    if Decays(42)==1    %If URT
        set(handlesarray,'enable','on');
    elseif Decays(49)==1    %If RTO
        set(handlesarray(3:end),'enable','on');
    else
        set(handlesarray(1:2),'enable','on');
        set(handlesarray(5:8),'enable','on');
    end
elseif Decays(7)==0 %Disable everything if not fitted
    set(handlesarray,'enable','off');
    set(handles.t6start,'value',1);
    Decays(14)=1;
end  
guidata(hObject, handles);
%DataFit(1);

%Tells the Fitting Function to Fit Time Constant 7
function t7fit_Callback(hObject, eventdata, handles)
global Decays
Decays(8)=get(hObject,'Value');
%Set enable/disable options depending on if fitted or not
handlesarray=[handles.t7,handles.t7vary,handles.t7Rise,handles.t7Risevary,handles.t7start,handles.URT7,handles.RTO7,handles.t7back];
if Decays(8)==1
    if Decays(43)==1    %If URT
        set(handlesarray,'enable','on');
    elseif Decays(50)==1    %If RTO
        set(handlesarray(3:end),'enable','on');
    else
        set(handlesarray(1:2),'enable','on');
        set(handlesarray(5:8),'enable','on');
    end
elseif Decays(8)==0 %Disable everything if not fitted
    set(handlesarray,'enable','off');
    set(handles.t7start,'value',1);
    Decays(15)=1;
end  
guidata(hObject, handles);
%DataFit(1);



%Tells the Fitting Function about the Rise Time for Time Constant 1
function t1start_Callback(hObject, eventdata, handles)
global Decays
Decays(9)=get(hObject,'Value');
if Decays(9)==2 || Decays(9)==1 || Decays(23)~= Decays(21+Decays(9)) || sum(ismember((find(Decays(2:8))),(Decays(9)-1)))==0   %If following self or zero or decays are in oposite directions or decay to folow is not a fitted channel, reset to zero
    Decays(6)=1;
    set(handles.t1start,'value',1)
    if Decays(37)==1 || Decays(44)==1
       set(handles.t1Risevary,'enable','on')
       set(handles.t1Rise,'enable','on')
    else
       set(handles.t1Risevary,'value',0) 
       set(handles.t1Risevary,'enable','off')
       set(handles.t1Rise,'enable','off')
    end
elseif Decays(42+Decays(9))==1  %Check if following on from a rise time only and reset the RTO to zero and turn off URT, also sequential rise cannto be fixed 
    handlesarray=[handles.RTO1,handles.RTO2,handles.RTO3,handles.RTO4,handles.RTO5,handles.RTO6,handles.RTO7,handles.t1,handles.t2,handles.t3,handles.t4,handles.t5,handles.t6,handles.t7,handles.t1vary,handles.t2vary,handles.t3vary,handles.t4vary,handles.t5vary,handles.t6vary,handles.t7vary];
    Decays(42+Decays(9))=0;
    set(handlesarray(Decays(9)-1),'value',0)
    set(handlesarray(7+(Decays(9)-1)),'enable','on')    %reenables decay guess
    set(handlesarray(14+(Decays(9)-1)),'enable','on')    %reenables decay fix
    Decays(37)=0;   %URT off
    set(handles.URT1,'value',0)
    %Set rise fix off as sequential rise is only limited to previous process
    Decays(30)=0;
    set(handles.t1Risevary,'value',0)
    set(handles.t1Risevary,'enable','off')
    set(handles.t1Rise,'enable','off')
else %Can't have an URT if sequential process
    Decays(37)=0;   %URT off
    set(handles.URT1,'value',0)
    %Set rise fix off as sequential rise is only limited to previous process
    Decays(30)=0;
    set(handles.t1Risevary,'value',0)
    set(handles.t1Risevary,'enable','off')
    set(handles.t1Rise,'enable','off')
end
guidata(hObject, handles);
%DataFit(1);

function t1start_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%Tells the Fitting Function about the Rise Time for Time Constant 2
function t2start_Callback(hObject, eventdata, handles)
global Decays
Decays(10)=get(hObject,'Value');
if Decays(10)==3 || Decays(10)==1|| Decays(24)~= Decays(21+Decays(10)) || sum(ismember((find(Decays(2:8))),(Decays(10)-1)))==0   %If following self or zero or decays are in oposite directions or decay to folow is not a fitted channel, reset to zero
    Decays(10)=1;
    set(handles.t2start,'value',1)
    if Decays(38)==1 || Decays(45)==1
       set(handles.t2Risevary,'enable','on')
       set(handles.t2Rise,'enable','on')
    else
       set(handles.t2Risevary,'value',0)
       set(handles.t2Risevary,'enable','off')
       set(handles.t2Rise,'enable','off')
    end
elseif Decays(42+Decays(10))==1  %Check if following on from a rise time only and reset the RTO to zero and turn off URT
    handlesarray=[handles.RTO1,handles.RTO2,handles.RTO3,handles.RTO4,handles.RTO5,handles.RTO6,handles.RTO7,handles.t1,handles.t2,handles.t3,handles.t4,handles.t5,handles.t6,handles.t7,handles.t1vary,handles.t2vary,handles.t3vary,handles.t4vary,handles.t5vary,handles.t6vary,handles.t7vary];
    Decays(42+Decays(10))=0;
    set(handlesarray(Decays(10)-1),'value',0)
    set(handlesarray(7+(Decays(10)-1)),'enable','on')    %reenables decay guess
    set(handlesarray(14+(Decays(10)-1)),'enable','on')    %reenables decay fix
    Decays(38)=0;   %URT off
    set(handles.URT2,'value',0)
    %Set rise fix off as sequential rise is only limited to previous process
    Decays(31)=0;
    set(handles.t2Risevary,'value',0)
    set(handles.t2Risevary,'enable','off')
    set(handles.t2Rise,'enable','off')
else %Can't have an URT if sequential process
    Decays(38)=0;
    set(handles.URT2,'value',0)
    %Set rise fix off as sequential rise is only limited to previous process
    Decays(31)=0;
    set(handles.t2Risevary,'value',0)
    set(handles.t2Risevary,'enable','off')
    set(handles.t2Rise,'enable','off')
end
guidata(hObject, handles);
%DataFit(1);

function t2start_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%Tells the Fitting Function about the Rise Time for Time Constant 3
function t3start_Callback(hObject, eventdata, handles)
global Decays
Decays(11)=get(hObject,'Value');
if Decays(11)==4 || Decays(11)==1 || Decays(25)~= Decays(21+Decays(11)) || sum(ismember((find(Decays(2:8))),(Decays(11)-1)))==0   %If following self or zero or decays are in oposite directions or decay to folow is not a fitted channel, reset to zero
    Decays(11)=1;
    set(handles.t3start,'value',1)
    if Decays(39)==1 || Decays(46)==1
       set(handles.t3Risevary,'enable','on')
       set(handles.t3Rise,'enable','on')
    else
       set(handles.t3Risevary,'value',0)
       set(handles.t3Risevary,'enable','off')
       set(handles.t3Rise,'enable','off')
    end
elseif Decays(42+Decays(11))==1  %Check if following on from a rise time only and reset the RTO to zero and turn off URT
    handlesarray=[handles.RTO1,handles.RTO2,handles.RTO3,handles.RTO4,handles.RTO5,handles.RTO6,handles.RTO7,handles.t1,handles.t2,handles.t3,handles.t4,handles.t5,handles.t6,handles.t7,handles.t1vary,handles.t2vary,handles.t3vary,handles.t4vary,handles.t5vary,handles.t6vary,handles.t7vary];
    Decays(42+Decays(11))=0;
    set(handlesarray(Decays(11)-1),'value',0)
    set(handlesarray(7+(Decays(11)-1)),'enable','on')    %reenables decay guess
    set(handlesarray(14+(Decays(11)-1)),'enable','on')    %reenables decay fix
    Decays(39)=0;   %URT off
    set(handles.URT3,'value',0)
    %Set rise fix off as sequential rise is only limited to previous process
    Decays(32)=0;
    set(handles.t3Risevary,'value',0)
    set(handles.t3Risevary,'enable','off')
    set(handles.t3Rise,'enable','off')
else %Can't have an URT if sequential process
    Decays(39)=0;
    set(handles.URT3,'value',0)
    %Set rise fix off as sequential rise is only limited to previous process
    Decays(32)=0;
    set(handles.t3Risevary,'value',0)
    set(handles.t3Risevary,'enable','off')
    set(handles.t3Rise,'enable','off')
end
guidata(hObject, handles);
%DataFit(1);

function t3start_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%Tells the Fitting Function about the Rise Time for Time Constant 4
function t4start_Callback(hObject, eventdata, handles)
global Decays
Decays(12)=get(hObject,'Value');
if Decays(12)==5 || Decays(12)==1 || Decays(26)~= Decays(21+Decays(12)) || sum(ismember((find(Decays(2:8))),(Decays(12)-1)))==0   %If following self or zero or decays are in oposite directions or decay to folow is not a fitted channel, reset to zero
    Decays(12)=1;
    set(handles.t4start,'value',1)
    if Decays(40)==1 || Decays(47)==1
       set(handles.t4Risevary,'enable','on')
       set(handles.t4Rise,'enable','on')
    else
       set(handles.t4Risevary,'value',0)
       set(handles.t4Risevary,'enable','off')
       set(handles.t4Rise,'enable','off')
    end
elseif Decays(42+Decays(12))==1  %Check if following on from a rise time only and reset the RTO to zero and turn off URT
    handlesarray=[handles.RTO1,handles.RTO2,handles.RTO3,handles.RTO4,handles.RTO5,handles.RTO6,handles.RTO7,handles.t1,handles.t2,handles.t3,handles.t4,handles.t5,handles.t6,handles.t7,handles.t1vary,handles.t2vary,handles.t3vary,handles.t4vary,handles.t5vary,handles.t6vary,handles.t7vary];
    Decays(42+Decays(12))=0;
    set(handlesarray(Decays(12)-1),'value',0)
    set(handlesarray(7+(Decays(12)-1)),'enable','on')    %reenables decay guess
    set(handlesarray(14+(Decays(12)-1)),'enable','on')    %reenables decay fix
    Decays(40)=0;   %URT off
    set(handles.URT4,'value',0)
    %Set rise fix off as sequential rise is only limited to previous process
    Decays(33)=0;
    set(handles.t4Risevary,'value',0)
    set(handles.t4Risevary,'enable','off')
    set(handles.t4Rise,'enable','off')
else %Can't have an URT if sequential process
    Decays(40)=0;
    set(handles.URT4,'value',0)
    %Set rise fix off as sequential rise is only limited to previous process
    Decays(33)=0;
    set(handles.t4Risevary,'value',0)
    set(handles.t4Risevary,'enable','off')
    set(handles.t4Rise,'enable','off')
end
guidata(hObject, handles);
%DataFit(1);

function t4start_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%Tells the Fitting Function about the Rise Time for Time Constant 5
function t5start_Callback(hObject, eventdata, handles)
global Decays
Decays(13)=get(hObject,'Value');
if Decays(13)==6 || Decays(13)==1 || Decays(27)~= Decays(21+Decays(13)) || sum(ismember((find(Decays(2:8))),(Decays(13)-1)))==0   %If following self or zero or decays are in oposite directions or decay to folow is not a fitted channel, reset to zero
    Decays(13)=1;
    set(handles.t5start,'value',1)
    if Decays(41)==1 || Decays(48)==1
       set(handles.t5Risevary,'enable','on')
       set(handles.t5Rise,'enable','on')
    else
       set(handles.t5Risevary,'value',0)
       set(handles.t5Risevary,'enable','off')
       set(handles.t5Rise,'enable','off')
    end
elseif Decays(42+Decays(13))==1  %Check if following on from a rise time only and reset the RTO to zero and turn off URT
    handlesarray=[handles.RTO1,handles.RTO2,handles.RTO3,handles.RTO4,handles.RTO5,handles.RTO6,handles.RTO7,handles.t1,handles.t2,handles.t3,handles.t4,handles.t5,handles.t6,handles.t7,handles.t1vary,handles.t2vary,handles.t3vary,handles.t4vary,handles.t5vary,handles.t6vary,handles.t7vary];
    Decays(42+Decays(13))=0;
    set(handlesarray(Decays(13)-1),'value',0)
    set(handlesarray(7+(Decays(13)-1)),'enable','on')    %reenables decay guess
    set(handlesarray(14+(Decays(13)-1)),'enable','on')    %reenables decay fix
    Decays(41)=0;   %URT off
    set(handles.URT5,'value',0)
    %Set rise fix off as sequential rise is only limited to previous process
    Decays(34)=0;
    set(handles.t5Risevary,'value',0)
    set(handles.t5Risevary,'enable','off')
    set(handles.t5Rise,'enable','off')
else %Can't have an URT if sequential process
    Decays(41)=0;
    set(handles.URT5,'value',0)
    %Set rise fix off as sequential rise is only limited to previous process
    Decays(34)=0;
    set(handles.t5Risevary,'value',0)
    set(handles.t5Risevary,'enable','off')
    set(handles.t5Rise,'enable','off')
end
guidata(hObject, handles);
%DataFit(1);

function t5start_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%Tells the Fitting Function about the Rise Time for Time Constant 6
function t6start_Callback(hObject, eventdata, handles)
global Decays
Decays(14)=get(hObject,'Value');
if Decays(14)==7 || Decays(14)==1 || Decays(28)~= Decays(21+Decays(14)) || sum(ismember((find(Decays(2:8))),(Decays(14)-1)))==0   %If following self or zero or decays are in oposite directions or decay to folow is not a fitted channel, reset to zero
    Decays(14)=1;
    set(handles.t6start,'value',1)
    if Decays(42)==1 || Decays(49)==1
       set(handles.t6Risevary,'enable','on')
       set(handles.t6Rise,'enable','on')
    else
       set(handles.t6Risevary,'value',0)
       set(handles.t6Risevary,'enable','off')
       set(handles.t6Rise,'enable','off')
    end
elseif Decays(42+Decays(14))==1  %Check if following on from a rise time only and reset the RTO to zero and turn off URT
    handlesarray=[handles.RTO1,handles.RTO2,handles.RTO3,handles.RTO4,handles.RTO5,handles.RTO6,handles.RTO7,handles.t1,handles.t2,handles.t3,handles.t4,handles.t5,handles.t6,handles.t7,handles.t1vary,handles.t2vary,handles.t3vary,handles.t4vary,handles.t5vary,handles.t6vary,handles.t7vary];
    Decays(42+Decays(14))=0;
    set(handlesarray(Decays(14)-1),'value',0)
    set(handlesarray(7+(Decays(14)-1)),'enable','on')    %reenables decay guess
    set(handlesarray(14+(Decays(14)-1)),'enable','on')    %reenables decay fix
    Decays(42)=0;   %URT off
    set(handles.URT6,'value',0)
    %Set rise fix off as sequential rise is only limited to previous process
    Decays(35)=0;
    set(handles.t6Risevary,'value',0)
    set(handles.t6Risevary,'enable','off')
    set(handles.t6Rise,'enable','off')
else %Can't have an URT if sequential process
    Decays(42)=0;
    set(handles.URT6,'value',0)
    %Set rise fix off as sequential rise is only limited to previous process
    Decays(35)=0;
    set(handles.t6Risevary,'value',0)
    set(handles.t6Risevary,'enable','off')
    set(handles.t6Rise,'enable','off')
end
guidata(hObject, handles);
%DataFit(1);

function t6start_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%Tells the Fitting Function about the Rise Time for Time Constant 7
function t7start_Callback(hObject, eventdata, handles)
global Decays
Decays(15)=get(hObject,'Value');
if Decays(15)==8 || Decays(15)==1 || Decays(29)~= Decays(21+Decays(15)) || sum(ismember((find(Decays(2:8))),(Decays(15)-1)))==0   %If following self or zero or decays are in oposite directions or decay to folow is not a fitted channel, reset to zero
    Decays(15)=1;
    set(handles.t7start,'value',1)
    if Decays(43)==1 || Decays(50)==1
       set(handles.t7Risevary,'enable','on')
       set(handles.t7Rise,'enable','on')
    else
       set(handles.t7Risevary,'value',0)
       set(handles.t7Risevary,'enable','off')
       set(handles.t7Rise,'enable','off')
    end
elseif Decays(42+Decays(15))==1  %Check if following on from a rise time only and reset the RTO to zero and turn off URT
    handlesarray=[handles.RTO1,handles.RTO2,handles.RTO3,handles.RTO4,handles.RTO5,handles.RTO6,handles.RTO7,handles.t1,handles.t2,handles.t3,handles.t4,handles.t5,handles.t6,handles.t7,handles.t1vary,handles.t2vary,handles.t3vary,handles.t4vary,handles.t5vary,handles.t6vary,handles.t7vary];
    Decays(42+Decays(15))=0;
    set(handlesarray(Decays(15)-1),'value',0)
    set(handlesarray(7+(Decays(15)-1)),'enable','on')    %reenables decay guess
    set(handlesarray(14+(Decays(15)-1)),'enable','on')    %reenables decay fix
    Decays(43)=0;   %URT off
    set(handles.URT7,'value',0)
    %Set rise fix off as sequential rise is only limited to previous process
    Decays(36)=0;
    set(handles.t7Risevary,'value',0)
    set(handles.t7Risevary,'enable','off')
    set(handles.t7Rise,'enable','off')
else %Can't have an URT if sequential process
    Decays(43)=0;
    set(handles.URT7,'value',0)
    %Set rise fix off as sequential rise is only limited to previous process
    Decays(36)=0;
    set(handles.t7Risevary,'value',0)
    set(handles.t7Risevary,'enable','off')
    set(handles.t7Rise,'enable','off')
end
guidata(hObject, handles);
%DataFit(1);

function t7start_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%Tells the Fitting Function about the Boundary Conditions for Time Constant 1
function t1vary_Callback(hObject, eventdata, handles)
global Decays
Decays(16)=get(hObject,'Value');
guidata(hObject, handles);
%DataFit(1);

%Tells the Fitting Function about the Boundary Conditions for Time Constant 2
function t2vary_Callback(hObject, eventdata, handles)
global Decays
Decays(17)=get(hObject,'Value');
guidata(hObject, handles);
%DataFit(1);

%Tells the Fitting Function about the Boundary Conditions for Time Constant 3
function t3vary_Callback(hObject, eventdata, handles)
global Decays
Decays(18)=get(hObject,'Value');
guidata(hObject, handles);
%DataFit(1);

%Tells the Fitting Function about the Boundary Conditions for Time Constant 4
function t4vary_Callback(hObject, eventdata, handles)
global Decays
Decays(19)=get(hObject,'Value');
guidata(hObject, handles);
%DataFit(1);

%Tells the Fitting Function about the Boundary Conditions for Time Constant 5
function t5vary_Callback(hObject, eventdata, handles)
global Decays
Decays(20)=get(hObject,'Value');
guidata(hObject, handles);
%DataFit(1);

%Tells the Fitting Function about the Boundary Conditions for Time Constant 6
function t6vary_Callback(hObject, eventdata, handles)
global Decays
Decays(21)=get(hObject,'Value');
guidata(hObject, handles);
%DataFit(1);

%Tells the Fitting Function about the Boundary Conditions for Time Constant 7
function t7vary_Callback(hObject, eventdata, handles)
global Decays
Decays(22)=get(hObject,'Value');
guidata(hObject, handles);
%DataFit(1);



%Tells the Fitting Function about the Boundary Conditions for Rise Constant 1
function t1Risevary_Callback(hObject, eventdata, handles)
global Decays
Decays(30)=get(hObject,'Value');
guidata(hObject, handles);
%DataFit(1);

%Tells the Fitting Function about the Boundary Conditions for Rise Constant 2
function t2Risevary_Callback(hObject, eventdata, handles)
global Decays
Decays(31)=get(hObject,'Value');
guidata(hObject, handles);
%DataFit(1);

%Tells the Fitting Function about the Boundary Conditions for Rise Constant 3
function t3Risevary_Callback(hObject, eventdata, handles)
global Decays
Decays(32)=get(hObject,'Value');
guidata(hObject, handles);
%DataFit(1);

%Tells the Fitting Function about the Boundary Conditions for Rise Constant 4
function t4Risevary_Callback(hObject, eventdata, handles)
global Decays
Decays(33)=get(hObject,'Value');
guidata(hObject, handles);
%DataFit(1);

%Tells the Fitting Function about the Boundary Conditions for Rise Constant 5
function t5Risevary_Callback(hObject, eventdata, handles)
global Decays
Decays(34)=get(hObject,'Value');
guidata(hObject, handles);
%DataFit(1);

%Tells the Fitting Function about the Boundary Conditions for Rise Constant 6
function t6Risevary_Callback(hObject, eventdata, handles)
global Decays
Decays(35)=get(hObject,'Value');
guidata(hObject, handles);
%DataFit(1);

%Tells the Fitting Function about the Boundary Conditions for Rise Constant 7
function t7Risevary_Callback(hObject, eventdata, handles)
global Decays
Decays(36)=get(hObject,'Value');
guidata(hObject, handles);
%DataFit(1);


%Tells the Fitting Function that Rise Constant 1 is an Unknown, but there is also a decay
function URT1_Callback(hObject, eventdata, handles)
global Decays
Decays(37)=get(hObject,'Value');
handlesarray=[handles.t1,handles.t1vary,handles.t1Rise,handles.t1Risevary];
if Decays(37)==1
    %Can't have sequential lifetime if URT
    Decays(9)=1;
    set(handles.t1start,'value',1);
    %Not a RTO
    Decays(44)=0;
    set(handles.RTO1,'value',0);
    %Ensure Rise and Decay Guesses are available
    set(handlesarray,'enable','on')
else
    set(handlesarray(3:4),'enable','off')
    set(handles.t1Risevary,'value',0)
end  
guidata(hObject, handles);
%DataFit(1);


%Tells the Fitting Function that Rise Constant 2 is an Unknown, but there is also a decay.
function URT2_Callback(hObject, eventdata, handles)
global Decays
Decays(38)=get(hObject,'Value');
handlesarray=[handles.t2,handles.t2vary,handles.t2Rise,handles.t2Risevary];
if Decays(38)==1
    %Can't have sequential lifetime if URT
    Decays(10)=1;
    set(handles.t2start,'value',1);
    %Not a RTO
    Decays(45)=0;
    set(handles.RTO2,'value',0);
    %Ensure Rise and Decay Guesses are available
    set(handlesarray,'enable','on')
else
    set(handlesarray(3:4),'enable','off')
    set(handles.t2Risevary,'value',0)
end 
guidata(hObject, handles);
%DataFit(1);


%Tells the Fitting Function that Rise Constant 3 is an Unknown, but there is also a decay
function URT3_Callback(hObject, eventdata, handles)
global Decays
Decays(39)=get(hObject,'Value');
handlesarray=[handles.t3,handles.t3vary,handles.t3Rise,handles.t3Risevary];
if Decays(39)==1
    %Can't have sequential lifetime if URT
    Decays(11)=1;
    set(handles.t3start,'value',1);
    %Not a RTO
    Decays(46)=0;
    set(handles.RTO3,'value',0);
    %Ensure Rise and Decay Guesses are available
    set(handlesarray,'enable','on')
else
    set(handlesarray(3:4),'enable','off')
    set(handles.t3Risevary,'value',0)
end 
guidata(hObject, handles);
%DataFit(1);


%Tells the Fitting Function that Rise Constant 4 is an Unknown, but there is also a decay
function URT4_Callback(hObject, eventdata, handles)
global Decays
Decays(40)=get(hObject,'Value');
handlesarray=[handles.t4,handles.t4vary,handles.t4Rise,handles.t4Risevary];
if Decays(40)==1
    %Can't have sequential lifetime if URT
    Decays(12)=1;
    set(handles.t4start,'value',1);
    %Not a RTO
    Decays(47)=0;
    set(handles.RTO4,'value',0);
    %Ensure Rise and Decay Guesses are available
    set(handlesarray,'enable','on')
else
    set(handlesarray(3:4),'enable','off')
    set(handles.t4Risevary,'value',0)
end 
guidata(hObject, handles);
%DataFit(1);

%Tells the Fitting Function that Rise Constant 5 is an Unknown, but there is also a decay
function URT5_Callback(hObject, eventdata, handles)
global Decays
Decays(41)=get(hObject,'Value');
handlesarray=[handles.t5,handles.t5vary,handles.t5Rise,handles.t5Risevary];
if Decays(41)==1
    %Can't have sequential lifetime if URT
    Decays(13)=1;
    set(handles.t5start,'value',1);
    %Not a RTO
    Decays(48)=0;
    set(handles.RTO5,'value',0);
    %Ensure Rise and Decay Guesses are available
    set(handlesarray,'enable','on')
else
    set(handlesarray(3:4),'enable','off')
    set(handles.t5Risevary,'value',0)
end 
guidata(hObject, handles);
%DataFit(1);

%Tells the Fitting Function that Rise Constant 6 is an Unknown, but there is also a decay
function URT6_Callback(hObject, eventdata, handles)
global Decays
Decays(42)=get(hObject,'Value');
handlesarray=[handles.t6,handles.t6vary,handles.t6Rise,handles.t6Risevary];
if Decays(42)==1
    %Can't have sequential lifetime if URT
    Decays(14)=1;
    set(handles.t6start,'value',1);
    %Not a RTO
    Decays(49)=0;
    set(handles.RTO6,'value',0);
    %Ensure Rise and Decay Guesses are available
    set(handlesarray,'enable','on')
else
    set(handlesarray(3:4),'enable','off')
    set(handles.t6Risevary,'value',0)
end 
guidata(hObject, handles);
%DataFit(1);

%Tells the Fitting Function that Rise Constant 7 is an Unknown, but there is also a decay
function URT7_Callback(hObject, eventdata, handles)
global Decays
Decays(43)=get(hObject,'Value');
handlesarray=[handles.t7,handles.t7vary,handles.t7Rise,handles.t7Risevary];
if Decays(43)==1
    %Can't have sequential lifetime if URT
    Decays(15)=1;
    set(handles.t7start,'value',1);
    %Not a RTO
    Decays(50)=0;
    set(handles.RTO7,'value',0);
    %Ensure Rise and Decay Guesses are available
    set(handlesarray,'enable','on')
else
    set(handlesarray(3:4),'enable','off')
    set(handles.t7Risevary,'value',0)
end 
guidata(hObject, handles);
%DataFit(1);


%Tells the Fitting Function that decay constant 1 is infinite
function RTO1_Callback(hObject, eventdata, handles)
global Decays
Decays(44)=get(hObject,'Value');
%Can't have any decay sequential rise associated as infinite decay
if any(Decays(9:15)==2) && Decays(44)==1
    handlearray=[handles.t1start,handles.t2start,handles.t3start,handles.t4start,handles.t5start,handles.t6start,handles.t7start,handles.t1Rise,handles.t2Rise,handles.t3Rise,handles.t4Rise,handles.t5Rise,handles.t6Rise,handles.t7Rise];
    k=find(Decays(9:15)==2);
    Decays(k+8)=1;
    set(handlearray(k),'value',1);
    set(handlearray(k+7),'enable','on');
end
%Should have an unfixed Decay constant if only rise time in fit
if Decays(44)==1
    Decays(37)=0;   %URT1 off
    Decays(16)=0;   %T1 vary off
    set(handles.URT1,'value',0)
    set(handles.t1vary,'value',0)
    set(handles.t1vary,'enable','off')
    set(handles.t1,'enable','off')
    if Decays(9)==1 %if not risen by an SRT
        set(handles.t1Risevary,'enable','on')
        set(handles.t1Rise,'enable','on')
    end
else
    set(handles.t1vary,'enable','on')
    set(handles.t1,'enable','on')
    set(handles.t1Risevary,'enable','off')
    set(handles.t1Rise,'enable','off')
end
guidata(hObject, handles);
%DataFit(1);


%Tells the Fitting Function that decay constant 2 is infinite
function RTO2_Callback(hObject, eventdata, handles)
global Decays
Decays(45)=get(hObject,'Value');
%Can't have any decay sequential rise associated as infinite decay
if any(Decays(9:15)==3) && Decays(45)==1
    handlearray=[handles.t1start,handles.t2start,handles.t3start,handles.t4start,handles.t5start,handles.t6start,handles.t7start,handles.t1Rise,handles.t2Rise,handles.t3Rise,handles.t4Rise,handles.t5Rise,handles.t6Rise,handles.t7Rise];
    k=find(Decays(9:15)==3);
    Decays(k+8)=1;
    set(handlearray(k),'value',1);
    set(handlearray(k+7),'enable','on');
end
%Should have an unfixed Decay constant if only rise time in fit
if Decays(45)==1
    Decays(38)=0;   %URT2 off
    Decays(17)=0;   %T2 vary off
    set(handles.URT2,'value',0)
    set(handles.t2vary,'value',0)
    set(handles.t2vary,'enable','off')
    set(handles.t2,'enable','off')
    if Decays(10)==1 %if not risen by an SRT
        set(handles.t2Risevary,'enable','on')
        set(handles.t2Rise,'enable','on')
    end
else
    set(handles.t2vary,'enable','on')
    set(handles.t2,'enable','on')
    set(handles.t2Risevary,'enable','off')
    set(handles.t2Rise,'enable','off')
end
guidata(hObject, handles);
%DataFit(1);


%Tells the Fitting Function that decay constant 3 is infinite
function RTO3_Callback(hObject, eventdata, handles)
global Decays
Decays(46)=get(hObject,'Value');
%Can't have any decay sequential rise associated as infinite decay
if any(Decays(9:15)==4) && Decays(46)==1
    handlearray=[handles.t1start,handles.t2start,handles.t3start,handles.t4start,handles.t5start,handles.t6start,handles.t7start,handles.t1Rise,handles.t2Rise,handles.t3Rise,handles.t4Rise,handles.t5Rise,handles.t6Rise,handles.t7Rise];
    k=find(Decays(9:15)==4);
    Decays(k+8)=1;
    set(handlearray(k),'value',1);
    set(handlearray(k+7),'enable','on');
end
%Should have an unfixed Decay constant if only rise time in fit
if Decays(46)==1
    Decays(39)=0;   %URT3 off
    Decays(18)=0;   %T3 vary off
    set(handles.URT3,'value',0)
    set(handles.t3vary,'value',0)
    set(handles.t3vary,'enable','off')
    set(handles.t3,'enable','off')
    if Decays(11)==1 %if not risen by an SRT
        set(handles.t3Risevary,'enable','on')
        set(handles.t3Rise,'enable','on')
    end
else
    set(handles.t3vary,'enable','on')
    set(handles.t3,'enable','on')
    set(handles.t3Risevary,'enable','off')
    set(handles.t3Rise,'enable','off')
end
guidata(hObject, handles);
%DataFit(1);


%Tells the Fitting Function that decay constant 4 is infinite
function RTO4_Callback(hObject, eventdata, handles)
global Decays
Decays(47)=get(hObject,'Value');
%Can't have any decay sequential rise associated as infinite decay
if any(Decays(9:15)==5) && Decays(47)==1
    handlearray=[handles.t1start,handles.t2start,handles.t3start,handles.t4start,handles.t5start,handles.t6start,handles.t7start,handles.t1Rise,handles.t2Rise,handles.t3Rise,handles.t4Rise,handles.t5Rise,handles.t6Rise,handles.t7Rise];
    k=find(Decays(9:15)==5);
    Decays(k+8)=1;
    set(handlearray(k),'value',1);
    set(handlearray(k+7),'enable','on');
end
%Should have an unfixed Decay constant if only rise time in fit
if Decays(47)==1
    Decays(40)=0;   %URT4 off
    Decays(19)=0;   %T4 vary off
    set(handles.URT4,'value',0)
    set(handles.t4vary,'value',0)
    set(handles.t4vary,'enable','off')
    set(handles.t4,'enable','off')
    if Decays(12)==1 %if not risen by an SRT
        set(handles.t4Risevary,'enable','on')
        set(handles.t4Rise,'enable','on')
    end
else
    set(handles.t4vary,'enable','on')
    set(handles.t4,'enable','on')
    set(handles.t4Risevary,'enable','off')
    set(handles.t4Rise,'enable','off')
end
guidata(hObject, handles);
%DataFit(1);

%Tells the Fitting Function that decay constant 5 is infinite
function RTO5_Callback(hObject, eventdata, handles)
global Decays
Decays(48)=get(hObject,'Value');
%Can't have any decay sequential rise associated as infinite decay
if any(Decays(9:15)==6) && Decays(48)==1
    handlearray=[handles.t1start,handles.t2start,handles.t3start,handles.t4start,handles.t5start,handles.t6start,handles.t7start,handles.t1Rise,handles.t2Rise,handles.t3Rise,handles.t4Rise,handles.t5Rise,handles.t6Rise,handles.t7Rise];
    k=find(Decays(9:15)==6);
    Decays(k+8)=1;
    set(handlearray(k),'value',1);
    set(handlearray(k+7),'enable','on');
end
%Should have an unfixed Decay constant if only rise time in fit
if Decays(48)==1
    Decays(41)=0;   %URT5 off
    Decays(20)=0;   %T5 vary off
    set(handles.URT5,'value',0)
    set(handles.t5vary,'value',0)
    set(handles.t5vary,'enable','off')
    set(handles.t5,'enable','off')
    if Decays(13)==1 %if not risen by an SRT
        set(handles.t5Risevary,'enable','on')
        set(handles.t5Rise,'enable','on')
    end
else
    set(handles.t5vary,'enable','on')
    set(handles.t5,'enable','on')
    set(handles.t5Risevary,'enable','off')
    set(handles.t5Rise,'enable','off')
end
guidata(hObject, handles);
%DataFit(1);

%Tells the Fitting Function that decay constant 6 is infinite
function RTO6_Callback(hObject, eventdata, handles)
global Decays
Decays(49)=get(hObject,'Value');
%Can't have any decay sequential rise associated as infinite decay
if any(Decays(9:15)==7) && Decays(49)==1
    handlearray=[handles.t1start,handles.t2start,handles.t3start,handles.t4start,handles.t5start,handles.t6start,handles.t7start,handles.t1Rise,handles.t2Rise,handles.t3Rise,handles.t4Rise,handles.t5Rise,handles.t6Rise,handles.t7Rise];
    k=find(Decays(9:15)==7);
    Decays(k+8)=1;
    set(handlearray(k),'value',1);
    set(handlearray(k+7),'enable','on');
end
%Should have an unfixed Decay constant if only rise time in fit
if Decays(49)==1
    Decays(42)=0;   %URT6 off
    Decays(21)=0;   %T6 vary off
    set(handles.URT6,'value',0)
    set(handles.t6vary,'value',0)
    set(handles.t6vary,'enable','off')
    set(handles.t6,'enable','off')
    if Decays(14)==1 %if not risen by an SRT
        set(handles.t6Risevary,'enable','on')
        set(handles.t6Rise,'enable','on')
    end
else
    set(handles.t6vary,'enable','on')
    set(handles.t6,'enable','on')
    set(handles.t6Risevary,'enable','off')
    set(handles.t6Rise,'enable','off')
end
guidata(hObject, handles);
%DataFit(1);

%Tells the Fitting Function that decay constant 7 is infinite
function RTO7_Callback(hObject, eventdata, handles)
global Decays
Decays(50)=get(hObject,'Value');
%Can't have any decay sequential rise associated as infinite decay
if any(Decays(9:15)==8) && Decays(50)==1
    handlearray=[handles.t1start,handles.t2start,handles.t3start,handles.t4start,handles.t5start,handles.t6start,handles.t7start,handles.t1Rise,handles.t2Rise,handles.t3Rise,handles.t4Rise,handles.t5Rise,handles.t6Rise,handles.t7Rise];
    k=find(Decays(9:15)==8);
    Decays(k+8)=1;
    set(handlearray(k),'value',1);
end
%Should have an unfixed Decay constant if only rise time in fit
if Decays(50)==1
    Decays(43)=0;   %URT7 off
    Decays(22)=0;   %T7 vary off
    set(handles.URT7,'value',0)
    set(handles.t7vary,'value',0)
    set(handles.t7vary,'enable','off')
    set(handles.t7,'enable','off')
    if Decays(15)==1 %if not risen by an SRT
        set(handles.t7Risevary,'enable','on')
        set(handles.t7Rise,'enable','on')
    end
else
    set(handles.t7vary,'enable','on')
    set(handles.t7,'enable','on')
    set(handles.t7Risevary,'enable','off')
    set(handles.t7Rise,'enable','off')
end
guidata(hObject, handles);
%DataFit(1);



%Tells the Fitting Function if Time Constant 1 should be Reverse Fit
function t1back_Callback(hObject, eventdata, handles)
global Decays
Decays(23)=get(hObject,'Value');
%Unselect any relelvent sequential rise times as direction switched so not physical
if Decays(9)~=1; %First check own row
    Decays(9)=1;
    set(handles.t1start,'value',1)
    if Decays(44)==1    %If RTO, enable rise guess and fix options
        set(handles.t1Rise,'enable','on')
        set(handles.t1Risevary,'enable','on')
    end
end
if any(find(Decays(9:15))==2)==1 %Resets any channel which was previously fed in by channel 1 to have a standard rise time
    handlesarray=[handles.t1start,handles.t2start,handles.t3start,handles.t4start,handles.t5start,handles.t6start,handles.t7start,handles.t1Rise,handles.t2Rise,handles.t3Rise,handles.t4Rise,handles.t5Rise,handles.t6Rise,handles.t7Rise,handles.t1Risevary,handles.t2Risevary,handles.t3Risevary,handles.t4Risevary,handles.t5Risevary,handles.t6Risevary,handles.t7Risevary];
    k=find((Decays(9:15)==2));
    set(handlesarray(k),'value',1);
    Decays((8+k))=1;
    if Decays(43+k)==1  %If RTO, enable rise guess and fix options
        set(handlesarray(k+7),'enable','on')
        set(handlesarray(k+14),'enable','on')
    end 
end
guidata(hObject, handles);
%DataFit(1);

%Tells the Fitting Function if Time Constant 2 should be Reverse Fit
function t2back_Callback(hObject, eventdata, handles)
global Decays
Decays(24)=get(hObject,'Value');
%Unselect any relelvent sequential rise times as direction switched so not physical
if Decays(10)~=1; %First check own row
    Decays(10)=1;
    set(handles.t2start,'value',1)
    if Decays(45)==1    %If RTO, enable rise guess and fix options
        set(handles.t2Rise,'enable','on')
        set(handles.t2Risevary,'enable','on')
    end
end
if any(find(Decays(9:15))==3)==1 %Resets any channel which was previously fed in by channel 1 to have a standard rise time
    handlesarray=[handles.t1start,handles.t2start,handles.t3start,handles.t4start,handles.t5start,handles.t6start,handles.t7start,handles.t1Rise,handles.t2Rise,handles.t3Rise,handles.t4Rise,handles.t5Rise,handles.t6Rise,handles.t7Rise,handles.t1Risevary,handles.t2Risevary,handles.t3Risevary,handles.t4Risevary,handles.t5Risevary,handles.t6Risevary,handles.t7Risevary];
    k=find((Decays(9:15)==3));
    set(handlesarray(k),'value',1);
    Decays((8+k))=1;
    if Decays(43+k)==1  %If RTO, enable rise guess and fix options
        set(handlesarray(k+7),'enable','on')
        set(handlesarray(k+14),'enable','on')
    end 
end
guidata(hObject, handles);
%DataFit(1);

%Tells the Fitting Function if Time Constant 3 should be Reverse Fit
function t3back_Callback(hObject, eventdata, handles)
global Decays
Decays(25)=get(hObject,'Value');
%Unselect any relelvent sequential rise times as direction switched so not physical
if Decays(11)~=1; %First check own row
    Decays(11)=1;
    set(handles.t3start,'value',1)
    if Decays(46)==1    %If RTO, enable rise guess and fix options
        set(handles.t3Rise,'enable','on')
        set(handles.t3Risevary,'enable','on')
    end
end
if any(find(Decays(9:15))==4)==1 %Resets any channel which was previously fed in by channel 1 to have a standard rise time
    handlesarray=[handles.t1start,handles.t2start,handles.t3start,handles.t4start,handles.t5start,handles.t6start,handles.t7start,handles.t1Rise,handles.t2Rise,handles.t3Rise,handles.t4Rise,handles.t5Rise,handles.t6Rise,handles.t7Rise,handles.t1Risevary,handles.t2Risevary,handles.t3Risevary,handles.t4Risevary,handles.t5Risevary,handles.t6Risevary,handles.t7Risevary];
    k=find((Decays(9:15)==4));
    set(handlesarray(k),'value',1);
    Decays((8+k))=1;
    if Decays(43+k)==1  %If RTO, enable rise guess and fix options
        set(handlesarray(k+7),'enable','on')
        set(handlesarray(k+14),'enable','on')
    end 
end
guidata(hObject, handles);
%DataFit(1);

%Tells the Fitting Function if Time Constant 4 should be Reverse Fit
function t4back_Callback(hObject, eventdata, handles)
global Decays
Decays(26)=get(hObject,'Value');
%Unselect any relelvent sequential rise times as direction switched so not physical
if Decays(12)~=1; %First check own row
    Decays(12)=1;
    set(handles.t4start,'value',1)
    if Decays(47)==1    %If RTO, enable rise guess and fix options
        set(handles.t4Rise,'enable','on')
        set(handles.t4Risevary,'enable','on')
    end
end
if any(find(Decays(9:15))==5)==1 %Resets any channel which was previously fed in by channel 1 to have a standard rise time
    handlesarray=[handles.t1start,handles.t2start,handles.t3start,handles.t4start,handles.t5start,handles.t6start,handles.t7start,handles.t1Rise,handles.t2Rise,handles.t3Rise,handles.t4Rise,handles.t5Rise,handles.t6Rise,handles.t7Rise,handles.t1Risevary,handles.t2Risevary,handles.t3Risevary,handles.t4Risevary,handles.t5Risevary,handles.t6Risevary,handles.t7Risevary];
    k=find((Decays(9:15)==5));
    set(handlesarray(k),'value',1);
    Decays((8+k))=1;
    if Decays(43+k)==1  %If RTO, enable rise guess and fix options
        set(handlesarray(k+7),'enable','on')
        set(handlesarray(k+14),'enable','on')
    end 
end
guidata(hObject, handles);
%DataFit(1);

%Tells the Fitting Function if Time Constant 5 should be Reverse Fit
function t5back_Callback(hObject, eventdata, handles)
global Decays
Decays(27)=get(hObject,'Value');
%Unselect any relelvent sequential rise times as direction switched so not physical
if Decays(13)~=1; %First check own row
    Decays(13)=1;
    set(handles.t5start,'value',1)
    if Decays(48)==1    %If RTO, enable rise guess and fix options
        set(handles.t5Rise,'enable','on')
        set(handles.t5Risevary,'enable','on')
    end
end
if any(find(Decays(9:15))==6)==1 %Resets any channel which was previously fed in by channel 1 to have a standard rise time
    handlesarray=[handles.t1start,handles.t2start,handles.t3start,handles.t4start,handles.t5start,handles.t6start,handles.t7start,handles.t1Rise,handles.t2Rise,handles.t3Rise,handles.t4Rise,handles.t5Rise,handles.t6Rise,handles.t7Rise,handles.t1Risevary,handles.t2Risevary,handles.t3Risevary,handles.t4Risevary,handles.t5Risevary,handles.t6Risevary,handles.t7Risevary];
    k=find((Decays(9:15)==6));
    set(handlesarray(k),'value',1);
    Decays((8+k))=1;
    if Decays(43+k)==1  %If RTO, enable rise guess and fix options
        set(handlesarray(k+7),'enable','on')
        set(handlesarray(k+14),'enable','on')
    end 
end
guidata(hObject, handles);
%DataFit(1);

%Tells the Fitting Function if Time Constant 6 should be Reverse Fit
function t6back_Callback(hObject, eventdata, handles)
global Decays
Decays(28)=get(hObject,'Value');
%Unselect any relelvent sequential rise times as direction switched so not physical
if Decays(14)~=1; %First check own row
    Decays(14)=1;
    set(handles.t6start,'value',1)
    if Decays(49)==1    %If RTO, enable rise guess and fix options
        set(handles.t6Rise,'enable','on')
        set(handles.t6Risevary,'enable','on')
    end
end
if any(find(Decays(9:15))==7)==1 %Resets any channel which was previously fed in by channel 1 to have a standard rise time
    handlesarray=[handles.t1start,handles.t2start,handles.t3start,handles.t4start,handles.t5start,handles.t6start,handles.t7start,handles.t1Rise,handles.t2Rise,handles.t3Rise,handles.t4Rise,handles.t5Rise,handles.t6Rise,handles.t7Rise,handles.t1Risevary,handles.t2Risevary,handles.t3Risevary,handles.t4Risevary,handles.t5Risevary,handles.t6Risevary,handles.t7Risevary];
    k=find((Decays(9:15)==7));
    set(handlesarray(k),'value',1);
    Decays((8+k))=1;
    if Decays(43+k)==1  %If RTO, enable rise guess and fix options
        set(handlesarray(k+7),'enable','on')
        set(handlesarray(k+14),'enable','on')
    end 
end
guidata(hObject, handles);
%DataFit(1);

%Tells the Fitting Function if Time Constant 7 should be Reverse Fit
function t7back_Callback(hObject, eventdata, handles)
global Decays
Decays(29)=get(hObject,'Value');
%Unselect any relelvent sequential rise times as direction switched so not physical
if Decays(15)~=1; %First check own row
    Decays(15)=1;
    set(handles.t7start,'value',1)
    if Decays(50)==1    %If RTO, enable rise guess and fix options
        set(handles.t7Rise,'enable','on')
        set(handles.t7Risevary,'enable','on')
    end
end
if any(find(Decays(9:15))==8)==1 %Resets any channel which was previously fed in by channel 1 to have a standard rise time
    handlesarray=[handles.t1start,handles.t2start,handles.t3start,handles.t4start,handles.t5start,handles.t6start,handles.t7start,handles.t1Rise,handles.t2Rise,handles.t3Rise,handles.t4Rise,handles.t5Rise,handles.t6Rise,handles.t7Rise,handles.t1Risevary,handles.t2Risevary,handles.t3Risevary,handles.t4Risevary,handles.t5Risevary,handles.t6Risevary,handles.t7Risevary];
    k=find((Decays(9:15)==8));
    set(handlesarray(k),'value',1);
    Decays((8+k))=1;
    if Decays(43+k)==1  %If RTO, enable rise guess and fix options
        set(handlesarray(k+7),'enable','on')
        set(handlesarray(k+14),'enable','on')
    end 
end
guidata(hObject, handles);
%DataFit(1);


%Input for T1 Time Constant
function t1_Callback(hObject, eventdata, handles)
%Check if there are any errors with the user input
if ErrorCheck(str2double(get(hObject,'String')),0,0,0,1,1,0,0,0,0) == 1;  %Checks if the number is valid
   set(hObject, 'String', handles.TimeCons(1,1)); %If it fails, reset editbox 
else
    handles.TimeCons(1,1)=str2num(get(hObject,'String')); %Otherwise update constants
end
guidata(hObject, handles);

function t1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%Input for T2 Time Constant
function t2_Callback(hObject, eventdata, handles)
%Check if there are any errors with the user input
if ErrorCheck(str2double(get(hObject,'String')),0,0,0,1,1,0,0,0,0) == 1;  %Checks if the number is valid
   set(hObject, 'String', handles.TimeCons(2,1)); %If it fails, reset editbox 
else
    handles.TimeCons(2,1)=str2num(get(hObject,'String')); %Otherwise update constants
end
guidata(hObject, handles);

function t2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%Input for T3 Time Constant
function t3_Callback(hObject, eventdata, handles)
%Check if there are any errors with the user input
if ErrorCheck(str2double(get(hObject,'String')),0,0,0,1,1,0,0,0,0) == 1;  %Checks if the number is valid
   set(hObject, 'String', handles.TimeCons(3,1)); %If it fails, reset editbox 
else
    handles.TimeCons(3,1)=str2num(get(hObject,'String')); %Otherwise update constants
end
guidata(hObject, handles);

function t3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%Input for T4 Time Constant
function t4_Callback(hObject, eventdata, handles)
%Check if there are any errors with the user input
if ErrorCheck(str2double(get(hObject,'String')),0,0,0,1,1,0,0,0,0) == 1;  %Checks if the number is valid
   set(hObject, 'String', handles.TimeCons(4,1)); %If it fails, reset editbox 
else
    handles.TimeCons(4,1)=str2num(get(hObject,'String')); %Otherwise update constants
end
guidata(hObject, handles);

function t4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%Input for T5 Time Constant
function t5_Callback(hObject, eventdata, handles)
%Check if there are any errors with the user input
if ErrorCheck(str2double(get(hObject,'String')),0,0,0,1,1,0,0,0,0) == 1;  %Checks if the number is valid
   set(hObject, 'String', handles.TimeCons(5,1)); %If it fails, reset editbox 
else
    handles.TimeCons(5,1)=str2num(get(hObject,'String')); %Otherwise update constants
end
guidata(hObject, handles);

function t5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%Input for T6 Time Constant
function t6_Callback(hObject, eventdata, handles)
%Check if there are any errors with the user input
if ErrorCheck(str2double(get(hObject,'String')),0,0,0,1,1,0,0,0,0) == 1;  %Checks if the number is valid
   set(hObject, 'String', handles.TimeCons(6,1)); %If it fails, reset editbox 
else
    handles.TimeCons(6,1)=str2num(get(hObject,'String')); %Otherwise update constants
end
guidata(hObject, handles);

function t6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%Input for T7 Time Constant
function t7_Callback(hObject, eventdata, handles)
%Check if there are any errors with the user input
if ErrorCheck(str2double(get(hObject,'String')),0,0,0,1,1,0,0,0,0) == 1;  %Checks if the number is valid
   set(hObject, 'String', handles.TimeCons(7,1)); %If it fails, reset editbox 
else
    handles.TimeCons(7,1)=str2num(get(hObject,'String')); %Otherwise update constants
end
guidata(hObject, handles);

function t7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%Input for T1 Rise Constant
function t1Rise_Callback(hObject, eventdata, handles)
%Check if there are any errors with the user input
if ErrorCheck(str2double(get(hObject,'String')),0,0,0,1,1,0,0,0,0) == 1;  %Checks if the number is valid
   set(hObject, 'String', handles.TimeCons(1,2)); %If it fails, reset editbox 
else
    handles.TimeCons(1,2)=str2num(get(hObject,'String')); %Otherwise update constants
end
guidata(hObject, handles);

function t1Rise_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%Input for T2 Rise Constant
function t2Rise_Callback(hObject, eventdata, handles)
if ErrorCheck(str2double(get(hObject,'String')),0,0,0,1,1,0,0,0,0) == 1;  %Checks if the number is valid
   set(hObject, 'String', handles.TimeCons(2,2)); %If it fails, reset editbox 
else
    handles.TimeCons(2,2)=str2num(get(hObject,'String')); %Otherwise update constants
end
guidata(hObject, handles);

function t2Rise_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%Input for T3 Rise Constant
function t3Rise_Callback(hObject, eventdata, handles)
if ErrorCheck(str2double(get(hObject,'String')),0,0,0,1,1,0,0,0,0) == 1;  %Checks if the number is valid
   set(hObject, 'String', handles.TimeCons(3,2)); %If it fails, reset editbox 
else
    handles.TimeCons(3,2)=str2num(get(hObject,'String')); %Otherwise update constants
end
guidata(hObject, handles)

function t3Rise_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%Input for T4 Rise Constant
function t4Rise_Callback(hObject, eventdata, handles)
if ErrorCheck(str2double(get(hObject,'String')),0,0,0,1,1,0,0,0,0) == 1;  %Checks if the number is valid
   set(hObject, 'String', handles.TimeCons(4,2)); %If it fails, reset editbox 
else
    handles.TimeCons(4,2)=str2num(get(hObject,'String')); %Otherwise update constants
end
guidata(hObject, handles)

function t4Rise_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%Input for T5 Rise Constant
function t5Rise_Callback(hObject, eventdata, handles)
if ErrorCheck(str2double(get(hObject,'String')),0,0,0,1,1,0,0,0,0) == 1;  %Checks if the number is valid
   set(hObject, 'String', handles.TimeCons(5,2)); %If it fails, reset editbox 
else
    handles.TimeCons(5,2)=str2num(get(hObject,'String')); %Otherwise update constants
end
guidata(hObject, handles)

function t5Rise_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%Input for T6 Rise Constant
function t6Rise_Callback(hObject, eventdata, handles)
if ErrorCheck(str2double(get(hObject,'String')),0,0,0,1,1,0,0,0,0) == 1;  %Checks if the number is valid
   set(hObject, 'String', handles.TimeCons(6,2)); %If it fails, reset editbox 
else
    handles.TimeCons(6,2)=str2num(get(hObject,'String')); %Otherwise update constants
end
guidata(hObject, handles)

function t6Rise_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%Input for T7 Rise Constant
function t7Rise_Callback(hObject, eventdata, handles)
if ErrorCheck(str2double(get(hObject,'String')),0,0,0,1,1,0,0,0,0) == 1;  %Checks if the number is valid
   set(hObject, 'String', handles.TimeCons(7,2)); %If it fails, reset editbox 
else
    handles.TimeCons(7,2)=str2num(get(hObject,'String')); %Otherwise update constants
end
guidata(hObject, handles)

function t7Rise_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%Allows for alteration of the timezero position in the fitting process
function Yoffset_Callback(hObject, eventdata, handles)
if ErrorCheck(str2double(get(hObject,'String')),0,0,0,1,0,0,0,0,0) == 1;  %Checks if the number is valid
   set(hObject, 'String', 0); %If it fails, reset editbox 
else
    handles.Yoffsetvalue=str2num(get(hObject,'String'));
    [handles.LinearYTickLabels,handles.LinLogYTickLabels,handles.LinLogScale] = YAxisLabels(handles.Timestep+handles.Yoffsetvalue,str2double(get(handles.LinLogMultiplier,'String')));  %Re-update y-axis tick marks accounting for offset
    guidata(hObject, handles);
    [handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2); %Plot data again
    %Set-Up Cursors Again
    if handles.DataAlreadyCalibrated==0;
        SliderUpdateReset(handles.TData(handles.XMinimumValueI),handles.TData(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    else
        if get(handles.GlobalFitButton,'value') == 1;
            GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
        else
            SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
        end    
    end
    guidata(hObject, handles);
    %DataFit(1)  %Fit Data
end
guidata(hObject, handles);

function Yoffset_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%A user input manual offset in the fit data
function ManualOffsetFit_Callback(hObject, eventdata, handles)
global UserFitOffset
%Check if there are any errors with the user input
if ErrorCheck(str2double(get(hObject,'String')),0,0,0,1,0,0,0,0,0) == 1;  %Checks if the number is valid
   set(hObject, 'String', UserFitOffset); %If it fails, reset editbox 
else
    UserFitOffset=str2num(get(hObject,'String')); %Otherwise update constants
end
guidata(hObject, handles);

function ManualOffsetFit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%UI panel for selecting Single Region or Global Fitting
function uipanel16_SelectionChangeFcn(hObject, eventdata, handles)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'SingleRegionButton'
        set(handles.uipanel17,'visible','off');   %Hide Global Fitting Settings Panel
        guidata(hObject, handles);
        [handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2); %Plot data again
        SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot)
        %Reset axis 4 for fit as crashes when switching
%         axes(handles.axes4), h = plot(0,0); xlim([0 100])
%         set(h,'Tag','RSquarePlot');  set(gca,'YTickLabel',[])
    case 'GlobalFitButton'
        set(handles.uipanel17,'visible','on');    %Show Global Fitting Settings Panel
        handles.NoRegions=(find(handles.NoRegionsSelection~=0))+1; %Finds the number of regions currently selected
        SelectionCheck=get(get(handles.uipanel23,'SelectedObject'),'Tag'); %Used to check if background division on
        if strcmp(SelectionCheck,'PumpDiv')==1 || strcmp(SelectionCheck,'ProbeDiv')==1 || strcmp(SelectionCheck,'PaPDiv')==1
           for i=1:handles.NoRegions
               set(handles.(['DivPeak' num2str(i)]),'enable','on')
           end
        end
        handles.CurrentSliders=find(handles.SelectedRegion~=0); %Finds out which slider region the user has selected to operate
        handles.MaxAndMinRegions=[str2num(get(handles.Slider1Min,'string')),str2num(get(handles.Slider1Max,'string'));str2num(get(handles.Slider2Min,'string')),str2num(get(handles.Slider2Max,'string'));str2num(get(handles.Slider3Min,'string')),str2num(get(handles.Slider3Max,'string'));str2num(get(handles.Slider4Min,'string')),str2num(get(handles.Slider4Max,'string'));str2num(get(handles.Slider5Min,'string')),str2num(get(handles.Slider5Max,'string'))]; %Gets the Maximum and Minimum Values set for the sliders
        guidata(hObject, handles);
        [handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2); %Plot data again
        GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot)
%         %Reset axis 4 for fit as crashes when switching
%         axes(handles.axes4), h = plot(0,0); xlim([0 100])
%         set(h,'Tag','RSquarePlot');  set(gca,'YTickLabel',[])
end




%UI panel for selecting the number of regions to fit when global fitting
function uipanel21_SelectionChangeFcn(hObject, eventdata, handles)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'NoRegions2Button'
        set([handles.Region3Button,handles.Region4Button,handles.Region5Button,handles.DoNotFitRegion3,handles.DoNotFitRegion4,handles.DoNotFitRegion5,handles.DivPeak3,handles.DivPeak4,handles.DivPeak5],'enable','off');   %Disable regions 3-5 when only fitting 2 regions
        handles.NoRegionsSelection=[1,0,0,0];       %States values from this submenu
        handles.NoRegions=2;                        %States number of regions chosen
        guidata(hObject, handles);
        [handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2);
        GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot)
        guidata(hObject, handles);
        SelectionCheck=get(get(handles.uipanel22,'SelectedObject'),'Tag'); %Used to check if a region is currently selected outwith the alowed regions (e.g. region 5 when only 4 regions)
        if strcmp(SelectionCheck,'Region5Button')==1 || strcmp(SelectionCheck,'Region4Button')==1 || strcmp(SelectionCheck,'Region3Button')==1
            set(handles.Region2Button,'Value',1)
            guidata(hObject, handles);
            uipanel22_SelectionChangeFcn(hObject, eventdata, handles)
        end  
    case 'NoRegions3Button'
        set([handles.Region4Button,handles.Region5Button,handles.DoNotFitRegion4,handles.DoNotFitRegion5,handles.DivPeak4,handles.DivPeak5],'enable','off'); %Disable regions 4-5 when only fitting 3 regions
        set([handles.Region3Button,handles.DoNotFitRegion3],'enable','on');                         %Ensure region 3 is enabled when fitting 3 regions
        SelectionCheck=get(get(handles.uipanel23,'SelectedObject'),'Tag'); %Used to check if background division on
        if strcmp(SelectionCheck,'PumpDiv')==1 || strcmp(SelectionCheck,'ProbeDiv')==1 || strcmp(SelectionCheck,'PaPDiv')==1
           set(handles.DivPeak3,'enable','on')
        end
        handles.NoRegionsSelection=[0,1,0,0];       %States values from this submenu
        handles.NoRegions=3;                        %States number of regions chosen
        guidata(hObject, handles);
        [handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2);
        GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot)
        guidata(hObject, handles);
        SelectionCheck=get(get(handles.uipanel22,'SelectedObject'),'Tag'); %Used to check if a region is currently selected outwith the alowed regions (e.g. region 5 when only 4 regions)
        if strcmp(SelectionCheck,'Region5Button')==1 || strcmp(SelectionCheck,'Region4Button')==1
            set(handles.Region3Button,'Value',1)
            guidata(hObject, handles);
            uipanel22_SelectionChangeFcn(hObject, eventdata, handles)
        end  
    case 'NoRegions4Button'
        set([handles.Region5Button,handles.DoNotFitRegion5,handles.DivPeak5],'enable','off');                         %Disable region 5 when only fitting 4 regions
        set([handles.Region3Button,handles.Region4Button,handles.DoNotFitRegion3,handles.DoNotFitRegion4],'enable','on'); %Ensure regions 3-4 are enabled when fitting 4 regions
        SelectionCheck=get(get(handles.uipanel23,'SelectedObject'),'Tag'); %Used to check if background division on
        if strcmp(SelectionCheck,'PumpDiv')==1 || strcmp(SelectionCheck,'ProbeDiv')==1 || strcmp(SelectionCheck,'PaPDiv')==1
           set([handles.DivPeak3,handles.DivPeak4],'enable','on')
        end
        handles.NoRegionsSelection=[0,0,1,0];       %States values from this submenu
        handles.NoRegions=4;                        %States number of regions chosen
        guidata(hObject, handles);
        [handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2);
        GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot)
        guidata(hObject, handles);
        SelectionCheck=get(get(handles.uipanel22,'SelectedObject'),'Tag'); %Used to check if a region is currently selected outwith the alowed regions (e.g. region 5 when only 4 regions)
        if strcmp(SelectionCheck,'Region5Button')==1
            set(handles.Region4Button,'Value',1)
            guidata(hObject, handles);
            uipanel22_SelectionChangeFcn(hObject, eventdata, handles)
        end           
    case 'NoRegions5Button'
        set([handles.Region3Button,handles.Region4Button,handles.Region5Button,handles.DoNotFitRegion3,handles.DoNotFitRegion4,handles.DoNotFitRegion5],'enable','on'); %Ensure all regions enabled when fitting 5 regions
        SelectionCheck=get(get(handles.uipanel23,'SelectedObject'),'Tag'); %Used to check if background division on
        if strcmp(SelectionCheck,'PumpDiv')==1 || strcmp(SelectionCheck,'ProbeDiv')==1 || strcmp(SelectionCheck,'PaPDiv')==1
           set([handles.DivPeak3,handles.DivPeak4,handles.DivPeak5],'enable','on')
        end
        handles.NoRegionsSelection=[0,0,0,1];       %States values from this submenu
        handles.NoRegions=5;                        %States number of regions chosen
        guidata(hObject, handles);
        [handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2);
        GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot)
        guidata(hObject, handles);
end



% --- Executes when selected object is changed in uipanel22.
function uipanel22_SelectionChangeFcn(hObject, eventdata, handles)
global DivisionVector
switch get(get(handles.uipanel22,'SelectedObject'),'Tag') % Get Tag of selected object.
    case 'Region1Button'
        handles.SelectedRegion=[1,0,0,0,0];         %States values from this submenu
        handles.CurrentSliders=1;                   %States number of region chosen
        guidata(hObject, handles);
        [handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2);
        GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot)
        %Correctly update side plot
        if get(handles.LinLogYAxis,'value') == 0;   %Fing out y data 
            sydata=(handles.Timestep(handles.YMinimumValueI:handles.YMaximumValueI)+handles.Yoffsetvalue);
        else
            %sydata=handles.YMinimumValueI:1:handles.YMaximumValueI;
            sydata=handles.LinLogScale(handles.YMinimumValueI:handles.YMaximumValueI);
        end
        %Finds slider regions for side plot data
        XDataMinSlider=min(get(handles.LeftSlider,'value'));
        XDataMaxSlider=max(get(handles.RightSlider,'value'));
        [~,DataLimitLeftIndex]=min(abs(handles.MainXData-XDataMinSlider));
        [~,DataLimitRightIndex]=min(abs(handles.MainXData-XDataMaxSlider));
        %SidePlot Update
        SidePlotGraph(handles.MainZData,sydata,get(handles.LinLogYAxis,'value'),DataLimitLeftIndex,DataLimitRightIndex,DivisionVector)
        guidata(hObject, handles);
    case 'Region2Button'
        handles.SelectedRegion=[0,1,0,0,0];         %States values from this submenu
        handles.CurrentSliders=2;                   %States number of region chosen
        guidata(hObject, handles);
        [handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2);
        GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot)
        %Correctly update side plot
        if get(handles.LinLogYAxis,'value') == 0;   %Fing out y data 
            sydata=(handles.Timestep(handles.YMinimumValueI:handles.YMaximumValueI)+handles.Yoffsetvalue);
        else
            %sydata=handles.YMinimumValueI:1:handles.YMaximumValueI;
            sydata=handles.LinLogScale(handles.YMinimumValueI:handles.YMaximumValueI);
        end
        %Finds slider regions for side plot data
        XDataMinSlider=min(get(handles.LeftSlider,'value'));
        XDataMaxSlider=max(get(handles.RightSlider,'value'));
        [~,DataLimitLeftIndex]=min(abs(handles.MainXData-XDataMinSlider));
        [~,DataLimitRightIndex]=min(abs(handles.MainXData-XDataMaxSlider));
        %SidePlot Update
        SidePlotGraph(handles.MainZData,sydata,get(handles.LinLogYAxis,'value'),DataLimitLeftIndex,DataLimitRightIndex,DivisionVector)
        guidata(hObject, handles);
    case 'Region3Button'
        handles.SelectedRegion=[0,0,1,0,0];         %States values from this submenu
        handles.CurrentSliders=3;                   %States number of region chosen
        guidata(hObject, handles);
        [handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2);
        GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot)
        %Correctly update side plot
        if get(handles.LinLogYAxis,'value') == 0;   %Fing out y data 
            sydata=(handles.Timestep(handles.YMinimumValueI:handles.YMaximumValueI)+handles.Yoffsetvalue);
        else
            %sydata=handles.YMinimumValueI:1:handles.YMaximumValueI;
            sydata=handles.LinLogScale(handles.YMinimumValueI:handles.YMaximumValueI);
        end
        %Finds slider regions for side plot data
        XDataMinSlider=min(get(handles.LeftSlider,'value'));
        XDataMaxSlider=max(get(handles.RightSlider,'value'));
        [~,DataLimitLeftIndex]=min(abs(handles.MainXData-XDataMinSlider));
        [~,DataLimitRightIndex]=min(abs(handles.MainXData-XDataMaxSlider));
        %SidePlot Update
        SidePlotGraph(handles.MainZData,sydata,get(handles.LinLogYAxis,'value'),DataLimitLeftIndex,DataLimitRightIndex,DivisionVector)
        guidata(hObject, handles);
    case 'Region4Button'
        handles.SelectedRegion=[0,0,0,1,0];         %States values from this submenu
        handles.CurrentSliders=4;                   %States number of region chosen
        guidata(hObject, handles);
        [handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2);
        GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot)
        %Correctly update side plot
        if get(handles.LinLogYAxis,'value') == 0;   %Fing out y data 
            sydata=(handles.Timestep(handles.YMinimumValueI:handles.YMaximumValueI)+handles.Yoffsetvalue);
        else
            %sydata=handles.YMinimumValueI:1:handles.YMaximumValueI;
            sydata=handles.LinLogScale(handles.YMinimumValueI:handles.YMaximumValueI);
        end
        %Finds slider regions for side plot data
        XDataMinSlider=min(get(handles.LeftSlider,'value'));
        XDataMaxSlider=max(get(handles.RightSlider,'value'));
        [~,DataLimitLeftIndex]=min(abs(handles.MainXData-XDataMinSlider));
        [~,DataLimitRightIndex]=min(abs(handles.MainXData-XDataMaxSlider));
        %SidePlot Update
        SidePlotGraph(handles.MainZData,sydata,get(handles.LinLogYAxis,'value'),DataLimitLeftIndex,DataLimitRightIndex,DivisionVector)
        guidata(hObject, handles);
    case 'Region5Button'
        handles.SelectedRegion=[0,0,0,0,1];         %States values from this submenu
        handles.CurrentSliders=5;                   %States number of region chosen
        guidata(hObject, handles);
        [handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2);
        GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot)
        %Correctly update side plot
        if get(handles.LinLogYAxis,'value') == 0;   %Fing out y data 
            sydata=(handles.Timestep(handles.YMinimumValueI:handles.YMaximumValueI)+handles.Yoffsetvalue);
        else
            %sydata=handles.YMinimumValueI:1:handles.YMaximumValueI;
            sydata=handles.LinLogScale(handles.YMinimumValueI:handles.YMaximumValueI);
        end
        %Finds slider regions for side plot data
        XDataMinSlider=min(get(handles.LeftSlider,'value'));
        XDataMaxSlider=max(get(handles.RightSlider,'value'));
        [~,DataLimitLeftIndex]=min(abs(handles.MainXData-XDataMinSlider));
        [~,DataLimitRightIndex]=min(abs(handles.MainXData-XDataMaxSlider));
        %SidePlot Update
        SidePlotGraph(handles.MainZData,sydata,get(handles.LinLogYAxis,'value'),DataLimitLeftIndex,DataLimitRightIndex,DivisionVector)
        guidata(hObject, handles);
end


%Used to tell fitting function to not include region 1 in global fit
function DoNotFitRegion1_Callback(hObject, eventdata, handles)
handles.DoNotFit(1)=get(handles.DoNotFitRegion1,'value');
guidata(hObject, handles);


%Used to tell fitting function to not include region 2 in global fit
function DoNotFitRegion2_Callback(hObject, eventdata, handles)
handles.DoNotFit(2)=get(handles.DoNotFitRegion2,'value');
guidata(hObject, handles);


%Used to tell fitting function to not include region 3 in global fit
function DoNotFitRegion3_Callback(hObject, eventdata, handles)
handles.DoNotFit(3)=get(handles.DoNotFitRegion3,'value');
guidata(hObject, handles);


%Used to tell fitting function to not include region 4 in global fit
function DoNotFitRegion4_Callback(hObject, eventdata, handles)
handles.DoNotFit(4)=get(handles.DoNotFitRegion4,'value');
guidata(hObject, handles);


%Used to tell fitting function to not include region 5 in global fit
function DoNotFitRegion5_Callback(hObject, eventdata, handles)
handles.DoNotFit(5)=get(handles.DoNotFitRegion5,'value');
guidata(hObject, handles);



%Used in the case of dividing the peak as a subtraction method, saying to use peak 1
function DivPeak1_Callback(hObject, eventdata, handles)
handles.GlobalDivPeak(1)=get(hObject,'Value');
if handles.GlobalDivPeak==[0,0,0,0,0]
    set(handles.DivPeak1,'value',1)
    handles.GlobalDivPeak(1)=1;
    errordlg('Must have atleast one division peak if division subtraction on','Error');    %display an error message
    return
end    
guidata(hObject, handles);
[handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2); %Update Plot
%Set-Up Cursors Again
if handles.DataAlreadyCalibrated==0;
    SliderUpdateReset(handles.TData(handles.XMinimumValueI),handles.TData(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
else
    if get(handles.GlobalFitButton,'value') == 1;
        GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    else
        SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    end    
end
guidata(hObject, handles);


%Used in the case of dividing the peak as a subtraction method, saying to use peak 2
function DivPeak2_Callback(hObject, eventdata, handles)
handles.GlobalDivPeak(2)=get(hObject,'Value');
if handles.GlobalDivPeak==[0,0,0,0,0]
    set(handles.DivPeak2,'value',1)
    handles.GlobalDivPeak(2)=1;
    errordlg('Must have atleast one division peak if division subtraction on','Error');    %display an error message
    return
end 
guidata(hObject, handles);
[handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2); %Update Plot
%Set-Up Cursors Again
if handles.DataAlreadyCalibrated==0;
    SliderUpdateReset(handles.TData(handles.XMinimumValueI),handles.TData(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
else
    if get(handles.GlobalFitButton,'value') == 1;
        GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    else
        SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    end    
end
guidata(hObject, handles);


%Used in the case of dividing the peak as a subtraction method, saying to use peak 3
function DivPeak3_Callback(hObject, eventdata, handles)
handles.GlobalDivPeak(3)=get(hObject,'Value');
if handles.GlobalDivPeak==[0,0,0,0,0]
    set(handles.DivPeak3,'value',1)
    handles.GlobalDivPeak(3)=1;
    errordlg('Must have atleast one division peak if division subtraction on','Error');    %display an error message
    return
end 
guidata(hObject, handles);
[handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2); %Update Plot
%Set-Up Cursors Again
if handles.DataAlreadyCalibrated==0;
    SliderUpdateReset(handles.TData(handles.XMinimumValueI),handles.TData(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
else
    if get(handles.GlobalFitButton,'value') == 1;
        GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    else
        SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    end    
end
guidata(hObject, handles);


%Used in the case of dividing the peak as a subtraction method, saying to use peak 4
function DivPeak4_Callback(hObject, eventdata, handles)
handles.GlobalDivPeak(4)=get(hObject,'Value');
if handles.GlobalDivPeak==[0,0,0,0,0]
    set(handles.DivPeak4,'value',1)
    handles.GlobalDivPeak(4)=1;
    errordlg('Must have atleast one division peak if division subtraction on','Error');    %display an error message
    return
end 
guidata(hObject, handles);
[handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2); %Update Plot
%Set-Up Cursors Again
if handles.DataAlreadyCalibrated==0;
    SliderUpdateReset(handles.TData(handles.XMinimumValueI),handles.TData(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
else
    if get(handles.GlobalFitButton,'value') == 1;
        GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    else
        SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    end    
end
guidata(hObject, handles);


%Used in the case of dividing the peak as a subtraction method, saying to use peak 5
function DivPeak5_Callback(hObject, eventdata, handles)
handles.GlobalDivPeak(5)=get(hObject,'Value');
if handles.GlobalDivPeak==[0,0,0,0,0]
    set(handles.DivPeak5,'value',1)
    handles.GlobalDivPeak(5)=1;
    errordlg('Must have atleast one division peak if division subtraction on','Error');    %display an error message
    return
end 
guidata(hObject, handles);
[handles.MainXData,handles.MainYData,handles.MainZData,handles.FullZData]=PlotUpdate(2); %Update Plot
%Set-Up Cursors Again
if handles.DataAlreadyCalibrated==0;
    SliderUpdateReset(handles.TData(handles.XMinimumValueI),handles.TData(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
else
    if get(handles.GlobalFitButton,'value') == 1;
        GlobalSliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    else
        SliderUpdateReset(handles.MQCal(handles.XMinimumValueI),handles.MQCal(handles.XMaximumValueI),handles.MinimumYValue,handles.MaximumYValue,handles.ThreeDPlot);                      %Set-up cursors
    end    
end
guidata(hObject, handles);


%Reset Multiple sliders for choosing regions
function GlobalSliderUpdateReset(minimumx,maximumx,minimumy,maximumy,ThreeD)

handles= guidata(gcbo);    %load in handles as this is a function, not a callback

if get(handles.LinLogYAxis,'value')==1
    minimumy=handles.MainYData(1);
    maximumy=handles.MainYData(end);
end

zmax=max(max(handles.MainZData));

%Set-up Initial cursors positions and limits
axes(handles.axes1);
for i=1:handles.NoRegions
    if handles.MaxAndMinRegions(i,1)<min(handles.MQCal) || handles.MaxAndMinRegions(i,1)>max(handles.MQCal) || (handles.MaxAndMinRegions(i,1) == 0 && handles.MaxAndMinRegions(i,2) == 0)
        if ThreeD==0
            line((ones(1,2)*minimumx),[minimumy,maximumy],'linestyle','-','Color',cell2mat(handles.GlobalSliderCell(i,1)),'Tag',handles.GlobalSliderCell{i,2});
        elseif ThreeD==1
            line((ones(1,2)*minimumx),[minimumy,maximumy],(ones(1,2)*(zmax*1.1)),'linestyle','-','Color',cell2mat(handles.GlobalSliderCell(i,1)),'Tag',handles.GlobalSliderCell{i,2});
        end
        set(handles.(['Slider' num2str(i) 'Min']),'string',num2str(minimumx));
        handles.MaxAndMinRegions(i,1)=minimumx;
    else
        if ThreeD==0
            line((ones(1,2)*handles.MaxAndMinRegions(i,1)),[minimumy,maximumy],'linestyle','-','Color',cell2mat(handles.GlobalSliderCell(i,1)),'Tag',handles.GlobalSliderCell{i,2});
        elseif ThreeD==1
            line((ones(1,2)*handles.MaxAndMinRegions(i,1)),[minimumy,maximumy],(ones(1,2)*(zmax*1.1)),'linestyle','-','Color',cell2mat(handles.GlobalSliderCell(i,1)),'Tag',handles.GlobalSliderCell{i,2});
        end
    end
    if handles.MaxAndMinRegions(i,2)>max(handles.MQCal) || handles.MaxAndMinRegions(i,2)<min(handles.MQCal) || (handles.MaxAndMinRegions(i,1) == 0 && handles.MaxAndMinRegions(i,2) == 0)
        if ThreeD==0
            line((ones(1,2)*maximumx),[minimumy,maximumy],'linestyle','-','Color',cell2mat(handles.GlobalSliderCell(i,1)),'Tag',handles.GlobalSliderCell{i,3});    
        elseif ThreeD==1
            line((ones(1,2)*maximumx),[minimumy,maximumy],(ones(1,2)*(zmax*1.1)),'linestyle','-','Color',cell2mat(handles.GlobalSliderCell(i,1)),'Tag',handles.GlobalSliderCell{i,3});    
        end
        set(handles.(['Slider' num2str(i) 'Max']),'string',num2str(maximumx));
        handles.MaxAndMinRegions(i,2)=maximumx;    
    else
        if ThreeD==0
            line((ones(1,2)*handles.MaxAndMinRegions(i,2)),[minimumy,maximumy],'linestyle','-','Color',cell2mat(handles.GlobalSliderCell(i,1)),'Tag',handles.GlobalSliderCell{i,3});
        elseif ThreeD==1
            line((ones(1,2)*handles.MaxAndMinRegions(i,2)),[minimumy,maximumy],(ones(1,2)*(zmax*1.1)),'linestyle','-','Color',cell2mat(handles.GlobalSliderCell(i,1)),'Tag',handles.GlobalSliderCell{i,3});   
        end
    end
end

%Set-Up Current Cursor Under Control
if handles.MaxAndMinRegions(handles.CurrentSliders,1)<minimumx || handles.MaxAndMinRegions(handles.CurrentSliders,1)>maximumx
    if ThreeD==0
        line((ones(1,2)*minimumx),[minimumy,maximumy],'linestyle','-','Color',cell2mat(handles.GlobalSliderCell(handles.CurrentSliders,1)),'Tag',handles.GlobalSliderCell{handles.CurrentSliders,2});
    elseif ThreeD==1
        line((ones(1,2)*minimumx),[minimumy,maximumy],(ones(1,2)*(zmax*1.1)),'linestyle','-','Color',cell2mat(handles.GlobalSliderCell(handles.CurrentSliders,1)),'Tag',handles.GlobalSliderCell{handles.CurrentSliders,2});
    end
    set(handles.(['Slider' num2str(handles.CurrentSliders) 'Min']),'string',num2str(minimumx));
    handles.MaxAndMinRegions(handles.CurrentSliders,1)=minimumx;
end
if handles.MaxAndMinRegions(handles.CurrentSliders,2)>maximumx || handles.MaxAndMinRegions(handles.CurrentSliders,2)<minimumx
    if ThreeD==0
        line((ones(1,2)*maximumx),[minimumy,maximumy],'linestyle','-','Color',cell2mat(handles.GlobalSliderCell(handles.CurrentSliders,1)),'Tag',handles.GlobalSliderCell{handles.CurrentSliders,3});
    elseif ThreeD==1
        line((ones(1,2)*maximumx),[minimumy,maximumy],'linestyle','-','Color',cell2mat(handles.GlobalSliderCell(handles.CurrentSliders,1)),'Tag',handles.GlobalSliderCell{handles.CurrentSliders,3});
    end
    set(handles.(['Slider' num2str(handles.CurrentSliders) 'Max']),'string',num2str(maximumx));
    handles.MaxAndMinRegions(handles.CurrentSliders,2)=maximumx;
end
set(handles.LeftSlider,'Min',minimumx,'Max',maximumx,'value',handles.MaxAndMinRegions(handles.CurrentSliders,1));
set(handles.RightSlider,'Min',minimumx,'Max',maximumx,'value',handles.MaxAndMinRegions(handles.CurrentSliders,2));

guidata(gcbo,handles)









% Data fitting function.
function DataFit(itterations)
%global start cct back ConsecutivelyFittingChannels CurrentFitData Zfit DataIsNowFitted residual
global CC SmallerTimesteps PosTimesteps NegTimesteps TimestepsIndex Decays PreviousDecays SRT Back CCT CurrentFitData PreviousTimeCon PreviousSRT PreviousBack Y Y2 URT NoDecay PreviousTimesteps SelectedFitRegions DivisionVector PreviousCCT UserFitOffset PreviousUserFitOffset TimestepsIndex2 DetailedTimestep PresentationFitData
handles= guidata(gcbo); 
if get(handles.GlobalFitButton,'value') == 0
    %Limit Data to that Between the Left and Right Cursors
    XDataMinSlider=min(get((findobj(gcf,'Tag','left slider')),'Xdata'));
    XDataMaxSlider=max(get((findobj(gcf,'Tag','right slider')),'Xdata'));
    [~,DataLimitLeftIndex]=min(abs(handles.MainXData-XDataMinSlider));
    [~,DataLimitRightIndex]=min(abs(handles.MainXData-XDataMaxSlider));
    RawData=handles.MainZData(:,DataLimitLeftIndex:DataLimitRightIndex);

    %Create some sort of choice statement here for global or summed fitting
    %NormalisedSummedData=(sum(RawData,2)-min(sum(RawData,2)))/max((sum(RawData,2)-min(sum(RawData,2))));
    %NormalisedGlobalData=(RawData-(min(min(RawData))))/(max(max(RawData-(min(min(RawData))))));
    %NormalisedGlobalData=(sum(RawData,2)-min(sum(RawData,2)))/max((sum(RawData,2)-min(sum(RawData,2))));
    DividedGlobalData=sum(RawData,2)./DivisionVector;
    NormalisedGlobalData=(DividedGlobalData-min(DividedGlobalData))/(max(DividedGlobalData)-min(DividedGlobalData));
else
    SelectedFitRegions=find(handles.DoNotFit(1:handles.NoRegions)==0); %Used to state if there are any user selescted regions not to fit
    if isempty(SelectedFitRegions)==1;
        errordlg('Must have atleast one region to fit','Error');    %display an error message
        return
    end
        
    handles.MaxAndMinRegions=[str2num(get(handles.Slider1Min,'string')),str2num(get(handles.Slider1Max,'string'));str2num(get(handles.Slider2Min,'string')),str2num(get(handles.Slider2Max,'string'));str2num(get(handles.Slider3Min,'string')),str2num(get(handles.Slider3Max,'string'));str2num(get(handles.Slider4Min,'string')),str2num(get(handles.Slider4Max,'string'));str2num(get(handles.Slider5Min,'string')),str2num(get(handles.Slider5Max,'string'))]; %Gets the Maximum and Minimum Values set for the sliders
    SummedPeakData=ones(size(handles.FullZData,1),handles.NoRegions);
    for i=1:handles.NoRegions;
        [~,LeftSliderPosition] = min(abs(handles.MQCal-handles.MaxAndMinRegions(i,1)));
        [~,RightSliderPosition] = min(abs(handles.MQCal-handles.MaxAndMinRegions(i,2)));
        DividedSummedPeakData=(sum(handles.FullZData(:,LeftSliderPosition:RightSliderPosition),2))./DivisionVector;
        %OffsetSummedPeakData(:,i)=(sum(handles.FullZData(:,LeftSliderPosition:RightSliderPosition),2))-min((sum(handles.FullZData(:,LeftSliderPosition:RightSliderPosition),2)));
        OffsetSummedPeakData(:,i)=DividedSummedPeakData-min(DividedSummedPeakData);
    end
    OffsetSummedPeakData=OffsetSummedPeakData(:,SelectedFitRegions);
    
    % Used for Norm to max fitting
%     NormalisedGlobalData=OffsetSummedPeakData/(max(max(OffsetSummedPeakData)));
    
    % Used for Norm to 1 fitting
    NormalisationConstants=max(OffsetSummedPeakData);
    NormalisedGlobalData=[];
    for i=1:length(NormalisationConstants)
        NormalisedGlobalData=[NormalisedGlobalData,OffsetSummedPeakData(:,i)/NormalisationConstants(i)];
    end
end


%assignin('base', 'NormalisedGlobalData', NormalisedGlobalData)

%Create Time Constant and Amplitude Matrix and RiseTime Information
TimeCon=[0,0;str2num(get(handles.t1,'string')),str2num(get(handles.t1Rise,'string'));str2num(get(handles.t2,'string')),str2num(get(handles.t2Rise,'string'));str2num(get(handles.t3,'string')),str2num(get(handles.t3Rise,'string'));str2num(get(handles.t4,'string')),str2num(get(handles.t4Rise,'string'));str2num(get(handles.t5,'string')),str2num(get(handles.t5Rise,'string'));str2num(get(handles.t6,'string')),str2num(get(handles.t6Rise,'string'));str2num(get(handles.t7,'string')),str2num(get(handles.t7Rise,'string'))];

%Rise Time Input Information
start=find(Decays(9:15)~=0);                 %Finds Channels with Different start times
rises=Decays(9:15);
SRT=zeros(size(Decays(9:15)));   
SRT(start)=rises(start)-1;
SRT=SRT(find(Decays(2:8)));                 %Checks which channels user has chosen to fit.


%Unknown Risetime
URT=Decays(37:43);  
URT=URT(find(Decays(2:8)));               %Checks which channels user has chosen to fit.

%No Decay Time
NoDecay=Decays(44:50);  
NoDecay=NoDecay(find(Decays(2:8)));               %Checks which channels user has chosen to fit.

%Checks for backwards fitting
Back=Decays(23:29);
Back=Back(find(Decays(2:8))); %Checks which channels user has chosen to fit.

%Amplitudes (as SRT and PreviousSRT switch which is larger, this if statement is required) Can now unclick any combination of tick boxes to fit without index errors
Amps=ones(8,(size(NormalisedGlobalData,2)));
if size(handles.PreviousFit) == size(NormalisedGlobalData);
    if handles.PreviousFit == NormalisedGlobalData;
        PreviousCompCurrent=ismember(find(PreviousDecays(1:8)),find(Decays(1:8)));       %Compares previous and current decays chosen
        if length(SRT)>length(PreviousSRT)
            k=find(PreviousDecays(1:8));     %Finds which channels were fitted in previous run
            k=k.*PreviousCompCurrent;  %Only will look at fits present in current settings (this stops failure when non-consecuative channels chosen to fit
            j=find(k);                   %So as to know which option was unclicked
            k(k==0) = [];               %Removes excess zeros
            l=1:length(k);
        elseif length(SRT)<length(PreviousSRT)
            k=find(Decays(1:8));     %Finds which channels are fitted in current run
            l=find(PreviousCompCurrent);    %So as to know which option were originally clicked
            k(k==0) = [];               %Removes excess zeros
            j=1:length(find(Decays(1:8)));
        else
            k=find(PreviousDecays(1:8));     %Finds which channels were fitted in previous run
            k=k.*PreviousCompCurrent;  %Only will look at fits present in current settings (this stops failure when non-consecuative channels chosen to fit
            k(k==0) = [];               %Removes excess zeros 
            j=1:length(k);
            l=1:length(k);
        end         
        for i=1:length(k)
            if TimeCon(k(i),1) == PreviousTimeCon(k(i),1) && TimeCon(k(i),2) == PreviousTimeCon(k(i),2) && SRT(j(i)) == PreviousSRT(l(i)) && Back(j(i)) == PreviousBack(l(i))
                Amps(k(i),:)=[handles.TimeConAndAmps(i,3:end)];       %Puts previous Amp magnitude information as initial guess
            end
        end
    end
end

handles.TimeConAndAmps=[TimeCon,Amps];

%Set-Up TimeConAndAmps for the current fit parameters
handles.TimeConAndAmps=handles.TimeConAndAmps(find(Decays(1:8)),:);

%New Extended Time Data
%Ensures Timedata is being used and not just Indicies in of Lin-Log Data
if get(handles.LinLogYAxis,'value') == 0;
    Timesteps=handles.MainYData;
else
    indicies=[];
    for l=1:length(handles.MainYData)
        k=find(handles.LinLogScale==handles.MainYData(l));
        indicies=[indicies,k];
    end
    Timesteps=handles.Timestep(indicies)+handles.Yoffsetvalue;
end



%Finds correct indicies in the extended time axis
%Spacing = (handles.Timestep(2)+handles.Yoffsetvalue)-(handles.Timestep(1)+handles.Yoffsetvalue); %find the minimum spacing between elements in x
%SmallerTimesteps=(Timesteps(1)-CCT):Spacing:(Timesteps(end)+(3*CCT));
Spacing = 3;
SmallerTimesteps=Timesteps(1):Spacing:(Timesteps(end)+(3*CCT));
PosTimesteps= (SmallerTimesteps>=0);
if isempty(find(SmallerTimesteps==0))==1
    NegTimesteps= (PosTimesteps~=1);
else
    NegTimesteps=zeros(1,length(PosTimesteps));
    zerocut=find(SmallerTimesteps==0);
    NegTimesteps(1:zerocut)=1;
end
TimestepsIndex=zeros(length(Timesteps),1);
for i=1:length(Timesteps)  %find where the original x values are in the newx vector
    [c index] = min(abs(SmallerTimesteps-Timesteps(i)));
    %TimestepsIndex(i) = find(SmallerTimesteps>=Timesteps(i),1);
    TimestepsIndex(i) = index;
end
TimestepsIndex2=[1:1:TimestepsIndex(end)];

%Used to generate a linlog y axis with mixed spacing for linear and log points for presentation of fits with more data points
DetailedTimestep=Timesteps(1):3:Timesteps(end);     %from start to finish in 3 fs steps
j=[];
for i=1:(length(Timesteps)-1) %Used to find difference between data points
    j=[j,(Timesteps(i+1)-Timesteps(i))];
end
cut=find(j>(Timesteps(2)-Timesteps(1)),1); %Find point lin goes to log

if isempty(cut)==1
    LinLogFitScale=linspace(1,length(Timesteps),length(DetailedTimestep));
else
    [c LinLogFitCutI] = min(abs(DetailedTimestep-Timesteps(cut)));
    %LinLogFitCutI=find(DetailedTimestep==Timesteps(cut))
    LinLogFitCut=DetailedTimestep(LinLogFitCutI);
    LogLinearTimesteps=[LinLogFitCut:3:Timesteps(end)];
    LogTimesteps=Timesteps(cut:end);
    LogIndicies=[];
    for l=1:length(LogTimesteps)
        [c index] = min(abs(LogLinearTimesteps-LogTimesteps(l)));
        LogIndicies=[LogIndicies,index];
    end
    LogIndiciesDifference=[];
    for l=1:(length(LogIndicies)-1)
        LogIndiciesDifference= [LogIndiciesDifference,(LogIndicies(l+1)-LogIndicies(l))];
    end
    AlteredLogPoints=[];
    for l=1:length(LogIndiciesDifference)
        d=logspace(log10(LogTimesteps(l)),log10(LogTimesteps(l+1)),(LogIndiciesDifference(l)));
        d=(d-min(d))/max(d-min(d));
        d=d+(l-1);
        AlteredLogPoints=[AlteredLogPoints,d];
    end
%     LogPoints=length(TempTimestep)-cut; %Finds number of log steps
    LinearPoints=linspace(1,cut,length(DetailedTimestep(1:LinLogFitCutI))); %Creates spacing for linear section 
    %Creates the linlog scale
%     AlteredLogPoints=logspace(log10(1),log10((TempTimestep(end)-LinLogFitCut)),((TempTimestep(end)-LinLogFitCut)/3));
%     AlteredLogPoints=AlteredLogPoints/max(AlteredLogPoints);
%     AlteredLogPoints=AlteredLogPoints*(str2double(get(handles.LinLogMultiplier,'String'))*(length(Timesteps)-cut));
%     AlteredLogPoints=AlteredLogPoints;
    AlteredLogPoints=AlteredLogPoints*(str2double(get(handles.LinLogMultiplier,'String')));
    AlteredLogPoints=AlteredLogPoints+cut;
    LinLogFitScale=[LinearPoints,AlteredLogPoints];
    LinLogFitScale=LinLogFitScale-1+handles.MainYData(1);
    
end

%Get the Instrument Response Function
CC=ccfit([0 str2num(get(handles.cc,'string')) 0 1],SmallerTimesteps);               %get the intrument response time

%Set-up Fitting Bounds
%lb=-Inf*ones(8,size(handles.TimeConAndAmps,2));
lb=zeros(8,size(handles.TimeConAndAmps,2));
% lb(:,1:2)=0.000000001;
ub=Inf*ones(8,size(handles.TimeConAndAmps,2));
k=find(Decays(16:22));     %Finds which Decay constants to fix
for i=1:length(k)
    lb((k(i)),1)=[(TimeCon(((k(i))+1),1)*0.99999999)];       %Puts lower limit to close to value
    ub((k(i)),1)=[(TimeCon(((k(i))+1),1)*1.00000001)];       %Puts upper limit to close to value
end
k=find(Decays(30:36));     %Finds which Rise constants to fix
for i=1:length(k)
    lb((k(i)),2)=[(TimeCon(((k(i))+1),2)*0.99999999)];       %Puts lower limit to close to value
    ub((k(i)),2)=[(TimeCon(((k(i))+1),2)*1.00000001)];       %Puts upper limit to close to value
end
%Check for any sequential rises which must be fixed due to a fixed decay
if any(SRT~=0)
    k=find(SRT>0);
    for i=1:length(k)
        if Decays(15+SRT(k(i)))==1
           lb((k(i)),2)=[(TimeCon(((SRT(k(i)))+1),1)*0.99999999)];       %Puts lower limit to close to value
           ub((k(i)),2)=[(TimeCon(((SRT(k(i)))+1),1)*1.00000001)];       %Puts upper limit to close to value 
        end
    end
end
 
%Keep the Required Boundaries for fits selected
LowerBounds=lb(find((Decays(1:8)))-1,:);     %Only Keeps Fits Chosen By User
UpperBounds=ub(find(Decays(1:8))-1,:);     %Only Keeps Fits Chosen By User

%fit
FitTest	= gdecay(handles.TimeConAndAmps,Timesteps); %check fit works (useful for debugging)
%opt     = optimset('TolX',1e-20000,'TolFun',1e-1200,'MaxFunEvals',3400,'Algorithm','levenberg-marquardt','Display','off'); %set the fitting options (note: remove 'Display','off' to see fitting statistics)
%opt  = optimset('OutputFcn',@OptPlot,'TolX',1e-20000,'TolFun',1e-1200,'MaxFunEvals',3400,'Algorithm','levenberg-marquardt','Display','off'); %set the fitting options (note: remove 'Display','off' to see fitting statistics)
opt  = optimset('OutputFcn',@OptPlot,'TolX',1e-16,'TolFun',1e-16,'MaxFunEvals',3400,'Algorithm','levenberg-marquardt','Display','off'); %set the fitting options (note: remove 'Display','off' to see fitting statistics)

tic
% for i   = 1:2                                                   %repeat the fit 5 times to improve converging
runningbox = msgbox('Fitting Data');

[TimeConAndAmps resnorm handles.residual exitflag] = lsqcurvefit(@gdecay,handles.TimeConAndAmps,Timesteps,NormalisedGlobalData,LowerBounds,UpperBounds,opt);   %fit using function gdecay below
delete(runningbox)
% end
toc
%save the outputs of the fitting routine
CurrentFitData	= gdecay(TimeConAndAmps,Timesteps);                  %get the fit y values (at the same x intervals as the original data)
FitTimeSpacing=Timesteps(1):Spacing:Timesteps(end);
PresentationFitData= gdecay2(TimeConAndAmps,FitTimeSpacing);

% figure()
% plot(handles.MainYData,NormalisedGlobalData(:,1),'o',LinLogFitScale,PresentationFitData(:,1),LinLogFitScale,squeeze(Y2(:,1,:)),'LineWidth',2)
% figure()
% plot(handles.MainYData,NormalisedGlobalData(:,1),'o',handles.MainYData,CurrentFitData(:,1),handles.MainYData,squeeze(Y(:,1,:)),'LineWidth',2)

TimeConAndAmps

%Create Legend for output plots
riseleg=[]; %Finds what should be put in legend for rise information
for i=1:size(TimeConAndAmps,1)
    if SRT(i)~= 0;
        k=TimeConAndAmps(SRT(i),1);
    elseif URT(i) ~= 0 || NoDecay(i) ~= 0
        k=TimeConAndAmps(i,2);
    else
        k=0;
    end
    riseleg=[riseleg,k];
end    
decayleg=[]; %Finds what should be put in legend for decay information
for i=1:size(TimeConAndAmps,1)
    if NoDecay(i)== 1;
        k=0;
    else
        k=TimeConAndAmps(i,1);
    end
    decayleg=[decayleg,k];
end
leg=({'Data Points', 'Fit', ['Offset = ' num2str(UserFitOffset)]});
FitsChosen=find(Decays(2:8));
for i=1:size(TimeConAndAmps,1)  %Builds legend heading depending upon number of fits applied and rise and decay information
    k=['\tau' num2str(FitsChosen(i)) ' Decay = ' ,num2str(decayleg(i)), ' ps, Rise = ', num2str(riseleg(i)), ' ps'];
    leg=[leg,k];
end

%included for plotting last point if not full data set
if get(handles.LinLogYAxis,'value') == 1;
    if handles.LinLogYTickLabels(end)~= handles.MainYData(end) || handles.LinLogYTickLabels(1)~= handles.MainYData(1)
        LinLogYTickLabels=[handles.LinLogYTickLabels,handles.MainYData(end),handles.MainYData(1)];
        LinearYTickLabels=[handles.LinearYTickLabels,SmallerTimesteps(TimestepsIndex(end)),SmallerTimesteps(TimestepsIndex(1))];
        LinLogYTickLabels=unique(LinLogYTickLabels);
        LinearYTickLabels=unique(LinearYTickLabels);
    end
end

%Plot the decays and fits
if get(handles.GlobalFitButton,'value') == 1
    sliderhandlesarray=[handles.Slider1Min,handles.Slider2Min,handles.Slider3Min,handles.Slider4Min,handles.Slider5Min,handles.Slider1Max,handles.Slider2Max,handles.Slider3Max,handles.Slider4Max,handles.Slider5Max]; %have array of all handles may need to access to build x labels
    for i=1:length(SelectedFitRegions)
        figure()
        if get(handles.LinLogYAxis,'value') == 0;
            %subplot(10,10,[1:80])
            subplot(13,13,[1:143])
            %plot(Timesteps,NormalisedGlobalData(:,i),'o',Timesteps,CurrentFitData(:,i),Timesteps,(ones(length(Timesteps),1)*UserFitOffset),Timesteps,squeeze(Y(:,i,:)),'LineWidth',2) 
            %plot(SmallerTimesteps(TimestepsIndex),NormalisedGlobalData(:,i),'o',SmallerTimesteps(TimestepsIndex),CurrentFitData(:,i),SmallerTimesteps(TimestepsIndex),(ones(length(Timesteps),1)*UserFitOffset),SmallerTimesteps(TimestepsIndex),squeeze(Y(:,i,:)),'LineWidth',2)          
            set(gca, 'ColorOrder', [0,0,1;0,0.5,0;1,0,0;0,0.75,0.75;0.75,0,0.75;0.75,0.75,0;0.247,0.247,0.247;0,1,0;0.87,0.49,0;0.48,0.06,0.89],'NextPlot', 'replacechildren');
            plot(SmallerTimesteps(TimestepsIndex),NormalisedGlobalData(:,i),'o',FitTimeSpacing,PresentationFitData(:,i),SmallerTimesteps(TimestepsIndex),(ones(length(Timesteps),1)*UserFitOffset),FitTimeSpacing,squeeze(Y2(:,i,:)),'LineWidth',2)
            set(gca,'XTick',[]);
            set(gca,'linewidth',2,'FontSize',14,'FontWeight','Bold')
            ylim([-0.05 1.05])
            xlim([Timesteps(1) Timesteps(end)])
            legend(leg,'linewidth',2)
            set(gca,'linewidth',2,'FontSize',14,'FontWeight','Bold')
            k=str2num(get(sliderhandlesarray(SelectedFitRegions(i)),'string'));    %get region minimum
            l=str2num(get(sliderhandlesarray(5+SelectedFitRegions(i)),'string'));    %get region maximum
            title(['M/Q= ' num2str((round(((k+l)*10)/2))/10) ' Mass Peak Decay Transients (Global Fit)'])
            %subplot(10,10,[81:100])
            subplot(13,13,[144:169])
            %plot(Timesteps,handles.residual(:,i),'r',Timesteps,zeros(length(Timesteps)),'--k','LineWidth',2)
            plot(SmallerTimesteps(TimestepsIndex),handles.residual(:,i),'r',SmallerTimesteps(TimestepsIndex),zeros(length(Timesteps)),'--k','LineWidth',2)
            ylim([-0.1 0.1])
            xlim([Timesteps(1) Timesteps(end)])
            legend('residual');
            set(gca,'linewidth',2,'FontSize',14,'FontWeight','Bold')
        elseif get(handles.LinLogYAxis,'value') == 1;
            %subplot(10,10,[1:80])
            subplot(13,13,[1:143])
            %plot(handles.MainYData,NormalisedGlobalData(:,i),'o',handles.MainYData,CurrentFitData(:,i),handles.MainYData,(ones(length(Timesteps),1)*UserFitOffset),handles.MainYData,squeeze(Y(:,i,:)),'LineWidth',2)
            set(gca, 'ColorOrder', [0,0,1;0,0.5,0;1,0,0;0,0.75,0.75;0.75,0,0.75;0.75,0.75,0;0.247,0.247,0.247;0,1,0;0.87,0.49,0;0.48,0.06,0.89],'NextPlot', 'replacechildren');
            plot(handles.MainYData,NormalisedGlobalData(:,i),'o',LinLogFitScale,PresentationFitData(:,i),handles.MainYData,(ones(length(Timesteps),1)*UserFitOffset),LinLogFitScale,squeeze(Y2(:,i,:)),'LineWidth',2)
            set(gca,'XTick',[]);
            ylim([-0.05 1.05])
            xlim([handles.MainYData(1) handles.MainYData(end)])
            legend(leg,'linewidth',2);
            set(gca,'linewidth',2,'FontSize',14,'FontWeight','Bold')
            k=str2num(get(sliderhandlesarray(SelectedFitRegions(i)),'string'));    %get region minimum
            l=str2num(get(sliderhandlesarray(5+SelectedFitRegions(i)),'string'));    %get region maximum
            title(['M/Q= ' num2str((round(((k+l)*10)/2))/10) ' Mass Peak Decay Transients (Global Fit)'])
            %subplot(10,10,[81:100])
            subplot(13,13,[144:169])
            plot(handles.MainYData,handles.residual(:,i),'r',handles.MainYData,zeros(length(handles.MainYData)),'--k','LineWidth',2)
            ylim([-0.1 0.1])
            xlim([handles.MainYData(1) handles.MainYData(end)])
            legend('residual');
            set(gca,'XTick',LinLogYTickLabels);
            set(gca,'XTickLabel',LinearYTickLabels);
            set(gca,'linewidth',2,'FontSize',14,'FontWeight','Bold')
        end
    end
else
    figure()
    if get(handles.LinLogYAxis,'value') == 0;
        %subplot(10,10,[1:80])
        subplot(13,13,[1:143])
        %plot(Timesteps,NormalisedGlobalData,'o',Timesteps,CurrentFitData,Timesteps,(ones(length(Timesteps),1)*UserFitOffset),Timesteps,squeeze(Y(:,1,:)),'LineWidth',2)
        %plot(SmallerTimesteps(TimestepsIndex),NormalisedGlobalData,'o',SmallerTimesteps(TimestepsIndex),CurrentFitData,SmallerTimesteps(TimestepsIndex),(ones(length(Timesteps),1)*UserFitOffset),SmallerTimesteps(TimestepsIndex),squeeze(Y(:,1,:)),'LineWidth',2)
        set(gca, 'ColorOrder', [0,0,1;0,0.5,0;1,0,0;0,0.75,0.75;0.75,0,0.75;0.75,0.75,0;0.247,0.247,0.247;0,1,0;0.87,0.49,0;0.48,0.06,0.89],'NextPlot', 'replacechildren');
        plot(SmallerTimesteps(TimestepsIndex),NormalisedGlobalData,'o',FitTimeSpacing,PresentationFitData,SmallerTimesteps(TimestepsIndex),(ones(length(Timesteps),1)*UserFitOffset),FitTimeSpacing,squeeze(Y2(:,1,:)),'LineWidth',2)
        set(gca,'XTick',[]);
        ylim([-0.05 1.05])
        xlim([Timesteps(1) Timesteps(end)])
        legend(leg,'linewidth',2);
        set(gca,'linewidth',2,'FontSize',14,'FontWeight','Bold')
        title(['M/Q= ' num2str((round(((XDataMaxSlider+XDataMinSlider)*10)/2))/10) ' Mass Peak Decay Transients (Individual Fit)'])
        %subplot(10,10,[81:100])
        subplot(13,13,[144:169])
        set(gca,'linewidth',2,'FontSize',14,'FontWeight','Bold')
        %plot(Timesteps,handles.residual,'r',Timesteps,zeros(length(Timesteps)),'--k','LineWidth',2)
        plot(SmallerTimesteps(TimestepsIndex),handles.residual,'r',SmallerTimesteps(TimestepsIndex),zeros(length(Timesteps)),'--k','LineWidth',2)
        ylim([-0.1 0.1])
        xlim([Timesteps(1) Timesteps(end)])
        legend('residual')
        set(gca,'linewidth',2,'FontSize',14,'FontWeight','Bold')
    elseif get(handles.LinLogYAxis,'value') == 1;
        %subplot(10,10,[1:80])
        subplot(13,13,[1:143])
        %plot(handles.MainYData,NormalisedGlobalData,'o',handles.MainYData,CurrentFitData,handles.MainYData,(ones(length(Timesteps),1)*UserFitOffset),handles.MainYData,squeeze(Y(:,1,:)),'LineWidth',2)
        set(gca, 'ColorOrder', [0,0,1;0,0.5,0;1,0,0;0,0.75,0.75;0.75,0,0.75;0.75,0.75,0;0.247,0.247,0.247;0,1,0;0.87,0.49,0;0.48,0.06,0.89],'NextPlot', 'replacechildren');
        plot(handles.MainYData,NormalisedGlobalData,'o',LinLogFitScale,PresentationFitData,handles.MainYData,(ones(length(Timesteps),1)*UserFitOffset),LinLogFitScale,squeeze(Y2(:,1,:)),'LineWidth',2)
        set(gca,'XTick',[]);
        ylim([-0.05 1.05])
        xlim([handles.MainYData(1) handles.MainYData(end)])
        legend(leg,'linewidth',2);
        set(gca,'linewidth',2,'FontSize',14,'FontWeight','Bold')
        title(['M/Q= ' num2str((round(((XDataMaxSlider+XDataMinSlider)*10)/2))/10) ' Mass Peak Decay Transients (Individual Fit)'])
        %subplot(10,10,[81:100])
        subplot(13,13,[144:169])
        set(gca,'linewidth',2,'FontSize',14,'FontWeight','Bold')
        plot(handles.MainYData,handles.residual,'r',handles.MainYData,zeros(length(Timesteps)),'--k','LineWidth',2)
        ylim([-0.1 0.1])
        xlim([handles.MainYData(1) handles.MainYData(end)])
        legend('residual')
        set(gca,'linewidth',2,'FontSize',14,'FontWeight','Bold')
        set(gca,'XTick',LinLogYTickLabels);
        set(gca,'XTickLabel',LinearYTickLabels);
        set(gca,'linewidth',2,'FontSize',14,'FontWeight','Bold')
    end
end

%Create a bar chart to show fit amplitudes
Amplitudes=((TimeConAndAmps(:,3:end))*1000)';  %Multiplied output from fit a thousandth of actual amplitude
figure()
if get(handles.GlobalFitButton,'value') == 1
    if size(Amplitudes,1)==1  %If only one selected region in global fit
        subplot(2,1,1)
        BarChart=bar(1:size(Amplitudes,2),diag(Amplitudes),'stacked','LineWidth',2); %Needs to be in the form of a matrix or else matlab reconises only as a single variable
        BarChartColours=[0,0.75,0.75;0.75,0,0.75;0.75,0.75,0;0.247,0.247,0.247;0,1,0;0.87,0.49,0;0.48,0.06,0.89];
        for i=1:size(Amplitudes,2)
            set(BarChart(i),'FaceColor',BarChartColours(i,:))
        end
        %BarChart.BaseLine.LineWidth = 2;
        XBarLabel={}; %Create empty xlabel to build cell
        for i=1:size(Amplitudes,2) %For number fits
            string=(['t' num2str(i)]);
            XBarLabel=[XBarLabel,cellstr(string)];     %Put information into xlabel array
        end
        k=str2num(get(sliderhandlesarray(SelectedFitRegions(1)),'string'));    %get region minimum
        l=str2num(get(sliderhandlesarray(5+SelectedFitRegions(1)),'string'));    %get region maximum
        set(gca,'XTickLabel',XBarLabel);
        set(gca,'linewidth',2,'FontSize',14,'FontWeight','Bold')
        title(['Decay Amplitudes for Mass Peak M/Q = ' num2str((round(((k+l)*10)/2))/10) ' (Global Fit)'])
        ylim([-0.2 1.5])
        xl= xlim; %Sets xlimits for asthestics
        if size(Amplitudes,2)==1
            xl(2)=xl(2)+0.2;
            xl(1)=xl(1)-0.2;
        elseif size(Amplitudes,2)==2
            xl(2)=xl(2)+0.2;
        end
        xlim(xl);
        leg=leg(4:end); %Limits legend made earlier for current requirements
        legend(leg,'linewidth',2);
        %Now Normalise for subplot2
        NormalisationTimeConstant=find(Amplitudes(1,:)==max(Amplitudes(1,:))); %Finds largest amplitude timeconstant in parent
        NormalisedAmplitudes=Amplitudes(1,:)/Amplitudes(1,NormalisationTimeConstant);     
        subplot(2,1,2)
        BarChart=bar(1:size(NormalisedAmplitudes,2),diag(NormalisedAmplitudes),'stacked','LineWidth',2); %Needs to be in the form of a matrix or else matlab reconises only as a single variable
        for i=1:size(NormalisedAmplitudes,2)
            set(BarChart(i),'FaceColor',BarChartColours(i,:))
        end
        
        set(gca,'XTickLabel',XBarLabel);
        xl= xlim; %Sets xlimits for asthestics
        if size(Amplitudes,2)==1
            xl(2)=xl(2)+0.2;
            xl(1)=xl(1)-0.2;
        elseif size(Amplitudes,2)==2
            xl(2)=xl(2)+0.2;
        end
        xlim(xl);
        set(gca,'linewidth',2,'FontSize',14,'FontWeight','Bold')
        title(['Normalised Decay Amplitudes for Mass Peaks ' num2str((round(((k+l)*10)/2))/10) ' (Global Fit)'])
    else  %if global fit and user has chosen more than one region
        subplot(2,1,1)
        BarChart=bar(Amplitudes,'LineWidth',2);
        BarChartColours=[0,0.75,0.75;0.75,0,0.75;0.75,0.75,0;0.247,0.247,0.247;0,1,0;0.87,0.49,0;0.48,0.06,0.89];
        for i=1:size(Amplitudes,2)
            set(BarChart(i),'FaceColor',BarChartColours(i,:))
        end
        
        XBarLabel={}; %Create empty xlabel to build cell
        XBarString='';
        for i=1:length(SelectedFitRegions) %For number of regions fitted
            k=str2num(get(sliderhandlesarray(SelectedFitRegions(i)),'string'));    %get region minimum
            l=str2num(get(sliderhandlesarray(5+SelectedFitRegions(i)),'string'));    %get region maximum
            XBarLabel=[XBarLabel,num2cell((round(((k+l)*10)/2))/10)];     %Put information into xlabel array
            if i == 1 %Used for crating title string
                XBarString=strcat(XBarString,'M/Q = ',num2str((round(((k+l)*10)/2))/10));
            elseif i == length(SelectedFitRegions)
                XBarString=strcat(XBarString,' and M/Q = ',num2str((round(((k+l)*10)/2))/10));
            else
                XBarString=strcat(XBarString,', M/Q = ',num2str((round(((k+l)*10)/2))/10));
            end
        end
        set(gca,'XTickLabel',XBarLabel);
        set(gca,'linewidth',3,'FontSize',14,'FontWeight','Bold')
        title(['Decay Amplitudes for Mass Peaks ' XBarString ' (Global Fit)'])
        ylim([-0.2 1.5])
        leg=leg(4:end);
        legend(leg,'linewidth',2);
        %Now Normalise for subplot2
        ParentPeak=find(cell2mat(XBarLabel)==max(cell2mat(XBarLabel))); %Finds which is the highest mass peak
        ParentPeak=ParentPeak(end); %Used if 2 or more regions the same are used as parent (ie 100-120 for 2 peaks)
        NormalisationTimeConstant=find(Amplitudes(ParentPeak,:)==max(Amplitudes(ParentPeak,:))); %Finds largest amplitude timeconstant in parent
        for i=1:size(Amplitudes,1) %Normalise the timeconstant amplitudes with respect to the largest time constant in the parent
            NormalisingAmplitudes=Amplitudes(i,:)/Amplitudes(i,NormalisationTimeConstant);
            if i==1
                NormalisedAmplitudes=NormalisingAmplitudes;
            else
                NormalisedAmplitudes=[NormalisedAmplitudes;NormalisingAmplitudes];
            end
        end       
        subplot(2,1,2)
        BarChart=bar(NormalisedAmplitudes,'LineWidth',2);
        for i=1:size(NormalisedAmplitudes,2)
            set(BarChart(i),'FaceColor',BarChartColours(i,:))
        end
        
        set(gca,'XTickLabel',XBarLabel);
        set(gca,'linewidth',2,'FontSize',14,'FontWeight','Bold')
        title(['Normalised Decay Amplitudes for Mass Peaks ' XBarString ' (Global Fit)'])
    end
else %If on individual fit
    subplot(2,1,1)
    BarChart=bar(1:size(Amplitudes,2),diag(Amplitudes),'stacked','LineWidth',2); %Needs to be in the form of a matrix or else matlab reconises only as a single variable
    BarChartColours=[0,0.75,0.75;0.75,0,0.75;0.75,0.75,0;0.247,0.247,0.247;0,1,0;0.87,0.49,0;0.48,0.06,0.89];
    for i=1:size(Amplitudes,2)
        set(BarChart(i),'FaceColor',BarChartColours(i,:))
    end
    
    XBarLabel={}; %Create empty xlabel to build cell
    for i=1:size(Amplitudes,2) %For number fits
        string=(['t' num2str(i)]);
        XBarLabel=[XBarLabel,cellstr(string)];     %Put information into xlabel array
    end
    set(gca,'XTickLabel',XBarLabel);
    set(gca,'linewidth',2,'FontSize',14,'FontWeight','Bold')
    title(['Decay Amplitudes for Mass Peak M/Q = ' num2str((round(((XDataMaxSlider+XDataMinSlider)*10)/2))/10) ' (Individual Fit)'])
    ylim([-0.2 1.5])
    xl= xlim; %Sets xlimits for asthestics
    if size(Amplitudes,2)==1
        xl(2)=xl(2)+0.2;
        xl(1)=xl(1)-0.2;
    elseif size(Amplitudes,2)==2
        xl(2)=xl(2)+0.2;
    end
    xlim(xl);
    leg=leg(4:end);
    legend(leg,'linewidth',2);
    %Now Normalise for subplot2
    NormalisationTimeConstant=find(Amplitudes(1,:)==max(Amplitudes(1,:))); %Finds largest amplitude timeconstant in parent
    NormalisedAmplitudes=Amplitudes(1,:)/Amplitudes(1,NormalisationTimeConstant);     
    subplot(2,1,2)
    BarChart=bar(1:size(NormalisedAmplitudes,2),diag(NormalisedAmplitudes),'stacked','LineWidth',2); %Needs to be in the form of a matrix or else matlab reconises only as a single variable
    for i=1:size(NormalisedAmplitudes,2)
        set(BarChart(i),'FaceColor',BarChartColours(i,:))
    end
    
    set(gca,'XTickLabel',XBarLabel);
    xl= xlim; %Sets xlimits for asthestics
    if size(Amplitudes,2)==1
        xl(2)=xl(2)+0.2;
        xl(1)=xl(1)-0.2;
    elseif size(Amplitudes,2)==2
        xl(2)=xl(2)+0.2;
    end
    xlim(xl);
    title(['Normalised Decay Amplitudes for Mass Peaks ' num2str((round(((XDataMaxSlider+XDataMinSlider)*10)/2))/10) ' (Individual Fit)'],'FontSize',14,'FontWeight','Bold')
    set(gca,'linewidth',2,'FontSize',14,'FontWeight','Bold')
end

%Section used for peak comparrison from raw data
for i=1:size(NormalisedGlobalData,2)
    if i==1
        NormalisedIndividualPeaks=NormalisedGlobalData(:,i)/max(NormalisedGlobalData(:,i));
    else
        NormalisedIndividualPeaks=[NormalisedIndividualPeaks,(NormalisedGlobalData(:,i)/max(NormalisedGlobalData(:,i)))];
    end
end
% for i=1:size(NormalisedGlobalData,2)
    figure()
    if get(handles.LinLogYAxis,'value') == 0;
        %plot(Timesteps,NormalisedIndividualPeaks(:,i),'LineWidth',2);
        set(gca, 'ColorOrder', [0,0,1;0,0.5,0;1,0,0;0,0.75,0.75;0.75,0,0.75;0.75,0.75,0;0.247,0.247,0.247;0,1,0;0.87,0.49,0;0.48,0.06,0.89],'NextPlot', 'replacechildren');
        plot(Timesteps,NormalisedIndividualPeaks,'LineWidth',2);
        xlim([Timesteps(1) Timesteps(end)]);
    elseif get(handles.LinLogYAxis,'value') == 1;
        %plot(handles.MainYData,NormalisedIndividualPeaks(:,i),'LineWidth',2);
        set(gca, 'ColorOrder', [0,0,1;0,0.5,0;1,0,0;0,0.75,0.75;0.75,0,0.75;0.75,0.75,0;0.247,0.247,0.247;0,1,0;0.87,0.49,0;0.48,0.06,0.89],'NextPlot', 'replacechildren');
        plot(handles.MainYData,NormalisedIndividualPeaks,'LineWidth',2);
        set(gca,'XTick',LinLogYTickLabels);
        set(gca,'XTickLabel',LinearYTickLabels);
        xlim([handles.MainYData(1) handles.MainYData(end)]);
    end
    set(gca,'linewidth',2,'FontSize',14,'FontWeight','Bold')
    leg2=({'Normalised Mass Peak 1', 'Normalised Mass Peak 2', 'Normalised Mass Peak 3', 'Normalised Mass Peak 4', 'Normalised Mass Peak 5'});
    legend(leg2,'linewidth',2);
    title(['Normalised Mass Peaks: ' num2str(i) ''],'FontSize',14,'FontWeight','Bold')
% end
%Update GUI Time Constants
k=find(Decays(1:8));     %Find which channels were fitted
if any(k==2)             %Checks for channel 1
    Index=find(k==2);
    set(handles.t1,'string',TimeConAndAmps(Index,1));
    if SRT(Index)~=0            %If sequential risetime, state rise from decayed output
        set(handles.t1Rise,'string',TimeConAndAmps(SRT(Index),1));
    elseif URT(Index)==1 || NoDecay(Index) == 1       %If unknown risetime, state unkown rise found
        set(handles.t1Rise,'string',TimeConAndAmps(Index,2));
    else
        set(handles.t1Rise,'string','0');
    end
end
if any(k==3)             %Checks for channel 2
    Index=find(k==3);
    set(handles.t2,'string',TimeConAndAmps(Index,1));
    if SRT(Index)~=0            %If sequential risetime, state rise from decayed output
        set(handles.t2Rise,'string',TimeConAndAmps(SRT(Index),1));
    elseif URT(Index)==1 || NoDecay(Index) == 1       %If unknown risetime, state unkown rise found
        set(handles.t2Rise,'string',TimeConAndAmps(Index,2));
    else
        set(handles.t2Rise,'string','0');
    end
end
if any(k==4)             %Checks for channel 3
    Index=find(k==4);
    set(handles.t3,'string',TimeConAndAmps(Index,1));
    if SRT(Index)~=0            %If sequential risetime, state rise from decayed output
        set(handles.t3Rise,'string',TimeConAndAmps(SRT(Index),1));
    elseif URT(Index)==1 || NoDecay(Index) == 1       %If unknown risetime, state unkown rise found
        set(handles.t3Rise,'string',TimeConAndAmps(Index,2));
    else
        set(handles.t3Rise,'string','0');
    end
end
if any(k==5)             %Checks for channel 4
    Index=find(k==5);
    set(handles.t4,'string',TimeConAndAmps(Index,1));
    if SRT(Index)~=0            %If sequential risetime, state rise from decayed output
        set(handles.t4Rise,'string',TimeConAndAmps(SRT(Index),1));
    elseif URT(Index)==1  || NoDecay(Index) == 1      %If unknown risetime, state unkown rise found
        set(handles.t4Rise,'string',TimeConAndAmps(Index,2));
    else
        set(handles.t4Rise,'string','0');
    end
end
if any(k==6)             %Checks for channel 4
    Index=find(k==6);
    set(handles.t5,'string',TimeConAndAmps(Index,1));
    if SRT(Index)~=0            %If sequential risetime, state rise from decayed output
        set(handles.t5Rise,'string',TimeConAndAmps(SRT(Index),1));
    elseif URT(Index)==1  || NoDecay(Index) == 1      %If unknown risetime, state unkown rise found
        set(handles.t5Rise,'string',TimeConAndAmps(Index,2));
    else
        set(handles.t5Rise,'string','0');
    end
end
if any(k==7)             %Checks for channel 4
    Index=find(k==7);
    set(handles.t6,'string',TimeConAndAmps(Index,1));
    if SRT(Index)~=0            %If sequential risetime, state rise from decayed output
        set(handles.t6Rise,'string',TimeConAndAmps(SRT(Index),1));
    elseif URT(Index)==1  || NoDecay(Index) == 1      %If unknown risetime, state unkown rise found
        set(handles.t6Rise,'string',TimeConAndAmps(Index,2));
    else
        set(handles.t6Rise,'string','0');
    end
end
if any(k==8)             %Checks for channel 4
    Index=find(k==8);
    set(handles.t7,'string',TimeConAndAmps(Index,1));
    if SRT(Index)~=0            %If sequential risetime, state rise from decayed output
        set(handles.t7Rise,'string',TimeConAndAmps(SRT(Index),1));
    elseif URT(Index)==1  || NoDecay(Index) == 1      %If unknown risetime, state unkown rise found
        set(handles.t7Rise,'string',TimeConAndAmps(Index,2));
    else
        set(handles.t7Rise,'string','0');
    end
end

%Enable Save Fit Button
set(handles.SaveFit,'enable','on')

%Update variables
handles.TimeConAndAmps=TimeConAndAmps;
handles.PreviousFit= NormalisedGlobalData;
PreviousDecays=Decays;
PreviousSRT=SRT;
PreviousBack=Back;
PreviousUserFitOffset=UserFitOffset;
PreviousTimesteps=Timesteps; %This is used in the save fit function as a reminder of the timesteps at the time the fit was made
if get(handles.GlobalFitButton,'value') == 1
    handles.MaxAndMinRegionsSave=handles.MaxAndMinRegions; %Saves the present positions of the sliders to be used when saving fit data
else
    handles.MaxAndMinRegionsSave=[XDataMinSlider,XDataMaxSlider];
end
handles.TimeCons =[str2num(get(handles.t1,'string')),str2num(get(handles.t1Rise,'string'));str2num(get(handles.t2,'string')),str2num(get(handles.t2Rise,'string'));str2num(get(handles.t3,'string')),str2num(get(handles.t3Rise,'string'));str2num(get(handles.t4,'string')),str2num(get(handles.t4Rise,'string'));str2num(get(handles.t5,'string')),str2num(get(handles.t5Rise,'string'));str2num(get(handles.t6,'string')),str2num(get(handles.t6Rise,'string'));str2num(get(handles.t7,'string')),str2num(get(handles.t7Rise,'string'))];  %Keeps a record of current user timeconstants
PreviousTimeCon=[0,0;handles.TimeCons];
PreviousCCT=CCT; % Used in saving code so as user knows what cross correlation was for the fit
guidata(gcbo,handles) 



function y=gdecay(input,xdata)
global Y yofs SRT CC SmallerTimesteps TimestepsIndex PosTimesteps NegTimesteps Back URT NoDecay UserFitOffset
%initialise variables
input  = input*1000;                            %input has previosly been devided by 1000 to allow easier fitting (smaller step sizes)
xdata  = xdata(:);                              %make sure it's a column vector;
fits   = length(SRT);                           %get how many chanels (or decays) are being used
slices = size(input,2)-2; s=size(input,2)-2;     %get how large the dataset is (not used here, only for global fitting)
%Y      = zeros(length(xdata),slices,fits);      %prepare space for Y (fit for each indevidual channel)
%y      = zeros(length(xdata),slices);           %prepare space for y (overall fit data)
%rise   = ones (length(TimestepsIndex),fits);              %prepare space for rise  (rise curve for each chanel)
Y      = zeros(length(SmallerTimesteps),slices,fits);      %prepare space for Y (fit for each indevidual channel)
y      = zeros(length(SmallerTimesteps),slices);           %prepare space for y (overall fit data)
rise   = ones (length(SmallerTimesteps),fits);              %prepare space for rise  (rise curve for each chanel)
decay  = ones (length(SmallerTimesteps),fits);              %prepare space for decay (decay curve for each chanel)
convolution = ones (((2*(length(SmallerTimesteps)))-1),fits);       %prepare space for convolution (rise and decay convolution for each chanel)
spacing= SmallerTimesteps(2)-SmallerTimesteps(1);                       %find out what the spacing is between newx values
xvals  = (1:length(SmallerTimesteps)) + (find(SmallerTimesteps>=0,1)-1);    %figure out which xvalues of the convoluted data to use
BelowZero=(find(SmallerTimesteps>=0,1))-1;
if isempty(find(SmallerTimesteps==0))==1
    BelowZeroBack=BelowZero+1;                                              %Below zero for backwards fitting(so index of first positive number
else
    BelowZeroBack=BelowZero;
end


for f = 1:fits;                                %for each fit
    %calculate rise time curves
    if SRT(f), % if there is a rise time, calculate y(x) = 1-(e^-tx) rise time curve and convolute it with the crosscorelation
        if Back(f)==0 
            risefit   = 1-(PosTimesteps .* exp(-SmallerTimesteps./(input(SRT(f),1))));
            if BelowZero~=0 && isempty(BelowZero)==0
                risefit(1:BelowZero)=0;     %Sets anything below zero to zero if applicable to fit
            end
        else
             risefit   =1-(NegTimesteps .* exp(SmallerTimesteps./input(SRT(f),1)));
             if BelowZeroBack~=0 && isempty(BelowZeroBack)==0
                 risefit(BelowZeroBack:end)=0;     %Sets anything above zero to zero if applicable to fit
             end
        end
          risefit=conv(risefit,CC);
          risefit=risefit(xvals);
          %rise(:,f) = risefit(TimestepsIndex);
          rise(:,f) = risefit;
     elseif URT(f) || NoDecay(f)
         if Back(f)==0
             risefit   =1-(PosTimesteps .* exp(-SmallerTimesteps./(input(f,2))));
             if BelowZero~=0 && isempty(BelowZero)==0
                 risefit(1:BelowZero)=0;     %Sets anything below zero to zero if applicable to fit
             end
         else
             risefit   =1-(NegTimesteps .* exp(SmallerTimesteps./input(f,2)));
             if BelowZeroBack~=0 && isempty(BelowZeroBack)==0
                 risefit(BelowZeroBack:end)=0;     %Sets anything above zero to zero if applicable to fit
             end
         end
             risefit=conv(risefit,CC);
             risefit=risefit(xvals);
             risefit=risefit/max(risefit);
             %rise(:,f) = risefit(TimestepsIndex);
             rise(:,f) = risefit;
    %else rise(:,f) = ones(length(TimestepsIndex),1); %otherwise, just use the crosscorrelation 
    else rise(:,f) = ones(length(SmallerTimesteps),1); %otherwise, just use the crosscorrelation 
    end
    
%     k=rise(TimestepsIndex,4)'
%     
%     figure()
%     plot(k)
    
    %calculate decay time curves
    if Back(f)==1
        decay(:,f) = NegTimesteps .* exp(SmallerTimesteps./input(f,1));  %calculate decay time curve (y(x) = e^-tx)
        convolution(:,f)    = conv(decay(:,f),CC);    %convolute the decay with the rise using matlab inbuilt function
        convolution(:,f)    = convolution(:,f)/max(convolution(:,f));
        if NoDecay(f)==1
            convolution(:,f)=ones(size(convolution(:,f)));  %Set to ones as no decay required 
        end
    elseif NoDecay(f)==1 
        decay(:,f) = PosTimesteps .* exp(-SmallerTimesteps./input(f,1));  %calculate decay time curve (y(x) = e^-tx)
        convolutiontemp= conv(decay(:,f),CC);    %convolute the decay with the rise using matlab inbuilt function )
        convolution(:,f)    = ones(size(convolutiontemp));    %Set to ones as no decay required 
    else
        decay(:,f) = PosTimesteps .* exp(-SmallerTimesteps./input(f,1));  %calculate decay time curve (y(x) = e^-tx)
        convolution(:,f)    = conv(decay(:,f),CC);    %convolute the decay with the rise using matlab inbuilt function )
        convolution(:,f)    = convolution(:,f)/max(convolution(:,f));
    end 
end
%Select relevant values, apply relevant rise time and normalise
decayconv=convolution(xvals,:);

%rtfit=decayconv(TimestepsIndex,:).*rise;
rtfit=decayconv.*rise;
rtfit= bsxfun(@rdivide, rtfit, max(rtfit));

%Amplitude fit and add the diffeernt amplitudes up for a comparison output
for s = 1:slices                                %fit each slice (Peak) of the dataset
    for f = 1:fits;                                 %fit each chanel    
        convfit    = input(f,(s+2)).* rtfit(:,f);  %get rid of excess x values (so it's back to newx spacing) and apply a multiplier (2*spacing/cct used to keep base amplitude at 1)  
        convfit(isnan(convfit))=0;                 %Replaces any NAN with zeros
        Y(:,s,f)   = convfit;                 %change the x spacing back into the original (data) x spacing
        y(:,s) = sum(Y(:,s,:),3); %+ yofs;                %add the different chanels together
    end 
end
Y=Y(TimestepsIndex,:);
y=y+UserFitOffset;
y=y(TimestepsIndex,:);

%Used for second set of data to make better plot
function y=gdecay2(input,xdata)
global Y2 yofs SRT CC SmallerTimesteps TimestepsIndex2 PosTimesteps NegTimesteps Back URT NoDecay UserFitOffset
%initialise variables
input  = input*1000;                            %input has previosly been devided by 1000 to allow easier fitting (smaller step sizes)
xdata  = xdata(:);                              %make sure it's a column vector;
fits   = length(SRT);                           %get how many chanels (or decays) are being used
slices = size(input,2)-2; s=size(input,2)-2;     %get how large the dataset is (not used here, only for global fitting)
Y2      = zeros(length(xdata),slices,fits);      %prepare space for Y (fit for each indevidual channel)
y      = zeros(length(xdata),slices);           %prepare space for y (overall fit data)
rise   = ones (length(TimestepsIndex2),fits);              %prepare space for rise  (rise curve for each chanel)
decay  = ones (length(SmallerTimesteps),fits);              %prepare space for decay (decay curve for each chanel)
convolution = ones (((2*(length(SmallerTimesteps)))-1),fits);       %prepare space for convolution (rise and decay convolution for each chanel)
spacing= SmallerTimesteps(2)-SmallerTimesteps(1);                       %find out what the spacing is between newx values
xvals  = (1:length(SmallerTimesteps)) + (find(SmallerTimesteps>=0,1)-1);    %figure out which xvalues of the convoluted data to use
BelowZero=(find(SmallerTimesteps>=0,1))-1;
if isempty(find(SmallerTimesteps==0))==1
    BelowZeroBack=BelowZero+1;                                              %Below zero for backwards fitting(so index of first positive number
else
    BelowZeroBack=BelowZero;
end                                           %Below zero for backwards fitting(so index of first positive number

for f = 1:fits;                                %for each fit
    %calculate rise time curves
    if SRT(f), % if there is a rise time, calculate y(x) = 1-(e^-tx) rise time curve and convolute it with the crosscorelation
        if Back(f)==0 
            risefit   = 1-(PosTimesteps .* exp(-SmallerTimesteps./(input(SRT(f),1))));
            if BelowZero~=0 && isempty(BelowZero)==0
                risefit(1:BelowZero)=0;     %Sets anything below zero to zero if applicable to fit
            end
        else
             risefit   =1-(NegTimesteps .* exp(SmallerTimesteps./input(SRT(f),1)));
             if BelowZeroBack~=0 && isempty(BelowZeroBack)==0
                 risefit(BelowZeroBack:end)=0;     %Sets anything above zero to zero if applicable to fit
             end
        end
          risefit=conv(risefit,CC);
          risefit=risefit(xvals);
          risefit=risefit/max(risefit);
          rise(:,f) = risefit(TimestepsIndex2);
     elseif URT(f) || NoDecay(f)
         if Back(f)==0
             risefit   =1-(PosTimesteps .* exp(-SmallerTimesteps./(input(f,2))));
             if BelowZero~=0 && isempty(BelowZero)==0
                 risefit(1:BelowZero)=0;     %Sets anything below zero to zero if applicable to fit
             end
         else
             risefit   =1-(NegTimesteps .* exp(SmallerTimesteps./input(f,2)));
             if BelowZeroBack~=0 && isempty(BelowZero)==0
                 risefit(BelowZeroBack:end)=0;     %Sets anything above zero to zero if applicable to fit
             end
         end
             risefit=conv(risefit,CC);
             risefit=risefit(xvals);
             risefit=risefit/max(risefit);
             rise(:,f) = risefit(TimestepsIndex2);
    else rise(:,f) = ones(length(TimestepsIndex2),1); %otherwise, just use the crosscorrelation 
    end  
    %calculate decay time curves
    if Back(f)==1
        decay(:,f) = NegTimesteps .* exp(SmallerTimesteps./input(f,1));  %calculate decay time curve (y(x) = e^-tx)
        convolution(:,f)    = conv(decay(:,f),CC);    %convolute the decay with the rise using matlab inbuilt function
        convolution(:,f)    = convolution(:,f)/max(convolution(:,f));
        if NoDecay(f)==1
            convolution(:,f)=ones(size(convolution(:,f)));  %Set to ones as no decay required 
        end
    elseif NoDecay(f)==1 
        decay(:,f) = PosTimesteps .* exp(-SmallerTimesteps./input(f,1));  %calculate decay time curve (y(x) = e^-tx)
        convolutiontemp= conv(decay(:,f),CC);    %convolute the decay with the rise using matlab inbuilt function )
        convolution(:,f)    = ones(size(convolutiontemp));    %Set to ones as no decay required 
    else
        decay(:,f) = PosTimesteps .* exp(-SmallerTimesteps./input(f,1));  %calculate decay time curve (y(x) = e^-tx)
        convolution(:,f)    = conv(decay(:,f),CC);    %convolute the decay with the rise using matlab inbuilt function )
        convolution(:,f)    = convolution(:,f)/max(convolution(:,f));
    end 
end
%Select relevant values, apply relevant rise time and normalise
decayconv=convolution(xvals,:);
rtfit=decayconv(TimestepsIndex2,:).*rise;
rtfit= bsxfun(@rdivide, rtfit, max(rtfit));

%Amplitude fit and add the diffeernt amplitudes up for a comparison output
for s = 1:slices                                %fit each slice (Peak) of the dataset
    for f = 1:fits;                                 %fit each chanel    
        convfit    = input(f,(s+2)).* rtfit(:,f);  %get rid of excess x values (so it's back to newx spacing) and apply a multiplier (2*spacing/cct used to keep base amplitude at 1)  
        convfit(isnan(convfit))=0;                 %Replaces any NAN with zeros
        Y2(:,s,f)   = convfit;                 %change the x spacing back into the original (data) x spacing
        y(:,s) = sum(Y2(:,s,:),3); %+ yofs;                %add the different chanels together
    end 
end

y=y+UserFitOffset;

% Gaussian Fit
function y = ccfit(input,xdata)
%calculate the crosscorelation curve (note 2.35482 is the conversion factor between the gaussian 'varience' and a FWHM)
% xdata = xdata/1000 - input(1); 
y = input(4)*exp(-(((xdata/1000)-input(1))./(input(2)*sqrt(2)/2.35482)).^2)+input(3); %y(x) = A * e-(x/b)^2 + c  
% b varies the width of the curve. b = 2.355?2 * d gives a gaussian with FWHM of d. 
% c gives the y offset (so the curve will vary between c and 1000A+c )



% For R-squared Plot to track the resnorm value
function s = OptPlot(x,optimValues,state)
handles= guidata(gcbo);    %load in handles as this is a function, not a callback
if optimValues.iteration == 0 %setup stuff before we start
    %plotresnorm = findobj(get(gca,'Children'),'Tag','RSquarePlot')
    plotresnorm = findobj(handles.axes4,'Tag','RSquarePlot');
    if length(plotresnorm)>1
        plotresnorm=plotresnorm(2);
    end
    Y = get(plotresnorm,'Ydata');
    if Y==0; set(plotresnorm,'Ydata',optimValues.resnorm)%get rid of 0 point at beginning of new graph
    elseif length(Y)>90 %if too long
        newY = get(plotresnorm,'Ydata'); set(plotresnorm,'Ydata',newY(end-71:end)); %only use the most recent values
    end
else
    %plotresnorm = findobj(get(gca,'Children'),'Tag','RSquarePlot')
    plotresnorm = findobj(handles.axes4,'Tag','RSquarePlot');
    if length(plotresnorm)>1
        plotresnorm=plotresnorm(2);
    end
    Y = get(plotresnorm,'Ydata');
    if length(Y)>90
        OldY=get(plotresnorm,'Ydata');
        newY = [OldY(end-71:end) optimValues.resnorm];      %add on the most recent value
    else
        newY = [get(plotresnorm,'Ydata') optimValues.resnorm];      %add on the most recent value
    end
    set(plotresnorm,'Xdata',1:length(newY),'Ydata',newY);       %add it to the plot
    %set(get(gca,'XLabel'),'String',['R-Squared = ' num2str(optimValues.resnorm,4)]);%display it below the plot
    axes(handles.axes4)
    xlabel(['R-Squared = ' num2str(optimValues.resnorm,4)])
end
s = false;










% Saves Data from the most recent fit to a text file
function SaveFit_Callback(hObject, eventdata, handles)
global PreviousTimeCon PreviousDecays CurrentFitData PreviousTimesteps SelectedFitRegions PreviousCCT PreviousUserFitOffset Y2 DetailedTimestep PresentationFitData
%File format output, top rows are fits (from collumn 2 onwards and up to 4 rows) 
%and with decay in firstcollumn and rise in second. Below are the mass limits 
%selected by the user during the fit, min and max masses in order left to right. 
%Below are collumns of fit and residual intermitently depending on the
%number of regions fitted. Collumn 1 contains solely time information with
%zeros representing the region before the data.
%Build up suggested file name using regions fitted as title
if size(handles.MaxAndMinRegionsSave,1)>1
    Filename=strcat(handles.PathName,'Fit_Data_for_Mass_Regions_');
    for i=1:length(SelectedFitRegions)
        if i==1
            Filename=strcat(Filename,'M_Q_',num2str(round(handles.MaxAndMinRegionsSave(SelectedFitRegions(i),1))),'-', num2str(round(handles.MaxAndMinRegionsSave(SelectedFitRegions(i),2))));
        elseif i==length(SelectedFitRegions)
            Filename=strcat(Filename,'_and_M_Q_',num2str(round(handles.MaxAndMinRegionsSave(SelectedFitRegions(i),1))),'-', num2str(round(handles.MaxAndMinRegionsSave(SelectedFitRegions(i),2))));
        else
            Filename=strcat(Filename,',_M_Q_',num2str(round(handles.MaxAndMinRegionsSave(SelectedFitRegions(i),1))),'-', num2str(round(handles.MaxAndMinRegionsSave(SelectedFitRegions(i),2))));
        end
    end
else
    Filename=strcat(handles.PathName,'Fit_Data_for_Mass_Region_M_Q_',num2str(round(handles.MaxAndMinRegionsSave(1,1))),'-', num2str(round(handles.MaxAndMinRegionsSave(1,2))));
end
Filename=strcat(Filename,'_',datestr(now,'ddmmyyyy_HHMMSS'));

%Open text box to select place to save data, automatically chooses where data was loaded from as start point
[file,path] = uiputfile('*.datres','Save Fit Data As',Filename);
file2=file(1:end-7);
file2=strcat(file2,'.fitdata');

%Check if they pressed cancel
if (file == 0) & (path == 0); 
    errordlg('Cancel button pressed','Error');    %display an error message
    return
end

%Find Previous Time constants and mass region values, as well as fits and residuals, then concatanate into a single matrix
TimeCon=PreviousTimeCon(find(PreviousDecays(1:8)),:);
if size(handles.MaxAndMinRegionsSave,1)>1
    for i=1:length(SelectedFitRegions) %If multiple regions, get limits for each region
        if i==1
            TimeConAndMassRegions=[TimeCon;[handles.MaxAndMinRegionsSave(SelectedFitRegions(1),1),handles.MaxAndMinRegionsSave(SelectedFitRegions(1),2)]]; %Concatanate time constants with mass regions
            DataAndResiduals=[handles.PreviousFit(:,i),handles.residual(:,i)];
            TimeConAndMassRegions2=[TimeConAndMassRegions,[zeros(size(TimeConAndMassRegions,1),size((squeeze(Y2(:,i,:))),2)-1)]];
            DeatiledFitandConstituants=[PresentationFitData(:,i),squeeze(Y2(:,i,:))];
%             TimeConAndMassRegions=[TimeCon;[handles.MaxAndMinRegionsSave(SelectedFitRegions(1),1),handles.MaxAndMinRegionsSave(SelectedFitRegions(1),2)]]; %Concatanate time constants with mass regions
%             TimeConAndMassRegions=[zeros((size(TimeConAndMassRegions,1)),1),TimeConAndMassRegions];
%             FitsAndResiduals=[handles.PreviousFit(:,i),CurrentFitData(:,i),handles.residual(:,i)];
        else
            TimeConAndMassRegions=[TimeConAndMassRegions,TimeConAndMassRegions(:,1:2)]; %repeat
            TimeConAndMassRegions(end,((2*i)-1):(2*i))=[handles.MaxAndMinRegionsSave(SelectedFitRegions(i),1),handles.MaxAndMinRegionsSave(SelectedFitRegions(i),2)]; %Put in correct mass limits for the fit below
            DataAndResiduals=[DataAndResiduals,DataAndResiduals(:,1:2)]; %repeat
            DataAndResiduals(:,((2*i)-1):(2*i))=[handles.PreviousFit(:,i),handles.residual(:,i)]; %Add in fit values for mass regions selected above
            TimeConAndMassRegions2=[TimeConAndMassRegions2,TimeConAndMassRegions(:,1:2),[zeros(size(TimeConAndMassRegions,1),size((squeeze(Y2(:,i,:))),2)-1)]];         
            TimeConAndMassRegions2(end,(((size((squeeze(Y2(:,i,:))),2)+1)*i)-(size((squeeze(Y2(:,i,:))),2)):(((size((squeeze(Y2(:,i,:))),2)+1)*i)-(size((squeeze(Y2(:,i,:))),2))+1)))=[handles.MaxAndMinRegionsSave(SelectedFitRegions(i),1),handles.MaxAndMinRegionsSave(SelectedFitRegions(i),2)];           
            DeatiledFitandConstituants=[DeatiledFitandConstituants,PresentationFitData(:,i),squeeze(Y2(:,i,:))];
%             TimeConAndMassRegions=[TimeConAndMassRegions,TimeConAndMassRegions(:,1:3)]; %repeat
%             TimeConAndMassRegions(end,((3*i)-1):(3*i))=[handles.MaxAndMinRegionsSave(SelectedFitRegions(i),1),handles.MaxAndMinRegionsSave(SelectedFitRegions(i),2)]; %Put in correct mass limits for the fit below
%             FitsAndResiduals=[FitsAndResiduals,FitsAndResiduals(:,1:3)]; %repeat
%             FitsAndResiduals(:,((3*i)-2):(3*i))=[handles.PreviousFit(:,i),CurrentFitData(:,i),handles.residual(:,i)]; %Add in fit values for mass regions selected above
        end
    end
else
    TimeConAndMassRegions=[TimeCon;[handles.MaxAndMinRegionsSave(1,1),handles.MaxAndMinRegionsSave(1,2)]]; %Concatanate time constants with mass regions
    DataAndResiduals=[handles.PreviousFit(:,1),handles.residual(:,1)];
    TimeConAndMassRegions2=[TimeConAndMassRegions,[zeros(size(TimeConAndMassRegions,1),size((squeeze(Y2(:,1,:))),2)-1)]];
    DeatiledFitandConstituants=[PresentationFitData(:,1),squeeze(Y2(:,1,:))];
%     TimeConAndMassRegions=[TimeCon;[handles.MaxAndMinRegionsSave(1,1),handles.MaxAndMinRegionsSave(1,2)]]; %Concatanate time constants with mass regions
%     TimeConAndMassRegions=[zeros((size(TimeConAndMassRegions,1)),1),TimeConAndMassRegions];
%     FitsAndResiduals=[handles.PreviousFit(:,1),CurrentFitData(:,1),handles.residual(:,1)];
end
TimeConAndMassRegions=[zeros(size(TimeConAndMassRegions,1),1),TimeConAndMassRegions]; %Added so as time information srored in zeros collumn
DataAndResiduals=[PreviousTimesteps,DataAndResiduals];
SaveData=[TimeConAndMassRegions;DataAndResiduals];
SaveData(1,1)=PreviousCCT; %Save cross-correlation from fit
SaveData(2,1)=PreviousUserFitOffset; %Save user offset from fit

TimeConAndMassRegions2=[zeros(size(TimeConAndMassRegions,1),1),TimeConAndMassRegions2]; %Added so as time information srored in zeros collumn
DeatiledFitandConstituants=[DetailedTimestep',DeatiledFitandConstituants];
SaveFitData=[TimeConAndMassRegions2;DeatiledFitandConstituants];
SaveFitData(1,1)=PreviousCCT; %Save cross-correlation from fit
SaveFitData(2,1)=PreviousUserFitOffset; %Save user offset from fit

%Save the files
fid = fopen(strcat(path,file),'wt');
for i = 1:size(SaveData,1)
    fprintf(fid,'%g\t',SaveData(i,:));
    fprintf(fid,'\n');
end
fid = fopen(strcat(path,file2),'wt');
for i = 1:size(SaveFitData,1)
    fprintf(fid,'%g\t',SaveFitData(i,:));
    fprintf(fid,'\n');
end
fclose(fid);
guidata(hObject, handles);



% --- Executes on button press in ExportPlots.
function ExportPlots_Callback(hObject, eventdata, handles)

% Construct a questdlg with three options
choice =  questdlg('What would you like to save?', ...
    'Calibration Method', ...
    'Save Graphs','Save Data','Cancel','Cancel');
% Handle response
switch choice
    case 'Save Graphs' %If the user wants to save graphs
        
        %If trying to export anything from data-step graph with nothing on it
        if get(handles.FigExportChoice,'Value')==4
            if isempty(get(handles.axes5,'Children'))==1
                errordlg('Scan-Step Graph is currently empty','Error');    %display an error message
                return
            end
        end

        %User defined plot to load up which the user can then save in various formats
        fig=figure;ax=axes;clf;
        if get(handles.FigExportChoice,'Value')==1
            new_handle=copyobj(handles.axes1,fig);
            Exp_fig_children=get(gcf,'children');
            Exp_Lines=findobj(Exp_fig_children,'type','line');
            delete(Exp_Lines);
            set(gca,'linewidth',2,'FontSize',14,'FontWeight','Bold')
            if handles.DataAlreadyCalibrated==0;
                xlabel('Time of Flight (s)','FontSize',16,'FontWeight','Bold')
            elseif handles.DataAlreadyCalibrated==1;
                xlabel('m/q','FontSize',16,'FontWeight','Bold')
            end
            ylabel('Timestep (fs)','FontSize',16,'FontWeight','Bold')
            colormap jet
            shading interp  %stops lines appearing on plot
        elseif get(handles.FigExportChoice,'Value')==2
            new_handle=copyobj(handles.axes3,fig);
            set(gca,'linewidth',2,'FontSize',14,'FontWeight','Bold')
            set(findall(gca, 'Type', 'Line'),'LineWidth',2);
            xlabel('Intensity (arb.)','FontSize',16,'FontWeight','Bold')
            ylabel('Timestep (fs)','FontSize',16,'FontWeight','Bold')
            view([90 -90])
        elseif get(handles.FigExportChoice,'Value')==3
            new_handle=copyobj(handles.axes2,fig);
            set(gca,'linewidth',2,'FontSize',14,'FontWeight','Bold')
            set(findall(gca, 'Type', 'Line'),'LineWidth',2);
            if handles.DataAlreadyCalibrated==0;
                xlabel('Time of Flight (s)','FontSize',16,'FontWeight','Bold')
            elseif handles.DataAlreadyCalibrated==1;
                xlabel('m/q','FontSize',16,'FontWeight','Bold')
            end
            ylabel('Intensity (arb.)','FontSize',16,'FontWeight','Bold')
        elseif get(handles.FigExportChoice,'Value')==4
            new_handle=copyobj(handles.axes5,fig);
            set(gca,'linewidth',2,'FontSize',14,'FontWeight','Bold')
            set(findall(gca, 'Type', 'Line'),'LineWidth',2);
            set(gca, 'XTickMode', 'Auto', 'XTickLabelMode', 'Auto', 'YTickMode', 'Auto', 'YTickLabelMode', 'Auto')
            xlabel('Data Step','FontSize',16,'FontWeight','Bold')
            ylabel('Intensity (arb.)','FontSize',16,'FontWeight','Bold')
        end
        set(gca,'ActivePositionProperty','outerposition')
        set(gca,'Units','normalized')
        set(gca,'OuterPosition',[0 0 1 1])
        set(gca,'position',[0.1300 0.1100 0.7750 0.8150])
        guidata(hObject, handles);
        
    case 'Save Data' %If the user wants to save data
       
        %Open text box to select place to save data, automatically chooses where data was loaded from as start point
        if get(handles.FigExportChoice,'Value')==1
            Filename= strcat(handles.PathName,'Main Graph');
            DataAccess=get(handles.axes1,'children')
            DataAccess=DataAccess(end);
            xdata = get(DataAccess,'XData')';
            ydata = get(DataAccess,'YData');
            if get(handles.LinLogYAxis,'value') == 1; %If in linlog y axis, alter the data to timestep values
                temp=handles.Timestep+handles.Yoffsetvalue;
                [~,J]=ismember(ydata,handles.LinLogScale);
                ydata=temp(J);
            end
            zdata = get(DataAccess,'CData');
            xdata=[0,xdata];
            SaveData=[ydata,zdata];
            SaveData=[xdata;SaveData];
        elseif get(handles.FigExportChoice,'Value')==2
            Filename = strcat(handles.PathName,'Time Graph');
            DataAccess=get(handles.axes3,'children');
            xdata = get(DataAccess,'XData')';
            ydata = get(DataAccess,'YData')';
            if get(handles.LinLogYAxis,'value') == 1; %If in linlog y axis, alter the data to timestep values
                temp=handles.Timestep+handles.Yoffsetvalue;
                [~,J]=ismember(ydata,handles.LinLogScale);
                ydata=temp(J);
            end
            SaveData=[ydata,xdata];
        elseif get(handles.FigExportChoice,'Value')==3
            Filename = strcat(handles.PathName,'Spectra Graph');
            DataAccess=get(handles.axes2,'children');
            xdata = get(DataAccess,'XData')';
            ydata = get(DataAccess,'YData')';
            SaveData=[xdata,ydata];
        elseif get(handles.FigExportChoice,'Value')==4
            Filename = strcat(handles.PathName,'Scan Step Graph');
            DataAccess=get(handles.axes5,'children');
            xdata = get(DataAccess,'XData')';
            ydata = get(DataAccess,'YData')';
            SaveData=[xdata,ydata];
        end
        Filename=strcat(Filename,'_',datestr(now,'ddmmyyyy_HHMMSS'));
        [file,path] = uiputfile(['*.txt','*.csv'],'Save Fit Data As',Filename);
        
        %Check if they pressed cancel
        if (file == 0) & (path == 0); 
            errordlg('Cancel button pressed','Error');    %display an error message
            return
        end
        csvwrite(strcat(path,file),SaveData)
        guidata(hObject, handles);
        
    case 'Cancel'
end
guidata(hObject, handles);


%Used to determine what graph to take data from for exporting graphs and data
function FigExportChoice_Callback(hObject, eventdata, handles)
guidata(hObject, handles);

function FigExportChoice_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
