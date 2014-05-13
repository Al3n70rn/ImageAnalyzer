function varargout = addroi(varargin)
% ADDROI Application M-file for untitled.fig
%   ADDROI, by itself, creates a new ADDROI or raises the existing
%   singleton*.
%
%   H = ADDROI returns the handle to a new ADDROI or the handle to
%   the existing singleton*.
%
%   ADDROI('CALLBACK',hObject,eventData,handles,...) calls the local
%   function named CALLBACK in ADDROI.M with the given input arguments.
%
%   ADDROI('Property','Value',...) creates a new ADDROI or raises the
%   existing singleton*.  Starting from the left, property value pairs are
%   applied to the GUI before addroi_OpeningFunction gets called.  An
%   unrecognized property name or invalid value makes property application
%   stop.  All inputs are passed to addroi_OpeningFcn via varargin.
%
%   *See GUI Options - GUI allows only one instance to run (singleton).
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help untitled

% Copyright 2000-2006 The MathWorks, Inc.

% Last Modified by GUIDE v2.5 10-Aug-2012 12:29:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',          mfilename, ...
                   'gui_Singleton',     gui_Singleton, ...
                   'gui_OpeningFcn',    @addroi_OpeningFcn, ...
                   'gui_OutputFcn',     @addroi_OutputFcn, ...
                   'gui_LayoutFcn',     [], ...
                   'gui_Callback',      []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before addroi is made visible.
function addroi_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to addroi (see VARARGIN)

% Choose default command line output for addroi
handles.output = 'Yes';

% Update handles structure
guidata(hObject, handles);

% Insert custom Title and Text if specified by the user
if(nargin > 3)
    for index = 1:2:(nargin-3),
        switch lower(varargin{index})
        case 'title'
            set(hObject, 'Name', varargin{index+1});
        case 'string'
            set(handles.string, 'String', varargin{index+1});
        otherwise
            error('Invalid input arguments');
        end
    end
end

% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
FigPos=get(0,'DefaultFigurePosition');
FigWidth=215;FigHeight=88;
if isempty(gcbf)
    ScreenUnits=get(0,'Units');
    set(0,'Units','points');
    ScreenSize=get(0,'ScreenSize');
    set(0,'Units',ScreenUnits);

    FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
    FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
else
    GCBFOldUnits = get(gcbf,'Units');
    set(gcbf,'Units','points');
    GCBFPos = get(gcbf,'Position');
    set(gcbf,'Units',GCBFOldUnits);
    FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                   (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
end
FigPos(3:4)=[FigWidth FigHeight];
set(hObject, 'position', FigPos);
    
% UIWAIT makes addroi wait for user response (see UIRESUME)
uiwait(handles.addroi);

% --- Outputs from this function are returned to the command line.
function varargout = addroi_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.addroi);

% --- Executes on button press in ok_button.
function ok_button_Callback(hObject, eventdata, handles)
% hObject    handle to ok_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = get(hObject,'String');

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.addroi);

% --- Executes on button press in cancel_button.
function cancel_button_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = get(hObject,'String');

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.addroi);


% --- Executes when user attempts to close addroi.
function addroi_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to addroi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(handles.addroi, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(handles.addroi);
else
    % The GUI is no longer waiting, just close it
    delete(handles.addroi);
end


% --- Executes on key press over addroi with no controls selected.
function addroi_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to addroi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check for "enter" - do uiresume if we get it
if isequal(get(hObject,'CurrentKey'),'return')
    uiresume(handles.addroi);
end    



function edit_roiName_Callback(hObject, eventdata, handles)
% hObject    handle to edit_roiName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_roiName as text
%        str2double(get(hObject,'String')) returns contents of edit_roiName as a double


% --- Executes during object creation, after setting all properties.
function edit_roiName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_roiName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in roi_shape.
function roi_shape_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in roi_shape
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'roi_rect'
        handles.drawType = 'rectangular';
    case 'roi_elli'
        handles.drawType = 'ellipse';
    otherwise
end

handles.output = hObject;
guidata(hObject, handles);
