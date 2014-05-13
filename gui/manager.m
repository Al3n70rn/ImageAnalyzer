function varargout = manager(varargin)
% MANAGER MATLAB code for manager.fig
%      MANAGER, by itself, creates a new MANAGER or raises the existing
%      singleton*.
%
%      H = MANAGER returns the handle to a new MANAGER or the handle to
%      the existing singleton*.
%
%      MANAGER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MANAGER.M with the given input arguments.
%
%      MANAGER('Property','Value',...) creates a new MANAGER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before manager_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to manager_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help manager

% Last Modified by GUIDE v2.5 28-Aug-2012 12:09:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @manager_OpeningFcn, ...
    'gui_OutputFcn',  @manager_OutputFcn, ...
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


% --- Executes just before manager is made visible.
function manager_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to manager (see VARARGIN)

% Default string for edit_patientName.
handles.defaultImageSeriesText = 'Enter name for Image Series';

% Saving the input Study object handle and setting the GUI name.
studyInput = find(strcmp(varargin, 'study'));
if ~isempty(studyInput)
    handles.study = varargin{studyInput+1};
    set(gcf, 'Name', strcat(['Study: ', handles.study.name]) );
else
    warndlg('No Study input found.', 'Manager GUI Input Error', 'modal');
    uiwait(gcf);
end

% If the default text for image series name has been given, Load Image
% Series menu item is enabled.
if ~strcmp(get(handles.edit_patientName, 'String'), handles.defaultImageSeriesText )
    handles.imageSeriesName = handles.edit_patientName;
    set(handles.menu_loadImageSeries, 'Enable', 'On');
else
    set(handles.menu_loadImageSeries, 'Enable', 'Off');
end

% If the Study contains previously saved Image Series, they are added
% to the Manager Patient Popupmenu.
if handles.study.imageSeriesId > 0
    hPatientsPopup = get(handles.popupmenu_patients);
    
    for i = 1:size(handles.study.imageSeriesList,2)
        hPatientsPopup.String = char(hPatientsPopup.String,...
            handles.study.imageSeriesList{i}.name);
        set(handles.popupmenu_patients, 'String', hPatientsPopup.String);
        set(handles.popupmenu_patients, 'Value', i + 1);
    end
    
    set(handles.popupmenu_patients, 'Value', handles.study.imageSeriesId + 1 );
    
    % ImageAnalyzerStudy is updated to appdata.
    setappdata(0, 'ImageAnalyzerStudy', handles.study);
    
    % Visualization GUI of the latest ImageSeries is called by using the
    % 'View' pushbutton callback function.
    pushbutton_view_Callback(hObject, eventdata, handles)
    handles = guidata(hObject);
    
else
    % If no Image Series can be found, the Manager pushbuttons are
    % disabled.
    set(handles.pushbutton_view, 'Enable', 'off');
    set(handles.pushbutton_delete, 'Enable', 'off');
end

% Updating the static text boxes of Manager GUI according to input data
% (image slice details & ROI details).
update_static_texts(hObject, eventdata, handles);
handles = guidata(hObject);

% Getting the menubar handles from appdata and enabling Menubar item
% 'View'.
menubar_handles = getappdata(0, 'menubar_handles');
set(menubar_handles.menu_view_study, 'Checked', 'on');
set(menubar_handles.menu_view_study, 'Enable', 'on');

% Saving Manager GUI text handles to appdata for other GUIs to use.
manager_text_handles = struct('text_ROIVolume', handles.text_ROIVolume, ...
    'edit_pixelHeight', handles.edit_pixelHeight, 'edit_pixelWidth', ...
    handles.edit_pixelWidth, 'edit_sliceThickness', handles.edit_sliceThickness, ...
    'text_numberOfSlices', handles.text_numberOfSlices, ...
    'text_numberOfROIs', handles.text_numberOfROIs);

setappdata(0, 'manager_handles', manager_text_handles);

handles.output = hObject;
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = manager_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu_patients.
function popupmenu_patients_Callback(hObject, eventdata, handles)

% Loading the latest ImageAnalyzerStudy from appdata.
handles.study = getappdata(0, 'ImageAnalyzerStudy');

% Getting the object value of the popupmenu which represents the ordinal of
% the selected patient.
value = get(hObject, 'Value');

