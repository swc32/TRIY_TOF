function varargout = Callibration(varargin)
% CALLIBRATION MATLAB code for Callibration.fig
%      CALLIBRATION, by itself, creates a new CALLIBRATION or raises the existing
%      singleton*.
%
%      H = CALLIBRATION returns the handle to a new CALLIBRATION or the handle to
%      the existing singleton*.
%
%      CALLIBRATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CALLIBRATION.M with the given input arguments.
%
%      CALLIBRATION('Property','Value',...) creates a new CALLIBRATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Callibration_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Callibration_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Callibration

% Last Modified by GUIDE v2.5 03-Feb-2017 15:52:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Callibration_OpeningFcn, ...
                   'gui_OutputFcn',  @Callibration_OutputFcn, ...
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


% --- Executes just before Callibration is made visible.
function Callibration_OpeningFcn(hObject, eventdata, handles, varargin)
global Cal ExportData
%Load up data passed from TOFANALYSE2
handles.TData=cell2mat(varargin(1));
handles.FullZData=sum(cell2mat(varargin(2)));
handles.PathName=num2str(cell2mat(varargin(3)));

%Plot Initial Data
DataPlot=plot(handles.axes1,handles.TData,handles.FullZData);
xlim([min(handles.TData) max(handles.TData)]);
xlabel('Time of Flight (s)')
ylabel('Relative Inetensity (arb.)')

%Enable data cursor on the axes upon opening
datacursormode on;
dcm_obj = datacursormode(gcf);
set(dcm_obj, 'enable','on');
 
% Create a new data tip
DataPlotHandle = handle(DataPlot);
DatatipHandle = dcm_obj.createDatatip(DataPlotHandle);
% Create a copy of the context menu for the datatip:
%set(DatatipHandle,'UIContextMenu',get(dcm_obj,'UIContextMenu'));
set(DatatipHandle,'HandleVisibility','off');
set(DatatipHandle,'Host',DataPlotHandle);
%set(DatatipHandle,'DisplayStyle','datatip');
 
% Set the data-tip orientation to top-right rather than auto
set(DatatipHandle,'OrientationMode','manual');
set(DatatipHandle,'Orientation','topright');
 
% Update the datatip marker appearance
set(DatatipHandle, 'MarkerSize',5, 'MarkerFaceColor','none', ...
              'MarkerEdgeColor','k', 'Marker','o', 'HitTest','off');
 
% Move the datatip to the top of the highest peak
%PositionStart = [handles.TData(find(handles.FullZData==max(handles.FullZData))),handles.FullZData(find(handles.FullZData==max(handles.FullZData))),1; handles.TData(find(handles.FullZData==max(handles.FullZData))),handles.FullZData(find(handles.FullZData==max(handles.FullZData))),-1];
DatatipHandle.Cursor.Position = [handles.TData(find(handles.FullZData==max(handles.FullZData))),handles.FullZData(find(handles.FullZData==max(handles.FullZData)))];
%update(DatatipHandle, PositionStart);



%Update settings to maximum and minimum of data input
set(handles.LeftDataCursorTextDisplay,'string',num2str(handles.TData(1)));
set(handles.RightDataCursorTextDisplay,'string',num2str(handles.TData(end)));
handles.LeftPeakX=handles.TData(1);
handles.RightPeakX=handles.TData(end);

%Save a handle to specify no calibration has yet taken place and has not been exported and disable export calibration until a calibration is made
handles.CalRecal=0;
Cal=[0,0];
ExportData=0;
set(handles.Export,'enable','off');

%Sets initial values of mass peaks on opening
handles.LMQ=0;
handles.RMQ=50;

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Callibration wait for user response (see UIRESUME)
 uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Callibration_OutputFcn(hObject, eventdata, handles)  
global Cal ExportData
%varargout{1} = handles.output;
varargout{1} = Cal;
%varargout{2} = handles.Cal;
varargout{2} = ExportData;



%Sets value for left mass peak
function LeftMQ_Callback(hObject, eventdata, handles)
LMQ=str2num(get(handles.LeftMQ,'string'));

if isempty(LMQ)==1 %Checks if input was a number
    errordlg('Input must be a number equal to or greater than zero','Error');    %display an error message
    set(handles.LeftMQ,'string',num2str(handles.LMQ));
    return 
elseif LMQ >= handles.RMQ %Checks to see number is not greater than right mass peak
    errordlg('Left peak cannot be after right peak','Error');    %display an error message
    set(handles.LeftMQ,'string',num2str(handles.LMQ));
    return
