function varargout = HydRun(varargin)
% HYDRUN MATLAB code for HydRun.fig
%      HYDRUN, by itself, creates a new HYDRUN or raises the existing
%      singleton*.
%
%      H = HYDRUN returns the handle to a new HYDRUN or the handle to
%      the existing singleton*.
%
%      HYDRUN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HYDRUN.M with the given input arguments.
%
%      HYDRUN('Property','Value',...) creates a new HYDRUN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HydRun_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HydRun_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help HydRun

% Last Modified by GUIDE v2.5 08-Dec-2016 13:39:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HydRun_OpeningFcn, ...
                   'gui_OutputFcn',  @HydRun_OutputFcn, ...
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


% --- Executes just before HydRun is made visible.
function HydRun_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to HydRun (see VARARGIN)

% Choose default command line output for HydRun
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes HydRun wait for user response (see UIRESUME)
% uiwait(handles.figure1);

cpath = which('HydRun.m'); % current path
if ~isempty(cpath)
    if ispc
        cidx = strfind(cpath, '\');
    else
        cidx = strfind(cpath, '/'); 
    end 
    foldername = cpath(1:cidx(end));
    fun_folder = [foldername, 'HydRun_Functions'];
    if exist(fun_folder, 'dir') == 7, addpath(fun_folder); end
end 


% --- Outputs from this function are returned to the command line.
function varargout = HydRun_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function filepath_Callback(hObject, eventdata, handles)
% hObject    handle to filepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filepath as text
%        str2double(get(hObject,'String')) returns contents of filepath as a double


% --- Executes during object creation, after setting all properties.
function filepath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DataSummaryButton.
function DataSummaryButton_Callback(hObject, eventdata, handles)
% hObject    handle to DataSummaryButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try 
    inputFile = get(handles.filepath, 'string'); 
    load(inputFile); 
    
    startDate = get(handles.sDate, 'string'); 
    endDate = get(handles.eDate, 'string');  
    
    if ~isempty(startDate) && ~isempty(endDate)       
        startDate = datenum(str2num(startDate)); 
        endDate = datenum(str2num(endDate)); 
    else 
        % if start date and end data not set, then it gets the overlap of
        % streamflow and precip data
        startDate = max(streamflow(1, 1), precip(1, 1)); 
        endDate = min(streamflow(end, 1), precip(end, 1)); 
    end
    
    streamflow = streamflow(streamflow(:, 1) >= startDate & streamflow(:, 1) <= endDate, :); 
    precip = precip(precip(:, 1) >= startDate & precip(:, 1) <= endDate, :); 
    
    flowSD = datestr(streamflow(1, 1), 'yyyy-mmm-dd'); 
    flowED = datestr(streamflow(end, 1), 'yyyy-mmm-dd');
    flowLength = round(streamflow(end, 1) - streamflow(1, 1)); 
    flowInterval = round((streamflow(2, 1) - streamflow(1, 1)) * 24 * 60); 
    flowStat = round(quantile(streamflow(:, 2), [0, .05, 0.5, 0.95, 1])*1000)/1000; 
    flowNA = sum(isnan(streamflow(:, 2))); 


    
    summary_1 = {'Stream Flow'; ...
        ''; 
        ['Start Date:   ', flowSD];
        ['End Date:   ', flowED];
        ['Time Period:   ', num2str(flowLength), ' (day)']; 
        ['Time Step:   ', num2str(flowInterval), ' (min)']; 
        ['Minimum:   ', num2str(flowStat(1)), ' (m^3/s)']; 
        ['5-Qunatile:   ', num2str(flowStat(2)), ' (m^3/s)']; 
        ['Average:   ', num2str(flowStat(3)), ' (m^3/s)']; 
        ['95-Qunatile:   ', num2str(flowStat(4)), ' (m^3/s)']; 
        ['Maximum:   ', num2str(flowStat(5)), ' (m^3/s)']; 
        ['Number of NAs:   ', num2str(flowNA)]};
    
    set(handles.DataSummaryPannel_1, 'string', summary_1); 
    
    
    precipSD = datestr(precip(1, 1), 'yyyy-mmm-dd'); 
    precipED = datestr(precip(end, 1), 'yyyy-mmm-dd');
    precipLength = round(precip(end, 1) - precip(1, 1)); 
    precipInterval = round((precip(2, 1) - precip(1, 1)) * 24 * 60); 
    precipAvg = round(nanmean(precip(:, 2))*1000)/1000; 
    precipMax = nanmax(precip(:, 2)); 
    precipNA = sum(isnan(precip(:, 2))); 


    summary_2 = {'Precipitation'; 
        ''; 
        ['Start Date:   ', precipSD]; 
        ['End Date:   ', precipED];
        ['Time Period:   ', num2str(precipLength), ' (day)']; 
        ['Time Step:   ', num2str(precipInterval), ' (min)']; 
        '';
        '';
        ['Average:   ', num2str(precipAvg), ' (mm)']; 
        '';
        ['Maximum:   ', num2str(precipMax), ' (mm)']; 
        ['Number of NAs:   ', num2str(precipNA)]}; 
    
    set(handles.DataSummaryPannel_2, 'string', summary_2);      
    
catch ME
    
    msgbox(ME.message)
    
end 

    
function filter_Callback(hObject, eventdata, handles)
% hObject    handle to filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filter as text
%        str2double(get(hObject,'String')) returns contents of filter as a double


% --- Executes during object creation, after setting all properties.
function filter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pass_Callback(hObject, eventdata, handles)
% hObject    handle to pass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pass as text
%        str2double(get(hObject,'String')) returns contents of pass as a double


% --- Executes during object creation, after setting all properties.
function pass_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SC_Callback(hObject, eventdata, handles)
% hObject    handle to SC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SC as text
%        str2double(get(hObject,'String')) returns contents of SC as a double


% --- Executes during object creation, after setting all properties.
function SC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BSlope_Callback(hObject, eventdata, handles)
% hObject    handle to BSlope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BSlope as text
%        str2double(get(hObject,'String')) returns contents of BSlope as a double


% --- Executes during object creation, after setting all properties.
function BSlope_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BSlope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ReRa_Callback(hObject, eventdata, handles)
% hObject    handle to ReRa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ReRa as text
%        str2double(get(hObject,'String')) returns contents of ReRa as a double


% --- Executes during object creation, after setting all properties.
function ReRa_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ReRa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function minDiff_Callback(hObject, eventdata, handles)
% hObject    handle to minDiff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minDiff as text
%        str2double(get(hObject,'String')) returns contents of minDiff as a double


% --- Executes during object creation, after setting all properties.
function minDiff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minDiff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ESlope_Callback(hObject, eventdata, handles)
% hObject    handle to ESlope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ESlope as text
%        str2double(get(hObject,'String')) returns contents of ESlope as a double


% --- Executes during object creation, after setting all properties.
function ESlope_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ESlope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit23_Callback(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit23 as text
%        str2double(get(hObject,'String')) returns contents of edit23 as a double


% --- Executes during object creation, after setting all properties.
function edit23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit24_Callback(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit24 as text
%        str2double(get(hObject,'String')) returns contents of edit24 as a double


% --- Executes during object creation, after setting all properties.
function edit24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit25_Callback(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit25 as text
%        str2double(get(hObject,'String')) returns contents of edit25 as a double


% --- Executes during object creation, after setting all properties.
function edit25_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rrplotpath_Callback(hObject, eventdata, handles)
% hObject    handle to rrplotpath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rrplotpath as text
%        str2double(get(hObject,'String')) returns contents of rrplotpath as a double


% --- Executes during object creation, after setting all properties.
function rrplotpath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rrplotpath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sDate_Callback(hObject, eventdata, handles)
% hObject    handle to sDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sDate as text
%        str2double(get(hObject,'String')) returns contents of sDate as a double


% --- Executes during object creation, after setting all properties.
function sDate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eDate_Callback(hObject, eventdata, handles)
% hObject    handle to eDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eDate as text
%        str2double(get(hObject,'String')) returns contents of eDate as a double


% --- Executes during object creation, after setting all properties.
function eDate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function text21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in BaseflowSepButtom.
function BaseflowSepButtom_Callback(hObject, eventdata, handles)
% hObject    handle to BaseflowSepButtom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    inputFile = get(handles.filepath, 'string'); 
    filter = str2num(get(handles.filter, 'string')); 
    pass = str2num(get(handles.pass, 'string')); 
    
  
    load(inputFile); 
    
    startDate = get(handles.sDate, 'string'); 
    endDate = get(handles.eDate, 'string');  
    
    if ~isempty(startDate) && ~isempty(endDate)       
        startDate = datenum(str2num(startDate)); 
        endDate = datenum(str2num(endDate)); 
    else 
        % if start date and end data not set, then it gets the overlap of
        % streamflow and precip data
        startDate = max([streamflow(1, 1), precip(1, 1)]); 
        endDate = min([streamflow(end, 1), precip(end, 1)]); 
    end
    
    streamflow = streamflow(streamflow(:, 1) >= startDate & streamflow(:, 1) <= endDate, :); 
 
    
    [~, baseflow] = separatebaseflow(streamflow, filter, pass); 
    
    axes(handles.baseflow_plot)
    plot(streamflow(:, 1), streamflow(:, 2), 'linewidth', 1.2);
    hold on 
    plot(baseflow(:, 1), baseflow(:, 2), 'r', 'linewidth', 1.2)
    xlim([streamflow(1, 1), streamflow(end, 1)])
    xlabel('Time', 'FontSize', 14)
    ylabel('Discharge(m^3/s)', 'FontSize', 14)
    datetick('x', 'mmmdd', 'keeplimits')
    legend('streamflow', 'baseflow')
    hold off
    
    
catch ME
    
    h_ME = msgbox(ME.message, 'Error Message', 'error', 'modal'); 

end 
    


% --- Executes on button press in RunoffExtButtom.
function RunoffExtButtom_Callback(hObject, eventdata, handles)
% hObject    handle to RunoffExtButtom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    inputFile = get(handles.filepath, 'string'); 
    
    filter = str2num(get(handles.filter, 'string')); 
    pass = str2num(get(handles.pass, 'string')); 
    
    SC = str2num(get(handles.SC, 'string')); 
    minDiff = str2num(get(handles.minDiff, 'string')); 
    ReRa = str2num(get(handles.ReRa, 'string')); 
    BSlope = str2num(get(handles.BSlope, 'string')); 
    ESlope = str2num(get(handles.ESlope, 'string')); 
    minDur = str2num(get(handles.minDur, 'string')); 
    
    
    load(inputFile); 
    
    startDate = get(handles.sDate, 'string'); 
    endDate = get(handles.eDate, 'string');  
    
    if ~isempty(startDate) && ~isempty(endDate)       
        startDate = datenum(str2num(startDate)); 
        endDate = datenum(str2num(endDate)); 
    else 
        % if start date and end data not set, then it gets the overlap of
        % streamflow and precip data
        startDate = max(streamflow(1, 1), precip(1, 1)); 
        endDate = min(streamflow(end, 1), precip(end, 1)); 
    end
    
    streamflow = streamflow(streamflow(:, 1) >= startDate & streamflow(:, 1) <= endDate, :); 
 
    % Baseflow separation
    [stormflow, ~] = separatebaseflow(streamflow, filter, pass);
    
    % Extract runoff events from the baseflow-free hydrograph
    if ~isempty(minDur)
        [runoffEvents, nRunoffEvent] = extractrunoff(stormflow, minDiff, ReRa, BSlope, ESlope, SC, minDur); 
    else 
        [runoffEvents, nRunoffEvent] = extractrunoff(stormflow, minDiff, ReRa, BSlope, ESlope, SC);
    end 
    
    
    HY_type = get(get(handles.runoffType, 'SelectedObject'), 'Tag'); 
    
    axes(handles.runoff_plot) 
    switch HY_type
        case 'bff'
            plotrunoffevent(runoffEvents, stormflow, 0); 
        case 'sf'
            plotrunoffevent(runoffEvents, streamflow, 0); 
    end 
    xlabel('Time', 'FontSize', 14)
    ylabel('Discharge(m^3/s)', 'FontSize', 14)
    datetick('x', 'mmmdd', 'keeplimits')
    
    linkaxes([handles.baseflow_plot, handles.runoff_plot], 'xy')

catch ME
    
    h_ME = msgbox(ME.message, 'Error Message', 'error', 'modal'); 

end 
    



function minDur_Callback(hObject, eventdata, handles)
% hObject    handle to minDur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minDur as text
%        str2double(get(hObject,'String')) returns contents of minDur as a double


% --- Executes during object creation, after setting all properties.
function minDur_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minDur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when uipanel2 is resized.
function uipanel2_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to uipanel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function text31_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RRmatchButtom.
function RRmatchButtom_Callback(hObject, eventdata, handles)
% hObject    handle to RRmatchButtom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    inputFile = get(handles.filepath, 'string'); 
    
    filter = str2num(get(handles.filter, 'string')); 
    pass = str2num(get(handles.pass, 'string')); 
    
    SC = str2num(get(handles.SC, 'string')); 
    minDiff = str2num(get(handles.minDiff, 'string')); 
    ReRa = str2num(get(handles.ReRa, 'string')); 
    BSlope = str2num(get(handles.BSlope, 'string')); 
    ESlope = str2num(get(handles.ESlope, 'string')); 
    minDur = str2num(get(handles.ESlope, 'string')); 
    
    
    MRT = str2num(get(handles.MRT, 'string'));
    RR_savepath = get(handles.rrplotpath, 'string');
    
    load(inputFile); 
    
    
    % Shorten preciptation and streamflow data
    startDate = get(handles.sDate, 'string'); 
    endDate = get(handles.eDate, 'string');  
    
    if ~isempty(startDate) && ~isempty(endDate)       
        startDate = datenum(str2num(startDate)); 
        endDate = datenum(str2num(endDate)); 
    else 
        % if start date and end data not set, then it gets the overlap of
        % streamflow and precip data
        startDate = max(streamflow(1, 1), precip(1, 1)); 
        endDate = min(streamflow(end, 1), precip(end, 1)); 
    end
    
    streamflow = streamflow(streamflow(:, 1) >= startDate & streamflow(:, 1) <= endDate, :); 
 
    
    % Baseflow separation
    [stormflow, ~] = separatebaseflow(streamflow, filter, pass);
    
    
    % Extract runoff events from the baseflow-free hydrograph
    if ~isempty(minDur)
        [runoffEvents, nRunoffEvent] = extractrunoff(stormflow, minDiff, ReRa, BSlope, ESlope, SC, minDur); 
    else 
        [runoffEvents, nRunoffEvent] = extractrunoff(stormflow, minDiff, ReRa, BSlope, ESlope, SC);
    end 
   
    % Match runoff events with rainfall events
    [rainEvents, nRainEvent] = extractprecipevent(precip, 6);  
    
    [RR_Events, ~] = matchrainfallrunoff(rainEvents, runoffEvents, MRT); 

    
    for i = 1:nRunoffEvent
        fig1 = figure('visible', 'off'); 
        plotevent(RR_Events{i, 1}, RR_Events{i, 2}); 
        
        set(fig1, 'paperUnit', 'centimeters', 'paperPosition', [0, 0, 20, 13]); 
        saveas(fig1, sprintf([RR_savepath, 'Event_%d'], i), 'png');
    end
    
catch ME
    
    h_ME = msgbox(ME.message, 'Error Message', 'error', 'modal'); 

end 



function MRT_Callback(hObject, eventdata, handles)
% hObject    handle to MRT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MRT as text
%        str2double(get(hObject,'String')) returns contents of MRT as a double


% --- Executes during object creation, after setting all properties.
function MRT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MRT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function recsavepath_Callback(hObject, eventdata, handles)
% hObject    handle to recsavepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of recsavepath as text
%        str2double(get(hObject,'String')) returns contents of recsavepath as a double


% --- Executes during object creation, after setting all properties.
function recsavepath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to recsavepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nrmsethr_Callback(hObject, eventdata, handles)
% hObject    handle to nrmsethr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nrmsethr as text
%        str2double(get(hObject,'String')) returns contents of nrmsethr as a double


% --- Executes during object creation, after setting all properties.
function nrmsethr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nrmsethr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in recessionAnalysisButtom.
function recessionAnalysisButtom_Callback(hObject, eventdata, handles)
% hObject    handle to recessionAnalysisButtom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    inputFile = get(handles.filepath, 'string'); 
    
    filter = str2num(get(handles.filter, 'string')); 
    pass = str2num(get(handles.pass, 'string')); 
    
    SC = str2num(get(handles.SC, 'string')); 
    minDiff = str2num(get(handles.minDiff, 'string')); 
    ReRa = str2num(get(handles.ReRa, 'string')); 
    BSlope = str2num(get(handles.BSlope, 'string')); 
    ESlope = str2num(get(handles.ESlope, 'string')); 
    minDur = str2num(get(handles.ESlope, 'string')); 
    
    recessionFile = get(handles.recsavepath, 'string'); 
    
    
    load(inputFile); 
    
    % Shorten preciptation and streamflow data
    startDate = get(handles.sDate, 'string'); 
    endDate = get(handles.eDate, 'string');  
    
    if ~isempty(startDate) && ~isempty(endDate)       
        startDate = datenum(str2num(startDate)); 
        endDate = datenum(str2num(endDate)); 
    else 
        % if start date and end data not set, then it gets the overlap of
        % streamflow and precip data
        startDate = max([streamflow(1, 1), precip(1, 1)]); 
        endDate = min([streamflow(end, 1), precip(end, 1)]); 
    end
    
    streamflow = streamflow(streamflow(:, 1) >= startDate & streamflow(:, 1) <= endDate, :); 
 
    
    % Baseflow separation
    [stormflow, ~] = separatebaseflow(streamflow, filter, pass);
    
    
    % Extract runoff events from the baseflow-free hydrograph
    if ~isempty(minDur)
        [runoffEvents, nRunoffEvent] = extractrunoff(stormflow, minDiff, ReRa, BSlope, ESlope, SC, minDur); 
    else 
        [runoffEvents, nRunoffEvent] = extractrunoff(stormflow, minDiff, ReRa, BSlope, ESlope, SC);
    end 
    
    % Compute Recession Constant and plot recession limbs
    for i = 1:nRunoffEvent
        runoff = runoffEvents{i};
        [RC, NRMSE, recession, simulation] = computeRC(runoff); 
        x = (recession(:, 1) - recession(1, 1)) * 24;
        fig2 = figure('visible', 'off');
        plot(x, recession(:, 2), 'linewidth', 2); 
        hold on 
        grid on
        plot(x, simulation(:, 2), '--r', 'linewidth', 2); 
        xlabel('Hour', 'FontSize', 14)
        ylabel('Discharge (m^3)', 'FontSize', 14)
        title(sprintf('Event %d \nRecession Constant = %.2f (hr)     NRMSE =%.4f', i, RC, NRMSE), 'FontSize', 14, 'FontWeight', 'bold')
        legend('Observed', 'Simulated')
        hold off
        set(fig2, 'paperUnit', 'centimeters', 'paperPosition', [0, 0, 20, 13]); 
        saveas(fig2, [recessionFile, 'Recession_', num2str(i)], 'png'); 
    end 

    
catch ME
    
    h_ME = msgbox(ME.message, 'Error Message', 'error', 'modal'); 

end 



function edit33_Callback(hObject, eventdata, handles)
% hObject    handle to edit33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit33 as text
%        str2double(get(hObject,'String')) returns contents of edit33 as a double


% --- Executes during object creation, after setting all properties.
function edit33_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit34_Callback(hObject, eventdata, handles)
% hObject    handle to edit34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit34 as text
%        str2double(get(hObject,'String')) returns contents of edit34 as a double


% --- Executes during object creation, after setting all properties.
function edit34_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in allrec.
function allrec_Callback(hObject, eventdata, handles)
% hObject    handle to allrec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of allrec


% --- Executes on button press in selerec.
function selerec_Callback(hObject, eventdata, handles)
% hObject    handle to selerec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of selerec


% --- Executes on button press in MRRbuttom.
function MRRbuttom_Callback(hObject, eventdata, handles)
% hObject    handle to MRRbuttom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit39_Callback(hObject, eventdata, handles)
% hObject    handle to edit39 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit39 as text
%        str2double(get(hObject,'String')) returns contents of edit39 as a double


% --- Executes during object creation, after setting all properties.
function edit39_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit39 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chkTC.
function chkTC_Callback(hObject, eventdata, handles)
% hObject    handle to chkTC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkTC


% --- Executes on button press in chkRC.
function chkRC_Callback(hObject, eventdata, handles)
% hObject    handle to chkRC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkRC


% --- Executes on button press in chkRR.
function chkRR_Callback(hObject, eventdata, handles)
% hObject    handle to chkRR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkRR


% --- Executes on button press in chkIA.
function chkIA_Callback(hObject, eventdata, handles)
% hObject    handle to chkIA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkIA


% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox8



function edit40_Callback(hObject, eventdata, handles)
% hObject    handle to edit40 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit40 as text
%        str2double(get(hObject,'String')) returns contents of edit40 as a double


% --- Executes during object creation, after setting all properties.
function edit40_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit40 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox9.
function checkbox9_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox9


% --- Executes on button press in checkbox10.
function checkbox10_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox10


% --- Executes on button press in checkbox11.
function checkbox11_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox11


% --- Executes on button press in checkbox12.
function checkbox12_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox12


% --- Executes on button press in checkbox13.
function checkbox13_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox13



function outputTablePath_Callback(hObject, eventdata, handles)
% hObject    handle to outputTablePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outputTablePath as text
%        str2double(get(hObject,'String')) returns contents of outputTablePath as a double


% --- Executes during object creation, after setting all properties.
function outputTablePath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outputTablePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chkTC.
function checkbox14_Callback(hObject, eventdata, handles)
% hObject    handle to chkTC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkTC


% --- Executes on button press in chkRC.
function checkbox15_Callback(hObject, eventdata, handles)
% hObject    handle to chkRC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkRC


% --- Executes on button press in chkIA.
function checkbox17_Callback(hObject, eventdata, handles)
% hObject    handle to chkIA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkIA



function area_Callback(hObject, eventdata, handles)
% hObject    handle to area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of area as text
%        str2double(get(hObject,'String')) returns contents of area as a double


% --- Executes during object creation, after setting all properties.
function area_CreateFcn(hObject, eventdata, handles)
% hObject    handle to area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chkAP.
function chkAP_Callback(hObject, eventdata, handles)
% hObject    handle to chkAP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkAP



function AntTime_Callback(hObject, eventdata, handles)
% hObject    handle to AntTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AntTime as text
%        str2double(get(hObject,'String')) returns contents of AntTime as a double


% --- Executes during object creation, after setting all properties.
function AntTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AntTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in computeHydroBottom.
function computeHydroBottom_Callback(hObject, eventdata, handles)
% hObject    handle to computeHydroBottom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try 
    
    inputFile = get(handles.filepath, 'string'); 
    
    filter = str2num(get(handles.filter, 'string')); 
    pass = str2num(get(handles.pass, 'string')); 
    
    SC = str2num(get(handles.SC, 'string')); 
    minDiff = str2num(get(handles.minDiff, 'string')); 
    ReRa = str2num(get(handles.ReRa, 'string')); 
    BSlope = str2num(get(handles.BSlope, 'string')); 
    ESlope = str2num(get(handles.ESlope, 'string')); 
    minDur = str2num(get(handles.ESlope, 'string')); 
    
    MRT = str2num(get(handles.MRT, 'string'));
    
    isTC = logical(get(handles.chkTC, 'Value'));
    isRC = logical(get(handles.chkRC, 'Value'));
    isIA = logical(get(handles.chkIA, 'Value'));
    isRR = logical(get(handles.chkRR, 'Value'));
    isAP = logical(get(handles.chkAP, 'Value')); 
    drainageArea = str2num(get(handles.area, 'string')); 
    antecedentTime = str2num(get(handles.AntTime, 'string')); 
   
    outputTablePath = get(handles.outputTablePath, 'string'); 

    load(inputFile); 
    
    
    % Shorten preciptation and streamflow data
    startDate = get(handles.sDate, 'string'); 
    endDate = get(handles.eDate, 'string');  
    
    if ~isempty(startDate) && ~isempty(endDate)       
        startDate = datenum(str2num(startDate)); 
        endDate = datenum(str2num(endDate)); 
    else 
        % if start date and end data not set, then it gets the overlap of
        % streamflow and precip data
        startDate = max([streamflow(1, 1), precip(1, 1)]); 
        endDate = min([streamflow(end, 1), precip(end, 1)]); 
    end
    
    streamflow = streamflow(streamflow(:, 1) >= startDate & streamflow(:, 1) <= endDate, :); 
 
    
    % Baseflow separation
    [stormflow, ~] = separatebaseflow(streamflow, filter, pass);
    
    
    % Extract runoff events from the baseflow-free hydrograph
    if ~isempty(minDur)
        [runoffEvents, nRunoffEvent] = extractrunoff(stormflow, minDiff, ReRa, BSlope, ESlope, SC, minDur); 
    else 
        [runoffEvents, nRunoffEvent] = extractrunoff(stormflow, minDiff, ReRa, BSlope, ESlope, SC);
    end 
   
    % Match runoff events with rainfall events
    [rainEvents, nRainEvent] = extractprecipevent(precip, 2);    
    [RR_Events, ~] = matchrainfallrunoff(rainEvents, runoffEvents, MRT); 
    
     
     outputTable = table();
     
     if isTC 
         names = {'T_w', 'T_LR', 'T_r', 'T_LP', 'T_LPC', 'T_LC', 'T_b', 'T_c'};
         TC = batchprocessing(@computeTC, [1, 2], RR_Events(:, 1), RR_Events(:, 2));
         TC = cell2mat(TC);
         TC = array2table(TC, 'VariableNames', names); 
         outputTable = [outputTable, TC]; 
     end 
     
     if isRR && ~isempty(drainageArea)
         RR = batchprocessing(@computeRR, [1, 2], RR_Events(:, 1), RR_Events(:, 2), drainageArea);
         RR = table(RR, 'VariableNames', {'Runoff_Ratio'}); 
         outputTable = [outputTable, RR]; 
     end 
     
     if isRC 
         [RC, NRMSE] = batchprocessing(@computeRC, 1, RR_Events(:, 2));
         RC = table(RC, NRMSE, 'VariableNames', {'Recession_Constant', 'NRMSE'}); 
         outputTable = [outputTable, RC]; 
     end
     
     if isIA 
         IA = batchprocessing(@computeIA, [1, 2], RR_Events(:, 1), RR_Events(:, 2)); 
         IA = table(IA, 'VariableNames', {'Initial_Abstraction'}); 
         outputTable = [outputTable, IA]; 
     end
     
     if isAP && ~isempty(antecedentTime)
         AP = batchprocessing(@computeAP, 2, precip, RR_Events(:, 2), antecedentTime, MRT);
         AP = table(AP, 'VariableNames', {'Antecedent_Precip'}); 
         outputTable = [outputTable, AP]; 
     end
     
     writetable(outputTable, outputTablePath);
    
catch ME
    
    h_ME = msgbox(ME.message, 'Error Message', 'error', 'modal'); 
    ME.stack.line;

end 


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)



function edit46_Callback(hObject, eventdata, handles)
% hObject    handle to filepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filepath as text
%        str2double(get(hObject,'String')) returns contents of filepath as a double


% --- Executes during object creation, after setting all properties.
function edit46_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