% Value '1' represents the 'All patients' selection.
if value == 1
    
    % Manager GUI pushbuttons are disabled.
    set(handles.pushbutton_view, 'Enable', 'off');
    set(handles.pushbutton_delete, 'Enable', 'off');
    
else
    % In case a patient saved by the user is selected, the Manager GUI
    % pushbuttons are enabled.
    set(handles.pushbutton_view, 'Enable', 'on');
    set(handles.pushbutton_delete, 'Enable', 'on');
    
    popupmenuCell = get(hObject, 'String');
    nameLength = length(handles.study.imageSeriesList{handles.study.imageSeriesId}.name);
    
    % If the current visualization does not match with the patient name in
    % the popupmenu and the imageSeriesList item, the image series
    % corresponding the selected patient is visualized.
    if ~strcmp(handles.study.imageSeriesList{handles.study.imageSeriesId}.name, ...
            popupmenuCell(value,1:nameLength))
        
        handles.study.imageSeriesId = value-1;
        handles.imageSeriesName = handles.study.imageSeriesList{ ...
            handles.study.imageSeriesId}.name;
        
        setappdata(0, 'ImageAnalyzerStudy', handles.study);
        
        pushbutton_view_Callback(hObject, eventdata, handles)
        handles = guidata(hObject);
    end
    
    % ImageSeriesId is updated to equal one less than the popupmenu ordinal
    % due to the 'All patients' selection, which takes the first value.
    handles.study.imageSeriesId = value-1;
    handles.imageSeriesName = handles.study.imageSeriesList{ ...
        handles.study.imageSeriesId}.name;
    
end

update_static_texts(hObject, eventdata, handles);
handles = guidata(hObject);

setappdata(0, 'ImageAnalyzerStudy', handles.study);

handles.output = hObject;
guidata(hObject, handles);


% --- Executes during GUI creation, after setting all properties.
function popupmenu_patients_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_patients (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject,'String','All patients')

handles.output = hObject;
guidata(hObject, handles);


% --- Executes on button press in pushbutton_view.
function pushbutton_view_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% If Visualization GUI exists, it is deleted.
if ishandle(getappdata(0,'hVisualization'))
    delete(getappdata(0,'hVisualization'));
end

% Loading the latest ImageAnalyzerStudy.
ImageAnalyzerStudy = getappdata(0, 'ImageAnalyzerStudy');

% ImageSeriesId of the study must be greater than 0 in order to
% successfully call the Visualization.
if ImageAnalyzerStudy.imageSeriesId > 0
    setappdata(0, 'hVisualization', visualization('study', ImageAnalyzerStudy));
else
    warndlg('Image Series ID mismatch', 'Image Series ID error', 'modal')
    uiwait(gcf)
end

handles.output = hObject;
guidata(hObject, handles);


% --- Executes on button press in pushbutton_delete.
function pushbutton_delete_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Deleting all Image Series at once is disabled!

% Prompt user for confirmation of the deletion.
modaldlgTitle = 'Confirm Image Series deleting';
modaldlgString = ['Delete Image Series "', handles.imageSeriesName '"', ...
    ' with ', get(handles.text_numberOfROIs, 'String'), ' ROI(s)?'];

