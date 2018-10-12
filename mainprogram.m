function varargout = mainprogram(varargin)
% mainprogram M-file for mainprogram.fig
%      mainprogram, by itself, creates a new mainprogram or raises the existing
%      singleton*.
%
%      H = mainprogram returns the handle to a new mainprogram or the handle to
%      the existing singleton*.
%
%      mainprogram('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in mainprogram.M with the given input arguments.
%
%      mainprogram('Property','Value',...) creates a new mainprogram or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mainprogram_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mainprogram_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)". 
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright  The MathWorks, Inc.

% Edit the above text to modify the response to help mainprogram

% Last Modified by GUIDE v2.5 11-Oct-2018 11:18:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mainprogram_OpeningFcn, ...
                   'gui_OutputFcn',  @mainprogram_OutputFcn, ...
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


% --- Executes just before mainprogram is made visible.
function mainprogram_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mainprogram (see VARARGIN)

% Choose default command line output for mainprogram
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mainprogram wait for user response (see UIRESUME)
% uiwait(handles.background);


% --- Outputs from this function are returned to the command line.
function varargout = mainprogram_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function inaviname_Callback(hObject, eventdata, handles)
% hObject    handle to inaviname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inaviname as text
%        str2double(get(hObject,'String')) returns contents of inaviname as a double


% --- Executes during object creation, after setting all properties.
function inaviname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inaviname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in selectbutton.
function selectbutton_Callback(hObject, eventdata, handles)
% hObject    handle to selectbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pathname = uigetdir();
if pathname(end) ~= '/' || pathname(end) ~= '\' 
	pathname = strcat(pathname, '/');    
end
set(handles.inaviname,'String',pathname);




function inwsize_Callback(hObject, eventdata, handles)
% hObject    handle to inwsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inwsize as text
%        str2double(get(hObject,'String')) returns contents of inwsize as a double


% --- Executes during object creation, after setting all properties.
function inwsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inwsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function inssize_Callback(hObject, eventdata, handles)
% hObject    handle to inssize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inssize as text
%        str2double(get(hObject,'String')) returns contents of inssize as a double


% --- Executes during object creation, after setting all properties.
function inssize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inssize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end





% --- Executes on button press in analyze.
function analyze_Callback(hObject, eventdata, handles)
% hObject    handle to analyze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
onetest_path=get(handles.inaviname,'String');
output_midresult = get(handles.edit14,'String');
output_finalresult = get(handles.edit16,'String');

average_worm_size = str2double(get(handles.inWsize,'String'));
live_mobility_thresh = str2double(get(handles.inSsize,'String'));

if output_midresult(end) ~= '/' || output_midresult(end) ~= '\' 
	output_midresult = strcat(output_midresult, '/');    
end
if output_finalresult(end) ~= '/' || output_finalresult(end) ~= '\' 
	output_finalresult = strcat(output_finalresult, '/');    
end

ImageProcessForWellPlate( onetest_path, output_midresult, output_finalresult, live_mobility_thresh, average_worm_size ); 
guidata(hObject,handles); 



% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.inaviname,'String','');

set(handles.edit14,'String','');
set(handles.edit16,'String','');

set(handles.inWsize,'String','2000');
set(handles.inSsize,'String','0.93');



function inWsize_Callback(hObject, eventdata, handles)
% hObject    handle to inWsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inWsize as text
%        str2double(get(hObject,'String')) returns contents of inWsize as a double


% --- Executes during object creation, after setting all properties.
function inWsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inWsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function inSsize_Callback(hObject, eventdata, handles)
% hObject    handle to inSsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inSsize as text
%        str2double(get(hObject,'String')) returns contents of inSsize as a double


% --- Executes during object creation, after setting all properties.
function inSsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inSsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end






% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over selectbutton.
function selectbutton_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to selectbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on selectbutton and no controls selected.
function selectbutton_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to selectbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function selectbutton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over analyze.
function analyze_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to analyze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on analyze and no controls selected.
function analyze_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to analyze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function analyze_CreateFcn(hObject, eventdata, handles)
% hObject    handle to analyze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double


% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