elseif LMQ<0 %Checks to see number is not less than zero
    errordlg('Value must be a number and be zero or greater','Error');    %display an error message
    set(handles.LeftMQ,'string',num2str(handles.LMQ));
    return
else
    handles.LMQ=LMQ;
end

guidata(hObject, handles);  
    


% --- Executes during object creation, after setting all properties.
function LeftMQ_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%Set value for right mass peak
function RightMQ_Callback(hObject, eventdata, handles)
RMQ=str2num(get(handles.RightMQ,'string'));

if isempty(RMQ)==1 %Checks if input was a number
    errordlg('Input must be a number equal to or greater than zero','Error');    %display an error message
    set(handles.RightMQ,'string',num2str(handles.RMQ));
    return    
elseif RMQ <= handles.LMQ %Checks to see number is not less than left mass peak
    errordlg('Right peak cannot be before left peak','Error');    %display an error message
    set(handles.RightMQ,'string',num2str(handles.RMQ));
    return
elseif RMQ<0 %Checks to see number is not less than zero
    errordlg('Input must be a number equal to or greater than zero','Error');    %display an error message
    set(handles.RightMQ,'string',num2str(handles.RMQ));
    return
else
    handles.RMQ=RMQ;
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function RightMQ_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%Gets the Cursor Position
function LeftDataCursor_Callback(hObject, eventdata, handles)
dcm_obj = datacursormode(gcf);
c_info = getCursorInfo(dcm_obj);
X=c_info.Position(1);
if X>=handles.RightPeakX
    errordlg('Left cursor point cannot be after right cursor point','Error');    %display an error message
    return
else
    handles.LeftPeakX=X;
    set(handles.LeftDataCursorTextDisplay,'string',num2str(handles.LeftPeakX));
end

guidata(hObject, handles);

% --- Executes on button press in RightDataCursor.
function RightDataCursor_Callback(hObject, eventdata, handles)
dcm_obj = datacursormode(gcf);
c_info = getCursorInfo(dcm_obj);
X=c_info.Position(1);
if X<=handles.LeftPeakX
    errordlg('Right cursor point cannot be before left cursor point','Error');    %display an error message
    return
else
    handles.RightPeakX=X;
    set(handles.RightDataCursorTextDisplay,'string',num2str(handles.RightPeakX));
end

guidata(hObject, handles);


%Calibrates and Plots the data
function Calibrate_Callback(hObject, eventdata, handles)
global Cal
DisableArray=[handles.LeftDataCursor,handles.RightDataCursor,handles.LeftMQ,handles.RightMQ];
if handles.CalRecal==0;    
    %Create an array of values needed for ease of tracking
    CalibrationArray=[str2num(get(handles.LeftDataCursorTextDisplay,'string')),str2num(get(handles.RightDataCursorTextDisplay,'string'));str2num(get(handles.LeftMQ,'string')),str2num(get(handles.RightMQ,'string'))];
    
    %Find Calibration Constants
    Cal(1)=(CalibrationArray(1,2)-CalibrationArray(1,1))/((sqrt(CalibrationArray(2,2)))-(sqrt(CalibrationArray(2,1))));
    Cal(2)=CalibrationArray(1,1)-(Cal(1)*(sqrt(CalibrationArray(2,1))));
    
    %Calibrate Data
    MQ = (((handles.TData-Cal(2))./Cal(1)).^2);
    
    %Shows index of first element equal to or greater than zero then resizes data
    MQZeroCutoff=find(MQ==min(MQ),1,'last');
    MQCal=MQ(MQZeroCutoff:end);
    ZData=handles.FullZData(MQZeroCutoff:end);
    
    %Plot Calibration Data
    DataPlot=plot(handles.axes1,MQCal,ZData);
    xlim([min(MQCal) max(MQCal)]);
    xlabel('M/Q')
    ylabel('Relative Inetensity (arb.)')
    
    % Create a new data tip
    dcm_obj = datacursormode(gcf);
    set(dcm_obj, 'enable','on');
    DataPlotHandle = handle(DataPlot);
    DatatipHandle = dcm_obj.createDatatip(DataPlotHandle);

    % Create a copy of the context menu for the datatip:
    set(DatatipHandle,'UIContextMenu',get(dcm_obj,'UIContextMenu'));
    set(DatatipHandle,'HandleVisibility','off');
    set(DatatipHandle,'Host',DataPlotHandle);
    %set(DatatipHandle,'DisplayStyle','datatip');

    % Set the data-tip orientation to top-right rather than auto
    set(DatatipHandle,'OrientationMode','manual');
    set(DatatipHandle,'Orientation','topright');

    % Update the datatip marker appearance
    set(DatatipHandle, 'MarkerSize',5, 'MarkerFaceColor','none', ...
                  'MarkerEdgeColor','k', 'Marker','o', 'HitTest','off');

    % Move the datatip to the top of the highest peak
    %PositionStart = [MQCal(find(ZData==max(ZData))),ZData(find(ZData==max(ZData))),1; MQCal(find(ZData==max(ZData))),ZData(find(ZData==max(ZData))),-1];
    DatatipHandle.Cursor.Position = [MQCal(find(ZData==max(ZData))),ZData(find(ZData==max(ZData)))];
    %update(DatatipHandle, PositionStart);
    
    zoom(gcf,'reset'); %Updates the zoom capabilities to the new axis limits
    
    set(DisableArray,'enable','off');  %Disables parts of the array to prevent user messing up code
    set(handles.Export,'enable','on'); %Allows access to export calibration function button
    
    handles.Cal=Cal; %Saves current calibration constants
    handles.CalRecal=1; %Staes for cade that data is now calibrated
