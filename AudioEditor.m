function varargout = AudioEditor(varargin)
% AUDIOEDITOR MATLAB code for AudioEditor.fig
%      AUDIOEDITOR, by itself, creates a new AUDIOEDITOR or raises the existing
%      singleton*.
%
%      H = AUDIOEDITOR returns the handle to a new AUDIOEDITOR or the handle to
%      the existing singleton*.
%
%      AUDIOEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AUDIOEDITOR.M with the given input arguments.
%
%      AUDIOEDITOR('Property','Value',...) creates a new AUDIOEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AudioEditor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AudioEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AudioEditor

% Last Modified by GUIDE v2.5 01-Jan-2021 20:43:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AudioEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @AudioEditor_OutputFcn, ...
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


% --- Executes just before AudioEditor is made visible.
function AudioEditor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AudioEditor (see VARARGIN)

% Choose default command line output for AudioEditor
addpath(genpath('Audio Recorder\functions'))
addpath(genpath('functions'))
handles.Y = [];
handles.FS = 16000;
handles.NUMCHAN = 1;
handles.BPS = 8;
handles.output = hObject;
handles.window_length = 0.030;
handles.noverlap = 0.015;
handles.time_start = 0;
handles.time_end = 1;
handles.window_type = 0;
handles.pe_coeff = 0.95;
handles.max_freq = [];
handles.player = [];
handles.num_gm = 5;
handles.y_train = [];
handles.f_train_labels = [];
handles.y_test = [];
handles.f_test_labels = [];
handles.is_trained=0;
handles.wl_sr = 0.030;
handles.no_sr = 0.015;
handles.init_tm = "Left to Right";
set(handles.recordBtn,'Enable','off')
set(handles.pauserecordBtn,'Enable','off')
set(handles.stoprecordBtn,'Enable','off')
check_sr_state('off', handles)
check_state('off', handles)
check_data_availability(false, handles)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AudioEditor wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AudioEditor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in openBtn.
function openBtn_Callback(hObject, eventdata, handles)
% hObject    handle to openBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile({'*.wav'}, 'File Selector');
if filename==0
    return
end

handles.player = [];
check_state('read', handles);
check_data_availability(true, handles)

[y, fs] = audioread(fullfile(pathname, filename));
a_info = audioinfo(fullfile(pathname, filename));

handles.ORIGINAL_FS = fs; handles.FS = fs;
handles.ORIGINAL_NUMCHAN = size(y,2); handles.NUMCHAN = size(y,2);
handles.ORIGINAL_LENGTH = size(y,1)/fs; handles.LENGTH = size(y,1)/fs;
handles.ORIGINAL_BPS = a_info.BitsPerSample; 
handles.BPS = a_info.BitsPerSample;
y = y(:,1)./max(abs(y(:,1)));
handles.Y = reshape(y, [1,length(y)]);
handles.fullpathname = strcat(pathname, filename);

handles.time_start = 0;
handles.time_end = handles.LENGTH;
set(handles.time_start_txtedit, 'String', num2str(handles.time_start))
set(handles.time_end_txtedit, 'String', num2str(handles.time_end))

set_information(hObject, eventdata, handles)
display_signal(hObject, eventdata, handles)
display_spectrogram(hObject, eventdata, handles)
update_bps_box(hObject, eventdata, handles)
update_numchan_box(hObject, eventdata, handles)
update_fs_slider(hObject, eventdata, handles)
display_features_info(hObject, eventdata, handles)

set(handles.time_settings_refresh_btn,'Enable','on')
set(handles.specgram_settings_refresh_btn,'Enable','on')

guidata(hObject, handles);

% --- Executes on slider movement.
function fs_slider_Callback(hObject, eventdata, handles)
% hObject    handle to fs_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.FS = round(get(hObject,'Value'))*1000;
FS_str = strcat(num2str(handles.FS/1000), 'KHz');
set(handles.fs_txt, 'String', FS_str);
handles.player = [];
if ~isempty(handles.Y)
    handles.LENGTH = length(handles.Y)/handles.FS;
    handles.time_end = handles.LENGTH;
    set(handles.time_end_txtedit, 'String', num2str(handles.time_end));
    time_settings_refresh_btn_Callback(hObject, eventdata, handles);
    display_signal(hObject, eventdata, handles)
    display_spectrogram(hObject, eventdata, handles)
end
guidata(hObject, handles);

function set_information(hObject, eventdata, handles)
set(handles.address_box, 'String', handles.fullpathname);
set(handles.audio_duration, ...
    'String', strcat(num2str(handles.ORIGINAL_LENGTH), 's'));

function display_signal(hObject, eventdata, handles)
dt = 1/handles.FS;
t = 0:dt:(length(handles.Y)*dt)-dt;
axes(handles.audio_wave);
plot(t, handles.Y);
title('Audio Signal')
xlabel('Time (s)')
xlim([handles.time_start handles.time_end]);
guidata(hObject, handles);