user_response = modaldlg('Title', modaldlgTitle, 'String', modaldlgString);
switch lower(user_response)
    case 'no'
        return
    case 'yes'
        
        % Checking if the study contains image series.
        if ~isempty(handles.study.imageSeriesList)
            
            % Deleting the selected patient string from the popupmenu.
            str = get(handles.popupmenu_patients, 'String');
            value = get(handles.popupmenu_patients, 'Value');
            c = cellstr(str);
            c(value) = [];
            
            currentImage = cellstr(str);
            hVisualization = getappdata(0, 'hVisualization');
            
            if ishandle(hVisualization)
                
                % If the selected image series of the selected patient is
                % visualized, the visualization GUI is deleted and menubar
                % items are updated accordingly.
                if strcmp(currentImage{value}, get(hVisualization,'Name'))
                    delete(getappdata(0, 'hVisualization'));
                    
                    menubar_handles = getappdata(0, 'menubar_handles');
                    set(menubar_handles.menu_view_visualization, 'Enable','off');
                    set(menubar_handles.menu_view_visualization, 'Checked','off');
                end
            end
            
            % Delete the ImageSeries (.is) files after checking that they
            % exist.
            fileStr = strcat(handles.study.pathName,'\',handles.imageSeriesName, ...
                '\', handles.imageSeriesName,'.is');
            if exist(fileStr, 'file')
                delete(fileStr);
            end
            
            % Deleting all the ROI (.roi) files from the folder but not the
            % folder itself after checking that the folder exists.
            folderStr = strcat(handles.study.pathName,'\', ...
                handles.study.imageSeriesList{handles.study.imageSeriesId}.name,'\','ROIs');
            
            if exist(folderStr, 'dir') == 7
                delete(strcat(folderStr,'\','*.roi'))
            end
            
            % Deleting the image series from the study itself and
            % decreasing the imageSeriesId value by one.
            handles.study.imageSeriesList(value - 1) = [];
            handles.study.imageSeriesId = length(c) - 1;
            
            set(handles.popupmenu_patients, 'Value', length(c) );
            set(handles.popupmenu_patients, 'String', char(c));
        end
        
        setappdata(0, 'ImageAnalyzerStudy', handles.study);
        
        % If no image series exist, Manager GUI pushbuttons are disabled.
        if isempty(handles.study.imageSeriesList)
            set(handles.pushbutton_view, 'Enable', 'off');
            set(handles.pushbutton_delete, 'Enable', 'off');
        else
            % If one or more image series do exist, the one before the
            % deleted image series is visualized.
            handles.imageSeriesName = handles.study.imageSeriesList{ ...
                handles.study.imageSeriesId}.name;  
            pushbutton_view_Callback(hObject, eventdata, handles)
            handles = guidata(hObject);
        end
        
end

update_static_texts(hObject, eventdata, handles)
setappdata(0, 'ImageAnalyzerStudy', handles.study);

handles.output = hObject;
guidata(hObject, handles);


% --- Executes on patient name editing.
function edit_patientName_Callback(hObject, eventdata, handles)
% hObject    handle to edit_patientName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% If the patient name string has been altered, loading image series menu
% item is enabled and image series name is updated.
if ~strcmp(get(hObject,'String'), handles.defaultImageSeriesText )
    handles.imageSeriesName = get(hObject,'String');
    set(handles.menu_loadImageSeries, 'Enable', 'On');
end

handles.output = hObject;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_patientName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_patientName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%set(hObject, 'String', handles.defaultImageSeriesText);

handles.output = hObject;
guidata(hObject, handles);


% --- Executes on menu item Load Image Series.
function menu_loadImageSeries_Callback(hObject, eventdata, handles)
% hObject    handle to menu_loadImageSeries (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Load the latest ImageAnalyzerStudy, if a study has been created earlier.
if ~isempty(getappdata(0, 'ImageAnalyzerStudy'))
    handles.study = getappdata(0, 'ImageAnalyzerStudy');
end

% Prompt user for the set of images.
[fileName, pathName] = uigetfile( {'*.jpg', 'JPG Files (*.jpg)'; ...
    '*.png', 'PNG Files (*.png)'; '*.bmp', 'BMP Files (*.bmp)'; ...
    '*.dcm', 'DICOM Files (*.dcm)'}, ...
    'Load image series', 'MultiSelect', 'on');


if ~isequal(fileName,0) 
    
    filesCell = cellstr(fileName);
    
    % At least two images have to be selected.
    if length(filesCell) > 1
        
        fileStr = char(fileName(1));
        if strcmp(fileStr(end-3:end),'.dcm')
            test = dicomread(char(strcat(pathName,fileName(1))));
        else
            test = imread(char(strcat(pathName,fileName(1))));
        end
        
        h = size(test,1);
        w = size(test,2);
        d = size(fileName,2);
        
        
        stack = uint16(zeros(h,w,d));
        
        hwb = waitbar(0, 'Importing Images, please wait...');
        for j = 1:d
            fileStr = char(fileName(j));
            if size(test,3) > 1
                if strcmp(fileStr(end-3:end),'.dcm')
                    stack(:,:,j) = rgb2gray(dicomread(char(strcat(pathName,fileName(j)))));
                else
                    stack(:,:,j) = rgb2gray(imread(char(strcat(pathName,fileName(j)))));
                end
            else
                if strcmp(fileStr(end-3:end),'.dcm')
                    stack(:,:,j) = dicomread(char(strcat(pathName,fileName(j))));
                else
                    stack(:,:,j) = imread(char(strcat(pathName,fileName(j))));
                end
            end
            waitbar(j/d,hwb);
        end
        close(hwb);
        
        % Constructing imageSeries -class object and saving the acquired
        % imageSeries to handles.
        handles.study.imageSeriesList{end+1} = imageSeries(stack);
        handles.study.imageSeriesList{end}.name = handles.imageSeriesName;
        
        hPatientsPopup = get(handles.popupmenu_patients);
        hPatientsPopup.String = char(hPatientsPopup.String,handles.imageSeriesName);
        set(handles.popupmenu_patients,'String', hPatientsPopup.String);
        
        handles.study.imageSeriesId = size(handles.study.imageSeriesList,2);
        
        if ~isempty(handles.study.imageSeriesList)
            set(handles.pushbutton_view, 'Enable', 'On');
        end
        
        set(handles.edit_patientName, 'String', handles.defaultImageSeriesText);
        set(handles.menu_loadImageSeries, 'Enable', 'Off');
        
        set(handles.popupmenu_patients, 'Value', handles.study.imageSeriesId + 1);
        set(handles.pushbutton_view, 'Enable', 'on');
        set(handles.pushbutton_delete, 'Enable', 'on');
        
        % Updating Study and enabling saving
        menubar_handles = getappdata(0, 'menubar_handles');
        set(menubar_handles.menu_file_save, 'Enable', 'On');
        
        setappdata(0, 'ImageAnalyzerStudy', handles.study);
        
        pushbutton_view_Callback(hObject, eventdata, handles)
        handles = guidata(hObject);
        
        update_static_texts(hObject, eventdata, handles)
    else
        warndlg('Minimum of 2 images is required', 'ImageSeries error', 'modal')
        uiwait(gcf)
        menu_loadImageSeries_Callback(hObject, eventdata, handles);
    end
end

handles.output = hObject;
guidata(hObject, handles);


% --- Executes on startup and on occasions where the patient data is either
% --- edited or deleted.
function update_static_texts(hObject, eventdata, handles)

popupmenuValue = get(handles.popupmenu_patients, 'Value');

if popupmenuValue > 1 && ~isempty(handles.study.imageSeriesList)
    
    % Updating the number of slices text box.
    set(handles.text_numberOfSlices, 'String', ...
        num2str(handles.study.imageSeriesList{popupmenuValue-1}.numberOfSlices));
    
    % Updating the resolution text box.
    resolutionStr = [num2str(handles.study.imageSeriesList{popupmenuValue-1}.width), ...
        ' x ', num2str(handles.study.imageSeriesList{popupmenuValue-1}.height)];
    set(handles.text_imageResolution, 'String', resolutionStr);
    
    % Updating the number of ROIs text box.
    numberOfROIsStr = num2str(length(handles.study.imageSeriesList{ ...
        handles.study.imageSeriesId}.roiList));
    set(handles.text_numberOfROIs, 'String', numberOfROIsStr);
else
    set(handles.text_numberOfROIs, 'String', '0')
    set(handles.text_imageResolution, 'String', '0')
    set(handles.text_numberOfSlices, 'String', '0')
end

handles.output = hObject;
guidata(hObject, handles);


% --- Executes when user attempts to close manager.
function manager_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to manager (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Closing the Study Manager window only hides it.
menubar_handles = getappdata(0, 'menubar_handles');
if ~isempty(menubar_handles)
    set(menubar_handles.menu_view_study,'Checked','off');
    set(getappdata(0,'hManager'),'Visible','off');
else
   delete(hObject)
end


% --- Executes on editing the slice thickness text box.
function edit_sliceThickness_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sliceThickness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(getappdata(0, 'ImageAnalyzerStudy'))
    handles.study = getappdata(0, 'ImageAnalyzerStudy');
    
    newSliceThickness = str2double(get(hObject, 'String'));
    
    % Check of invalid inputs.
    if ~isempty(strfind(get(hObject, 'String'),',')) || ...
            isnan(newSliceThickness) || newSliceThickness < 0.1
        warndlg('Invalid slice thickness (use only positive numbers and decimal point)', ...
            'ImageSeries error', 'modal');
        uiwait(gcf);
        return;
    end
    
    handles.study.imageSeriesList{handles.study.imageSeriesId}. ...
        sliceThickness = newSliceThickness;
    
    hVisualization = getappdata(0, 'hVisualization');
    visualization_axes = getappdata(0, 'visualization_axes');
    
    % Adjusting the aspect ratio of visualization images.
    if ishandle( hVisualization )
        daspect(visualization_axes{1}, [1 newSliceThickness 1]);
        daspect(visualization_axes{2}, [1 newSliceThickness 1]);
    end
    
    % Save new slice thickness value.
    set(hObject, 'Value', newSliceThickness);
    handles.study.imageSeriesList{handles.study.imageSeriesId}. ...
        sliceThickness = newSliceThickness;
    
    updateROIVolume(hObject, eventdata, handles)
    handles = guidata(hObject);
    
    setappdata(0, 'ImageAnalyzerStudy', handles.study);
    setappdata(0, 'manager_handles', manager_text_handles);
end

handles.output = hObject;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_sliceThickness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sliceThickness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on editing the pixel width text box.
function edit_pixelWidth_Callback(hObject, eventdata, handles)
% hObject    handle to edit_pixelWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(getappdata(0, 'ImageAnalyzerStudy'))
    handles.study = getappdata(0, 'ImageAnalyzerStudy');
    
    newPixelWidth = str2double(get(hObject, 'String'));
    
    % Check of invalid inputs.
    if ~isempty(strfind(get(hObject, 'String'),',')) || ...
            isnan(newPixelWidth) || newPixelWidth < 0
        warndlg('Invalid pixel width (use only positive numbers and decimal point)', ...
            'ImageSeries error', 'modal');
        uiwait(gcf);
        return;
    end
    
    % Save new pixel height value.
    set(hObject, 'Value', newPixelWidth);
    handles.study.imageSeriesList{handles.study.imageSeriesId}. ...
        pixelWidth = newPixelWidth;
    
    updateROIVolume(hObject, eventdata, handles)
    handles = guidata(hObject);

    setappdata(0, 'ImageAnalyzerStudy', handles.study);
    setappdata(0, 'manager_handles', manager_text_handles);
end


% --- Executes during object creation, after setting all properties.
function edit_pixelWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_pixelWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on editing the pixel height text box.
function edit_pixelHeight_Callback(hObject, eventdata, handles)
% hObject    handle to edit_pixelHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(getappdata(0, 'ImageAnalyzerStudy'))
    handles.study = getappdata(0, 'ImageAnalyzerStudy');
    
    newPixelHeight = str2double(get(hObject, 'String'));
    
    % Check of invalid inputs.
    if ~isempty(strfind(get(hObject, 'String'),',')) || ...
            isnan(newPixelHeight) || newPixelHeight < 0
        warndlg('Invalid pixel width (use only positive numbers and decimal point)', ...
            'ImageSeries error', 'modal');
        uiwait(gcf);
        return;
    end
    
    % Save new pixel height value.
    set(hObject, 'Value', newPixelHeight);
    handles.study.imageSeriesList{handles.study.imageSeriesId}. ...
        pixelHeight = newPixelHeight;
    
    updateROIVolume(hObject, eventdata, handles)
    handles = guidata(hObject);
    
    setappdata(0, 'ImageAnalyzerStudy', handles.study);
    setappdata(0, 'manager_handles', manager_text_handles);
end


% --- Executes during object creation, after setting all properties.
function edit_pixelHeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_pixelHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on editing the region of interest dimensions.
function updateROIVolume(hObject, eventdata, handles)

if ~isempty(getappdata(0,'currentROI'))
    currentROI = getappdata(0, 'currentROI');

    % x = the right image x-coordinates
    xMin = currentROI.roiCoordinates(1,1,3);
    xMax = currentROI.roiCoordinates(3,1,3);
    
    % y = the right image y-coordinates
    yMin = currentROI.roiCoordinates(1,2,3);
    yMax = currentROI.roiCoordinates(3,2,3);
    
    % z = the center image x-coordinates
    zMin = currentROI.roiCoordinates(1,1,2);
    zMax = currentROI.roiCoordinates(3,1,2);
      
    width = get(handles.edit_pixelWidth, 'Value');
    height = get(handles.edit_pixelHeight, 'Value');
    thickness = get(handles.edit_sliceThickness, 'Value');
    
    roiVolume = round((xMax-xMin)*width*(yMax-yMin)*height*(zMax-zMin)* ...
        thickness);
    
    set(handles.text_ROIVolume, 'String', num2str(roiVolume));

end

handles.output = hObject;
guidata(hObject, handles);