else
    
    %Replot Time Data
    DataPlot=plot(handles.axes1,handles.TData,handles.FullZData);
    xlim([min(handles.TData) max(handles.TData)]);
    xlabel('Time of Flight (s)')
    ylabel('Relative Inetensity (arb.)')
    
    % Create a new data tip
    dcm_obj = datacursormode(gcf);
    set(dcm_obj, 'enable','on');
    DataPlotHandle = handle(DataPlot);
    DatatipHandle = dcm_obj.createDatatip(DataPlotHandle);

    % Create a copy of the context menu for the datatip:
    set(DatatipHandle,'UIContextMenu',get(dcm_obj,'UIContextMenu'));
    set(DatatipHandle,'HandleVisibility','off');
    set(DatatipHandle,'Host',DataPlotHandle);
    %set(DatatipHandle,'DisplayStyle','datatip');

    % Set the data-tip orientation to top-right rather than auto
    set(DatatipHandle,'OrientationMode','manual');
    set(DatatipHandle,'Orientation','topright');

    % Update the datatip marker appearance
    set(DatatipHandle, 'MarkerSize',5, 'MarkerFaceColor','none', ...
                  'MarkerEdgeColor','k', 'Marker','o', 'HitTest','off');

    % Move the datatip to the top of the highest peak
    %PositionStart = [handles.TData(find(handles.FullZData==max(handles.FullZData))),handles.FullZData(find(handles.FullZData==max(handles.FullZData))),1; handles.TData(find(handles.FullZData==max(handles.FullZData))),handles.FullZData(find(handles.FullZData==max(handles.FullZData))),-1];
    DatatipHandle.Cursor.Position = [handles.TData(find(handles.FullZData==max(handles.FullZData))),handles.FullZData(find(handles.FullZData==max(handles.FullZData)))];
    %update(DatatipHandle, PositionStart);
    
    zoom(gcf,'reset') %Updates the zoom capabilities to the new axis limits
    
    set(DisableArray,'enable','on');
    handles.CalRecal=0; %States for code calibration off
    
end

guidata(hObject, handles);


% --- Executes on button press in Export.
function Export_Callback(hObject, eventdata, handles)
global Cal ExportData

%Find where to save the taf_calib file
Filename = strcat(handles.PathName,'\tof_calib.cal');
[file,path] = uiputfile('*.cal','Save Fit Data As',Filename);

%Check if they pressed cancel
if path == 0 
    errordlg('Cancel button pressed','Error');    %display an error message
    return
end

if exist(strcat(path,file)) == 2 %If file already exists, ask to overwrite
    % Construct a questdlg with three options
    choice = questdlg('File already exists. Overwrite?', ...
	'Overwrite calibration file', ...
	'Yes','No','Yes');
    switch choice
        case 'Yes'
            delete(strcat(path,file))
            guidata(hObject, handles);
        case 'No'
            errordlg('Cancel button pressed','Error');    %display an error message
            return
    end
end

%Save file
fid = fopen(strcat(path,file),'wt');
fprintf(fid,'%d\n',Cal);
fclose(fid);

ExportData=1;

guidata(hObject, handles);
close(handles.figure1)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)

delete(hObject);