function display_spectrogram(hObject, eventdata, handles)
y = handles.Y;
pe_y = PreEmphasis(y, handles.pe_coeff);
stride = handles.window_length-handles.noverlap;
[FrameMat, t] = FrameBlocking(pe_y,handles.window_length,stride,handles.FS);
wFrames = Windowing(FrameMat,handles.window_type);
[Spec, f] = GetDFTMagnitudes(wFrames, handles.FS);
axes(handles.audio_specgram);
PlotSpectrogram(Spec, t, f);
title('Spectrogram')
xlabel('Time (s)')
colorbar('off')
colormap(flipud(gray));
xlim([handles.time_start handles.time_end]);
if ~isempty(handles.max_freq)
    ylim([0 handles.max_freq]);
end
guidata(hObject, handles);

function update_fs_slider(hObject, eventdata, handles)
FS_str = strcat(num2str(handles.FS/1000), 'KHz');
set(handles.fs_txt, 'String', FS_str);
set(handles.fs_slider, 'Value', handles.FS/1000);
guidata(hObject, handles);

function update_numchan_box(hObject, eventdata, handles)
switch handles.NUMCHAN
    case 1
        set(handles.numchan1_rb, 'Value', 1);
        set(handles.numchan2_rb, 'Value', 0);
    case 2
        set(handles.numchan1_rb, 'Value', 0);
        set(handles.numchan2_rb, 'Value', 1);
    otherwise
        set(handles.numchan1_rb, 'Value', 0);
        set(handles.numchan2_rb, 'Value', 0);
end

function update_bps_box(hObject, eventdata, handles)
switch handles.BPS
    case 1
        set(handles.bps8_rb, 'Value', 1);
        set(handles.bps16_rb, 'Value', 0);
        set(handles.bps24_rb, 'Value', 0);
    case 2
        set(handles.bps8_rb, 'Value', 0);
        set(handles.bps16_rb, 'Value', 1);
        set(handles.bps24_rb, 'Value', 0);
    otherwise
        set(handles.bps8_rb, 'Value', 0);
        set(handles.bps16_rb, 'Value', 1);
        set(handles.bps24_rb, 'Value', 0);
end
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function fs_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fs_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes when selected object is changed in numchan_btn_gp.
function numchan_btn_gp_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in numchan_btn_gp 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    numchan1  = get(handles.numchan1_rb, 'Value');
    numchan2  = get(handles.numchan2_rb, 'Value');
    handles.NUMCHAN = 1*numchan1 + 2*numchan2;
catch ME
    disp(ME)
end
guidata(hObject, handles);
    

% --- Executes on button press in numchan1_rb.
function numchan1_rb_Callback(hObject, eventdata, handles)
% hObject    handle to numchan1_rb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of numchan1_rb



function window_length_txtedit_Callback(hObject, eventdata, handles)
% hObject    handle to window_length_txtedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of window_length_txtedit as text
%        str2double(get(hObject,'String')) returns contents of window_length_txtedit as a double

% --- Executes during object creation, after setting all properties.
function window_length_txtedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to window_length_txtedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function noverlap_txtedit_Callback(hObject, eventdata, handles)
% hObject    handle to noverlap_txtedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noverlap_txtedit as text
%        str2double(get(hObject,'String')) returns contents of noverlap_txtedit as a double

% --- Executes during object creation, after setting all properties.
function noverlap_txtedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noverlap_txtedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in specgram_settings_refresh_btn.
function specgram_settings_refresh_btn_Callback(hObject, eventdata, handles)
% hObject    handle to specgram_settings_refresh_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
window_length = get(handles.window_length_txtedit, 'String');
noverlap = get(handles.noverlap_txtedit,'String');
handles.window_length = str2double(window_length)/1000;
handles.noverlap = str2double(noverlap)/1000;
if handles.noverlap>=handles.window_length
    handles.noverlap = 0;
    set(handles.noverlap_txtedit,'String', num2str(handles.noverlap*1000));
end
window_type_p1 = get(handles.window_type_popup, 'Value');
handles.window_type = window_type_p1-1;
pe_corr_coef = get(handles.pre_emphasis_corr_radio_button, 'Value');
pe_manu_coef = get(handles.pre_emphasis_manual_radio_button, 'Value');
if pe_manu_coef==1
    pe_coeff = get(handles.pre_emphasis_manual_text, 'String');
    handles.pe_coeff = str2double(pe_coeff);
elseif pe_corr_coef==1
    coefs = getCORR(handles.Y);
    handles.pe_coeff = coefs(2)/coefs(1);
end
max_freq_str = get(handles.max_freq_field, 'String');
handles.max_freq = str2double(max_freq_str);
if isempty(max_freq_str)
    handles.max_freq = [];
end
display_spectrogram(hObject, eventdata, handles);
guidata(hObject, handles);

% --- Executes on button press in specgram_settings_def_btn.
function specgram_settings_def_btn_Callback(hObject, eventdata, handles)
% hObject    handle to specgram_settings_def_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.window_length_txtedit, 'String', 30);
set(handles.noverlap_txtedit,'String', 15);
handles.window_length = 0.030;
handles.noverlap = 0.015;
set(handles.window_type_popup, 'Value', 1);
handles.window_type = 0;
set(handles.pre_emphasis_corr_radio_button, 'Value', 0);
set(handles.pre_emphasis_manual_radio_button, 'Value', 1);
set(handles.pre_emphasis_manual_text, 'String', 0.95);
handles.pe_coeff = 0.95;
set(handles.max_freq_field, 'String', '');
handles.max_freq = [];
display_spectrogram(hObject, eventdata, handles);

function time_start_txtedit_Callback(hObject, eventdata, handles)
% hObject    handle to time_start_txtedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time_start_txtedit as text
%        str2double(get(hObject,'String')) returns contents of time_start_txtedit as a double


% --- Executes during object creation, after setting all properties.
function time_start_txtedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time_start_txtedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function time_end_txtedit_Callback(hObject, eventdata, handles)
% hObject    handle to time_end_txtedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time_end_txtedit as text
%        str2double(get(hObject,'String')) returns contents of time_end_txtedit as a double


% --- Executes during object creation, after setting all properties.
function time_end_txtedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time_end_txtedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in time_settings_refresh_btn.
function time_settings_refresh_btn_Callback(hObject, eventdata, handles)
% hObject    handle to time_settings_refresh_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
time_start = get(handles.time_start_txtedit, 'String');
time_end = get(handles.time_end_txtedit,'String');
handles.time_start = str2double(time_start);
handles.time_end = str2double(time_end);
if handles.time_start>=handles.time_end
    handles.time_start = handles.time_end-0.1;
    set(handles.time_start_txtedit,'String', num2str(handles.time_start));
end

display_signal(hObject, eventdata, handles);
display_spectrogram(hObject, eventdata, handles);
display_features_info(hObject, eventdata, handles);
guidata(hObject, handles);



function address_box_Callback(hObject, eventdata, handles)
% hObject    handle to address_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of address_box as text
%        str2double(get(hObject,'String')) returns contents of address_box as a double

% --- Executes during object creation, after setting all properties.
function address_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to address_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in saveBtn.
function saveBtn_Callback(hObject, eventdata, handles)
% hObject    handle to saveBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp(handles.FS)
disp(handles.BPS)
disp(handles.NUMCHAN)
handles.fullpathname = get(handles.address_box, 'String');
audiowrite(handles.fullpathname, handles.Y,...
    handles.FS, 'BitsPerSample',handles.BPS)

% --- Executes on button press in playBtn.
function playBtn_Callback(hObject, eventdata, handles)
% hObject    handle to playBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.Y)
    return;
end
if isempty(handles.player)
    handles.player = audioplayer(handles.Y, handles.FS);
end
resume(handles.player);
guidata(hObject, handles);


% --- Executes on button press in pauseBtn.
function pauseBtn_Callback(hObject, eventdata, handles)
% hObject    handle to pauseBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)\
if isempty(handles.player)
    return;
end
pause(handles.player);
guidata(hObject, handles);



% --- Executes on button press in stopBtn.
function stopBtn_Callback(hObject, eventdata, handles)
% hObject    handle to stopBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.player)
    return;
end
stop(handles.player);
handles.player = [];
guidata(hObject, handles);



% --- Executes on button press in numchan_def.
function numchan_def_Callback(hObject, eventdata, handles)
% hObject    handle to numchan_def (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.NUMCHAN = handles.ORIGINAL_NUMCHAN;
update_numchan_box(hObject, eventdata, handles);
guidata(hObject, handles);


% --- Executes on button press in sf_def.
function sf_def_Callback(hObject, eventdata, handles)
% hObject    handle to sf_def (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.FS = handles.ORIGINAL_FS;

handles.player = [];
if ~isempty(handles.Y)
    handles.LENGTH = length(handles.Y)/handles.FS;
    handles.time_end = handles.LENGTH;
    set(handles.time_end_txtedit, 'String', num2str(handles.time_end));
    time_settings_refresh_btn_Callback(hObject, eventdata, handles);
    update_fs_slider(hObject, eventdata, handles);
    display_signal(hObject, eventdata, handles)
    display_spectrogram(hObject, eventdata, handles)
end
guidata(hObject, handles);



% --- Executes when selected object is changed in bps_btn_gp.
function bps_btn_gp_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in bps_btn_gp 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    bps8  = get(handles.bps8_rb, 'Value');
    bps16  = get(handles.bps16_rb, 'Value');
    bps24  = get(handles.bps24_rb, 'Value');
    handles.BPS = 8*bps8 + 16*bps16 + 24*bps24;
catch ME
    disp(ME)
end
guidata(hObject, handles);

% --- Executes on button press in bps_def.
function bps_def_Callback(hObject, eventdata, handles)
% hObject    handle to bps_def (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.BPS = handles.ORIGINAL_BPS;
update_bps_box(hObject, eventdata, handles)
guidata(hObject, handles);


% --- Executes on button press in newBtn.
function newBtn_Callback(hObject, eventdata, handles)
% hObject    handle to newBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
check_state('write', handles);
check_data_availability(false, handles)
handles.player = [];
handles.ORIGINAL_LENGTH = '-';
handles.fullpathname = '';
set_information(hObject, eventdata, handles)
handles.recObj = audiorecorder(handles.FS, handles.BPS, handles.NUMCHAN);
clear_features_info(hObject, eventdata, handles)
guidata(hObject, handles);


% --- Executes on button press in recordBtn.
function recordBtn_Callback(hObject, eventdata, handles)
% hObject    handle to recordBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
resume(handles.recObj);


% --- Executes on button press in stoprecordBtn.
function pauserecordBtn_Callback(hObject, eventdata, handles)
% hObject    handle to stoprecordBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pause(handles.recObj);

% --- Executes on button press in pauserecordBtn.
function stoprecordBtn_Callback(hObject, eventdata, handles)
% hObject    handle to pauserecordBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    stop(handles.recObj);
    y = getaudiodata(handles.recObj);
catch ME
    return
end

check_state('read', handles);
check_data_availability(true, handles)

handles.ORIGINAL_FS = handles.FS;
handles.ORIGINAL_NUMCHAN = handles.NUMCHAN;
handles.LENGTH = size(y,1)/handles.FS;
handles.ORIGINAL_LENGTH = handles.LENGTH;
handles.fullpathname =  strcat(pwd, '\Untitled.wav');
y = y(:,1)./max(abs(y(:,1)));
handles.Y = reshape(y, [1,length(y)]);

handles.time_end = handles.LENGTH;
set(handles.time_end_txtedit, 'String', num2str(handles.time_end))

set_information(hObject, eventdata, handles)
display_signal(hObject, eventdata, handles)
display_spectrogram(hObject, eventdata, handles)
update_numchan_box(hObject, eventdata, handles)
update_fs_slider(hObject, eventdata, handles)
update_bps_box(hObject, eventdata, handles)
display_features_info(hObject, eventdata, handles)

set(handles.time_settings_refresh_btn,'Enable','on')
set(handles.specgram_settings_refresh_btn,'Enable','on')
guidata(hObject, handles);


function check_state(state, handles)
switch state
    case 'write'
        set(handles.recordBtn,'Enable','on')
        set(handles.pauserecordBtn,'Enable','on')
        set(handles.stoprecordBtn,'Enable','on')
        set(handles.playBtn,'Enable','off')
        set(handles.pauseBtn,'Enable','off')
        set(handles.stopBtn,'Enable','off')
    case 'read'
        set(handles.recordBtn,'Enable','off')
        set(handles.pauserecordBtn,'Enable','off')
        set(handles.stoprecordBtn,'Enable','off')
        set(handles.playBtn,'Enable','on')
        set(handles.pauseBtn,'Enable','on')
        set(handles.stopBtn,'Enable','on')
    otherwise
        set(handles.recordBtn,'Enable','off')
        set(handles.pauserecordBtn,'Enable','off')
        set(handles.stoprecordBtn,'Enable','off')
        set(handles.playBtn,'Enable','off')
        set(handles.pauseBtn,'Enable','off')
        set(handles.stopBtn,'Enable','off')
        axes(handles.audio_wave);
        plot([],[])
        axes(handles.audio_wave);
        plot([],[])
end


function check_data_availability(data_availability, handles)
switch data_availability
    case false
        set(handles.audio_wave,'Visible','off')
        set(handles.audio_specgram,'Visible','off')
        set(handles.sigHidder,'Visible','on')
        set(handles.specHidder,'Visible','on')
        set(handles.auxHidder,'Visible','on')
        set(handles.time_settings_refresh_btn,'Enable','off')
        set(handles.specgram_settings_refresh_btn,'Enable','off')
        set(handles.aux_plot_refresh,'Enable','off')
    case true
        set(handles.audio_wave,'Visible','on')
        set(handles.audio_specgram,'Visible','on')
        set(handles.sigHidder,'Visible','off')
        set(handles.specHidder,'Visible','off')
        set(handles.auxHidder,'Visible','off')
        set(handles.time_settings_refresh_btn,'Enable','on')
        set(handles.specgram_settings_refresh_btn,'Enable','on')
        set(handles.aux_plot_refresh,'Enable','on')
end


% --- Executes on slider movement.
function time_slider_Callback(hObject, eventdata, handles)
% hObject    handle to time_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider



% --- Executes during object creation, after setting all properties.
function time_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in time_settings_def.
function time_settings_def_Callback(hObject, eventdata, handles)
% hObject    handle to time_settings_def (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp(handles.LENGTH)
handles.time_end = handles.LENGTH;
handles.time_start = 0;
set(handles.time_end_txtedit, 'String', num2str(handles.time_end));
set(handles.time_start_txtedit, 'String', num2str(0));
time_settings_refresh_btn_Callback(hObject, eventdata, handles);
display_signal(hObject, eventdata, handles);
display_spectrogram(hObject, eventdata, handles);
guidata(hObject, handles);



function max_freq_field_Callback(hObject, eventdata, handles)
% hObject    handle to max_freq_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of max_freq_field as text
%        str2double(get(hObject,'String')) returns contents of max_freq_field as a double


% --- Executes during object creation, after setting all properties.
function max_freq_field_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max_freq_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in freq_settings_refresh.
function freq_settings_refresh_Callback(hObject, eventdata, handles)
% hObject    handle to freq_settings_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
max_freq_str = get(handles.max_freq_field, 'String');
if isempty(max_freq_str)
    return
end
handles.max_freq = str2double(max_freq_str);
display_spectrogram(hObject, eventdata, handles);


% --- Executes on selection change in window_type_popup.
function window_type_popup_Callback(hObject, eventdata, handles)
% hObject    handle to window_type_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns window_type_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from window_type_popup


% --- Executes during object creation, after setting all properties.
function window_type_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to window_type_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pre_emphasis_manual_text_Callback(hObject, eventdata, handles)
% hObject    handle to pre_emphasis_manual_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pre_emphasis_manual_text as text
%        str2double(get(hObject,'String')) returns contents of pre_emphasis_manual_text as a double


% --- Executes during object creation, after setting all properties.
function pre_emphasis_manual_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pre_emphasis_manual_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in temcbx.
function plot_specs_cbx_Callback(hObject, eventdata, handles)
% hObject    handle to temcbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
display_features_info(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of temcbx

% --- Executes on button press in temcbx.
function plot_ceps_cbx_Callback(hObject, eventdata, handles)
% hObject    handle to temcbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
display_features_info(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of temcbx

% --- Executes on button press in temcbx.
function plot_corr_cbx_Callback(hObject, eventdata, handles)
% hObject    handle to temcbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
display_features_info(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of temcbx

% --- Executes on button press in temcbx.
function plot_amdf_cbx_Callback(hObject, eventdata, handles)
% hObject    handle to temcbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
display_features_info(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of temcbx

% --- Executes on button press in aux_plot_refresh.
function aux_plot_refresh_Callback(hObject, eventdata, handles)
% hObject    handle to aux_plot_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
display_features_info(hObject, eventdata, handles)

function clear_features_info(hObject, eventdata, handles)
set(handles.energy_val, 'String','-')
set(handles.zcr_val, 'String','-')
set(handles.f1_field, 'String', '-');
set(handles.f2_field, 'String', '-');
set(handles.f3_field, 'String', '-');
cla(handles.aux_plot)

function display_features_info(hObject, eventdata, handles)
cla(handles.aux_plot)
start_index = max(1,floor(handles.time_start*handles.FS));
end_index = min(ceil(handles.time_end*handles.FS),length(handles.Y));
frame = handles.Y(start_index:end_index);
frame = Windowing(frame, 3);
energy = getEnergy(frame);
zcr = getZCR(frame);
[f_vals, f_locs, smoothed_signal]=getFORMANTS(frame, handles.FS);
set(handles.f1_field, 'String', round(f_locs(1)));
set(handles.f2_field, 'String', round(f_locs(2)));
set(handles.f3_field, 'String', round(f_locs(3)));
set(handles.energy_val, 'String',energy)
set(handles.zcr_val, 'String',zcr)
if get(handles.plot_specs_cbx, 'Value')
    [spec, f] = getSPEC(frame, handles.FS);
    axes(handles.aux_plot);
    plot(f, spec, 'magenta');
    title('DFT Magnitudes')
    xlabel('Frequency')
end
if get(handles.plot_ceps_cbx, 'Value')
    ceps = getCEPSTRAL(frame);
    axes(handles.aux_plot);
    plot(ceps, 'magenta');
    title('Cepstral Coefficients')
    xlabel('Number of Sample')
end
if get(handles.plot_corr_cbx, 'Value')
    corr = getCORR(frame);
    axes(handles.aux_plot);
    plot(corr, 'magenta');
    title('Correlation Coefficients')
    xlabel('Number of Sample')
end
if get(handles.plot_amdf_cbx, 'Value')
    amdf = getAMDF(frame);
    axes(handles.aux_plot);
    plot(amdf, 'magenta');
    title('AMDF Coefficients')
    xlabel('Number of Sample')
end
guidata(hObject, handles);


% --- Executes on selection change in formants_field.
function formants_field_Callback(hObject, eventdata, handles)
% hObject    handle to formants_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns formants_field contents as cell array
%        contents{get(hObject,'Value')} returns selected item from formants_field


% --- Executes during object creation, after setting all properties.
function formants_field_CreateFcn(hObject, eventdata, handles)
% hObject    handle to formants_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%Speech Recognition%%%%%%%%%%%%%%%%

function trainfileloc_Callback(hObject, eventdata, handles)
% hObject    handle to trainfileloc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trainfileloc as text
%        str2double(get(hObject,'String')) returns contents of trainfileloc as a double


% --- Executes during object creation, after setting all properties.
function trainfileloc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trainfileloc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function trainlabelsloc_Callback(hObject, eventdata, handles)
% hObject    handle to trainlabelsloc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trainlabelsloc as text
%        str2double(get(hObject,'String')) returns contents of trainlabelsloc as a double


% --- Executes during object creation, after setting all properties.
function trainlabelsloc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trainlabelsloc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function testfileloc_Callback(hObject, eventdata, handles)
% hObject    handle to testfileloc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of testfileloc as text
%        str2double(get(hObject,'String')) returns contents of testfileloc as a double


% --- Executes during object creation, after setting all properties.
function testfileloc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to testfileloc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function testlabelsloc_Callback(hObject, eventdata, handles)
% hObject    handle to testlabelsloc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of testlabelsloc as text
%        str2double(get(hObject,'String')) returns contents of testlabelsloc as a double


% --- Executes during object creation, after setting all properties.
function testlabelsloc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to testlabelsloc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function num_gm_edit_Callback(hObject, eventdata, handles)
% hObject    handle to num_gm_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of num_gm_edit as text
%        str2double(get(hObject,'String')) returns contents of num_gm_edit as a double
handles.num_gm = get(handles.num_gm_edit,'String');
disp(handles.num_gm);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function num_gm_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_gm_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in init_tm_popup.
function init_tm_popup_Callback(hObject, eventdata, handles)
% hObject    handle to init_tm_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns init_tm_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from init_tm_popup
init_tm_ind = get(handles.init_tm_popup,'Value');
candidates = get(hObject,'String');
handles.init_tm = string(candidates(init_tm_ind));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function init_tm_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to init_tm_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in predicted_labels_listbox.
function predicted_labels_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to predicted_labels_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns predicted_labels_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from predicted_labels_listbox
selected_elem = get(hObject,'Value');
gt = handles.test_words_label(selected_elem);
pr = handles.predicted_labels(selected_elem);
set(handles.gt_edit, 'String', gt);
set(handles.pr_edit, 'String', pr);
if pr==gt
    set(handles.is_detected, 'Value', 1)
else
    set(handles.is_detected, 'Value', 0)
end
play_test_word(hObject, eventdata, handles, selected_elem);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function predicted_labels_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to predicted_labels_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in open_train_file.
function open_train_file_Callback(hObject, eventdata, handles)
% hObject    handle to open_train_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile({'*.wav'}, 'File Selector');
if filename==0
    return
end
[y_train, fs_train] = audioread(fullfile(pathname, filename));
set(handles.trainfileloc, 'String', fullfile(pathname, filename));
handles.y_train = y_train(:,1);
handles.fs_train = fs_train;
if ~isempty(handles.f_train_labels) && ~isempty(handles.y_train)
    check_sr_state('trainable', handles)
end
guidata(hObject, handles);


% --- Executes on button press in open_train_labels.
function open_train_labels_Callback(hObject, eventdata, handles)
% hObject    handle to open_train_labels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile({'*.lab'}, 'File Selector');
if filename==0
    return
end
f = fopen(fullfile(pathname, filename));
handles.f_train_labels = textscan(f, '%f%f%c', 'Delimiter', ' ');
fclose(f);
set(handles.trainlabelsloc, 'String', fullfile(pathname, filename));
if ~isempty(handles.f_train_labels) && ~isempty(handles.y_train)
    check_sr_state('trainable', handles)
end
guidata(hObject, handles);


% --- Executes on button press in open_test_file.
function open_test_file_Callback(hObject, eventdata, handles)
% hObject    handle to open_test_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile({'*.wav'}, 'File Selector');
if filename==0
    return
end
[y_test, fs_test] = audioread(fullfile(pathname, filename));
set(handles.testfileloc, 'String', fullfile(pathname, filename));
handles.y_test = y_test(:,1);
handles.fs_test = fs_test;
if ~isempty(handles.f_train_labels) && ~isempty(handles.y_train)
    if ~isempty(handles.f_test_labels) && ~isempty(handles.y_test)
        if handles.is_trained
            check_sr_state('testable', handles)
        end
    end 
end
guidata(hObject, handles);


% --- Executes on button press in open_test_labels.
function open_test_labels_Callback(hObject, eventdata, handles)
% hObject    handle to open_test_labels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile({'*.lab'}, 'File Selector');
if filename==0
    return
end
f = fopen(fullfile(pathname, filename));
handles.f_test_labels = textscan(f, '%f%f%c', 'Delimiter', ' ');
fclose(f);
set(handles.testlabelsloc, 'String', fullfile(pathname, filename));
if ~isempty(handles.f_train_labels) && ~isempty(handles.y_train)
    if ~isempty(handles.f_test_labels) && ~isempty(handles.y_test)
        if handles.is_trained
            check_sr_state('testable', handles)
        end
    end 
end
guidata(hObject, handles);

% --- Executes on button press in train_hmms.
function train_hmms_Callback(hObject, eventdata, handles)
% hObject    handle to train_hmms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
words_start = round(handles.f_train_labels{1}*handles.fs_train)+1;
words_end = round(handles.f_train_labels{2}*handles.fs_train)+2;
words_label = handles.f_train_labels{3};

handles.coeffs_b = [];
handles.coeffs_s = [];
handles.coeffs_r = [];
handles.coeffs_x = [];
for i=1:length(words_label)
    word_sample = handles.y_train(words_start(i):words_end(i));
    word_label = words_label(i);
    win = hann(handles.wl_sr*handles.fs_train,"periodic");
    S = stft(word_sample,"Window",win,"OverlapLength",handles.no_sr*handles.fs_train,"Centered",false);
    [coeffs,delta] = mfcc(S,handles.fs_train,"LogEnergy","Ignore");
    features = cat(2, coeffs, delta);
    switch word_label
        case 'b'
            handles.coeffs_b = cat(1,handles.coeffs_b, features);
        case 's'
            handles.coeffs_s = cat(1,handles.coeffs_s, features);
        case 'r'
            handles.coeffs_r = cat(1,handles.coeffs_r, features);
        case 'x'
            handles.coeffs_x = cat(1,handles.coeffs_x, features);
    end
end
[handles.priorb, handles.transmatb, handles.mub, handles.Sigmab, handles.mixmatb] = ...
    trainMHMM(handles.coeffs_b.', 5,5, handles.init_tm);
[handles.priors, handles.transmats, handles.mus, handles.Sigmas, handles.mixmats] = ...
    trainMHMM(handles.coeffs_s.', 7,5, handles.init_tm);
[handles.priorr, handles.transmatr, handles.mur, handles.Sigmar, handles.mixmatr] = ...
    trainMHMM(handles.coeffs_r.', 7,5, handles.init_tm);
[handles.priorx, handles.transmatx, handles.mux, handles.Sigmax, handles.mixmatx] = ...
    trainMHMM(handles.coeffs_x.', 7,5, handles.init_tm);
handles.is_trained=1;
if ~isempty(handles.f_train_labels) && ~isempty(handles.y_train)
    if ~isempty(handles.f_test_labels) && ~isempty(handles.y_test)
        if handles.is_trained
            check_sr_state('testable', handles)
        end
    end 
end
guidata(hObject, handles);

% --- Executes on button press in test_hmms.
function test_hmms_Callback(hObject, eventdata, handles)
% hObject    handle to test_hmms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.test_words_start = round(handles.f_test_labels{1}*handles.fs_test)+1;
handles.test_words_end = round(handles.f_test_labels{2}*handles.fs_test)+2;
words_label = handles.f_test_labels{3};
handles.test_words_label = strings(length(words_label),1);
handles.predicted_labels = strings(length(words_label),1);
for i=1:length(handles.test_words_label)
    word_sample = handles.y_test(handles.test_words_start(i):handles.test_words_end(i));
    win = hann(handles.wl_sr*handles.fs_test,"periodic");
    S = stft(word_sample,"Window",win,"OverlapLength",handles.no_sr*handles.fs_test,"Centered",false);
    [coeffs,delta] = mfcc(S,handles.fs_test,"LogEnergy","Ignore");
    features = cat(2, coeffs, delta);
    [loglikb, ~] = ...
        mhmm_logprob(features.', handles.priorb, handles.transmatb, ...
        handles.mub, handles.Sigmab, handles.mixmatb);
    [logliks, ~] = ...
        mhmm_logprob(features.', handles.priors, handles.transmats, ...
        handles.mus, handles.Sigmas, handles.mixmats);
    [loglikr, ~] = ...
        mhmm_logprob(features.', handles.priorr, handles.transmatr, ...
        handles.mur, handles.Sigmar, handles.mixmatr);
    [loglikx, ~] = ...
        mhmm_logprob(features.', handles.priorx, handles.transmatx, ...
        handles.mux, handles.Sigmax, handles.mixmatx);
    ws = ["bAz", "baste", "roSan", "xAmuS"];
    logliks = [loglikb, logliks, loglikr, loglikx];
    [~, argmax] = max(logliks);
    handles.test_words_label(i) = label_mapper(words_label(i));
    handles.predicted_labels(i) = ws(argmax);
end
set(handles.predicted_labels_listbox, 'String', handles.predicted_labels)
guidata(hObject, handles);

function [w]=label_mapper(label)
switch label
    case 'b'
        w="bAz";
    case 's'
        w="baste";
    case 'r'
        w="roSan";
    case 'x'
        w="xAmuS";
end

function play_test_word(hObject, eventdata, handles, num_elem)
y = handles.y_test(handles.test_words_start(num_elem):handles.test_words_end(num_elem));
obj = audioplayer(y, handles.fs_test);
playblocking(obj)
guidata(hObject, handles);

function check_sr_state(sr_state, handles)
switch sr_state
    case 'off'
        set(handles.train_hmms,'Enable','off')
        set(handles.test_hmms,'Enable','off')
    case 'trainable'
        set(handles.train_hmms,'Enable','on')
        set(handles.test_hmms,'Enable','off')
    case 'testable'
        set(handles.train_hmms,'Enable','on')
        set(handles.test_hmms,'Enable','on')
end


% --- Executes on button press in is_detected.
function is_detected_Callback(hObject, eventdata, handles)
% hObject    handle to is_detected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of is_detected


% --- Executes on button press in plot_path_btn.
function plot_path_btn_Callback(hObject, eventdata, handles)
% hObject    handle to plot_path_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clf(figure(1))
selected_elem = get(handles.predicted_labels_listbox,'Value');
pr = handles.predicted_labels(selected_elem);
word_sample = handles.y_test(handles.test_words_start(selected_elem):handles.test_words_end(selected_elem));
win = hann(handles.window_length*handles.fs_test,"periodic");
S = stft(word_sample,"Window",win,"OverlapLength",handles.noverlap*handles.fs_test,"Centered",false);
[coeffs,delta] = mfcc(S,handles.fs_test,"LogEnergy","Ignore");
features = cat(2, coeffs, delta);
ks = mixgauss_prob(features.', handles.mus, handles.Sigmas, handles.mixmats);
ms = viterbi_path(handles.priors, handles.transmats, ks);
kb = mixgauss_prob(features.', handles.mub, handles.Sigmab, handles.mixmatb);
mb = viterbi_path(handles.priorb, handles.transmatb, kb);
kr = mixgauss_prob(features.', handles.mur, handles.Sigmar, handles.mixmatr);
mr = viterbi_path(handles.priorr, handles.transmatr, kr);
kx = mixgauss_prob(features.', handles.mux, handles.Sigmax, handles.mixmatx);
mx = viterbi_path(handles.priorx, handles.transmatx, kx);
len_f = size(features,1);
x = linspace(1,len_f,len_f);
dt = 1/handles.fs_test;
t = 0:dt:(length(word_sample)*dt)-dt;
figure(1)
subplot(2,1,1)
plot(t,word_sample);
subplot(2,1,2)
sb = scatter(x,mb,40,'*r');
hold on;
plot(mb, '--r')
hold on
ss = scatter(x,ms,30,'ob');
hold on;
plot(ms, '--b')
hold on
sr = scatter(x,mr,20,'hg');
hold on;
plot(mr, '--g')
hold on
sx = scatter(x,mx,10,'pm');
hold on;
plot(mx, '--m')
legend([sb, ss, sr, sx], 'bAz', 'baste', 'roSan', 'xAmuS')
hold off
guidata(hObject, handles);



function wl_sr_edit_Callback(hObject, eventdata, handles)
% hObject    handle to wl_sr_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wl_sr_edit as text
%        str2double(get(hObject,'String')) returns contents of wl_sr_edit as a double
wl_sr_str = get(hObject, 'String');
handles.wl_sr = str2double(wl_sr_str)/1000;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function wl_sr_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wl_sr_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function no_sr_edit_Callback(hObject, eventdata, handles)
% hObject    handle to no_sr_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of no_sr_edit as text
%        str2double(get(hObject,'String')) returns contents of no_sr_edit as a double
no_sr_str = get(hObject, 'String');
handles.no_sr = str2double(no_sr_str)/1000;
if handles.no_sr>=handles.wl_sr
    handles.no_sr = 0;
    set(handles.no_sr_edit,'String', num2str(handles.no_sr*1000));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function no_sr_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to no_sr_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
