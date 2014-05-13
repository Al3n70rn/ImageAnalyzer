function varargout = ImageAnalyzer(varargin)
% ImageAnalyzer software
%      IMAGEANALYZER,
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ImageAnalyzer

% Last Modified by GUIDE v2.5 10-Sep-2012 10:06:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ImageAnalyzer_OpeningFcn, ...
    'gui_OutputFcn',  @ImageAnalyzer_OutputFcn, ...
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


% --- Executes just before ImageAnalyzer is made visible.
function ImageAnalyzer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ImageAnalyzer (see VARARGIN)

% Including the path of GUI and Class -files
addpath gui classes

% CloseRequestFcn of ImageAnalyzer will check this value in order to
% perform proper cleanup and closing manouvers. 
handles.closeImageAnalyzer = true;

% Saving the ImageAnalyser Menubar handles to appdata for other GUIs.
setappdata(0, 'menubar_handles', handles);

% Choose default command line output for ImageAnalyzer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = ImageAnalyzer_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function menu_file_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_fe_Callback(hObject, eventdata, handles)
% hObject    handle to menu_fe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_class_Callback(hObject, eventdata, handles)
% hObject    handle to menu_class (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_result_Callback(hObject, eventdata, handles)
% hObject    handle to menu_result (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_view_Callback(hObject, eventdata, handles)
% hObject    handle to menu_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_view_study_Callback(hObject, eventdata, handles)
% hObject    handle to menu_view_study (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Manager GUI visibility can be toggled 'on' and 'off' from menubar item
% View.
if strcmp(get(handles.menu_view_study,'Checked'),'on')
    set(handles.menu_view_study,'Checked','off');
    set(getappdata(0,'hManager'),'Visible','off');
else
    set(handles.menu_view_study,'Checked','on');
    set(getappdata(0,'hManager'),'Visible','on');
end

handles.output = hObject;
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_view_visualization_Callback(hObject, eventdata, handles)
% hObject    handle to menu_view_visualization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Visualization GUI visibility can be toggled 'on' and 'off' from
% menubar item View.
if strcmp(get(handles.menu_view_visualization,'Checked'),'on')
    set(handles.menu_view_visualization,'Checked','off')
    set(getappdata(0, 'hVisualization'),'Visible','off');
else
    set(handles.menu_view_visualization,'Checked','on')
    set(getappdata(0, 'hVisualization'),'Visible','on')
end

handles.output = hObject;
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_view_3DROIs_Callback(hObject, eventdata, handles)
% hObject    handle to menu_view_3DROIs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 3D ROIs figure visibility can be toggled 'on' and 'off' from
% menubar item View.
if strcmp(get(handles.menu_view_3DROIs,'Checked'),'on')
    set(handles.menu_view_3DROIs,'Checked','off')
    set(getappdata(0, 'h3DROIs'),'Visible','off');
else
    set(handles.menu_view_3DROIs,'Checked','on')
    set(getappdata(0, 'h3DROIs'),'Visible','on')
end

handles.output = hObject;
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_file_new_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Calling menubar_CloseRequestFcn without closing the Menubar itself.
handles.closeImageAnalyzer = false;
menubar_CloseRequestFcn(hObject, eventdata, handles);
handles.closeImageAnalyzer = true;

% Prompting the user for new ImageAnalyzer study path.
[fileName, pathName] = uiputfile({'*.sty;', ...
    'Image Analyzer workspace file (*.sty)'}, 'Create new study');

if (fileName~=0)
    
    handles.study = study(fileName);
    
    name = fileName(1:end-4);
    handles.study.pathName = strcat(pathName,name);
    
    % Calling and saving manager GUI.
    setappdata(0, 'hManager', manager('study', handles.study));
    
    % Setting View-menu item checked and enabling saving and closing of the
    % Study.
    set(handles.menu_view_study, 'Checked', 'on')
    set(handles.menu_file_save, 'Enable', 'on');
    set(handles.menu_file_close, 'Enable', 'on');
    
    handles.output = hObject;
    guidata(hObject, handles);
end

handles.output = hObject;
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_file_load_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Calling menubar_CloseRequestFcn without closing the Menubar itself.
handles.closeImageAnalyzer = false;
menubar_CloseRequestFcn(hObject, eventdata, handles);
handles.closeImageAnalyzer = true;

% Prompting the user for previously saved ImageAnalyzer study file.
[fileName, pathName] = uigetfile({'*.sty;',...
    'Image Analyzer workspace file (*.sty)'},'Load Study');

if fileName~=0
    
    hwb = waitbar(0,'Loading Study, please wait...');
    
    % Loading the .mat -file and saving the study to handles structure.
    h = load(strcat(pathName,fileName),'-mat');
    handles.study = h.ImageAnalyzerStudy;
    handles.study.pathName = h.ImageAnalyzerStudy.pathName;
    
    % Loading all the image series included in the study.
    for i=1:length(h.ImageAnalyzerStudy.imageSeriesList)
        
        str = ['Loading ImageSeries ', num2str(i), '/', ...
            num2str(length(h.ImageAnalyzerStudy.imageSeriesList)),' ...'];
        waitbar(i/length(h.ImageAnalyzerStudy.imageSeriesList),hwb,str);
        
        % Saving the image series file path and name to handles.
        handles.imageSeriesPath = strcat(handles.study.pathName);
        handles.imageSeriesName = h.ImageAnalyzerStudy.imageSeriesList{i};
        
        % Checking if the folders named after the image series exist.
        if exist(strcat(handles.imageSeriesPath,'\', ...
                handles.imageSeriesName), 'dir')
            
            % Saving the image series to a local variable before saving it
            % to the handles structure.
            h.ImageAnalyzerStudy.imageSeriesList{i} = ...
                load(strcat(handles.imageSeriesPath,'\', ...
                handles.imageSeriesName, '\', ...
                handles.imageSeriesName,'.is'),'-mat');
            
            handles.study.imageSeriesList{i} = ...
                h.ImageAnalyzerStudy.imageSeriesList{i}.ImageSeries;
        end
        
    end
    
    close(hwb);
    
    % Update ImageAnalyzerStudy to appdata.
    setappdata(0, 'ImageAnalyzerStudy', handles.study);
    
    % Call GUI Manager with Study object as a parameter
    setappdata(0, 'hManager', manager('study', handles.study));
    
    % Enable View-menu item and Study saving and closing
    set(handles.menu_view_study,'Checked','on');
    set(handles.menu_file_save, 'Enable', 'on');
    set(handles.menu_file_close, 'Enable', 'on');
end

handles.output = hObject;
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_file_save_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ImageAnalyzerStudy = getappdata(0,'ImageAnalyzerStudy');

% Saving the acquired image set by creating new folder for patient
% and using the filename for newImageSeries.
hwb = waitbar(0,'Saving Study, please wait...');

images = length(ImageAnalyzerStudy.imageSeriesList);
for i=1:images
    
    strSaveImageSeries = ['Saving ImageSeries ', num2str(i), '/', ...
        num2str(images),' ...'];
    waitbar(i/images,hwb,strSaveImageSeries);
    ImageSeries = ImageAnalyzerStudy.imageSeriesList{i};
    
    if ~exist(handles.study.pathName, 'dir')
        mkdir(handles.study.pathName);
    end
    
    if ~exist(strcat(handles.study.pathName,'\',ImageSeries.name), 'dir')
        mkdir(handles.study.pathName,ImageSeries.name);
    end
    
    save(strcat(handles.study.pathName,'\',ImageSeries.name,'\',...
        ImageSeries.name,'.is'),'ImageSeries','-mat');
    
    ROIs = length(ImageAnalyzerStudy.imageSeriesList{i}.roiList);
    
    if ROIs > 0
        % Saving ROI to new folder and file
        if ~exist(strcat(handles.study.pathName,'\',ImageSeries.name, ...
                '\','ROIs'), 'dir')
            mkdir(strcat(handles.study.pathName,'\',ImageSeries.name), ...
                'ROIs');
        end
        
        for j = 1:ROIs
            
            strSaveROI = ['Saving ROIs ', num2str(j), '/', ...
                num2str(ROIs),' ...'];
            waitbar(j/ROIs,hwb,strSaveROI);
            
            roiObject = ImageAnalyzerStudy.imageSeriesList{i}.roiList{j};
            save(strcat(handles.study.pathName,'\',ImageSeries.name, ...
                '\', 'ROIs', '\', roiObject.roiName,'.roi'), ...
                'roiObject', '-mat');
            
        end
    end
    % TEMP: Deleting ImageSeries so that they won't be saved in study?
    ImageAnalyzerStudy.imageSeriesList{i} = ImageSeries.name;
end

save(strcat(ImageAnalyzerStudy.pathName, '\', ...
    ImageAnalyzerStudy.fileName), 'ImageAnalyzerStudy','-mat');

close(hwb);


% --------------------------------------------------------------------
function menu_file_close_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Calling menubar_CloseRequestFcn without closing the Menubar itself.
handles.closeImageAnalyzer = false;
menubar_CloseRequestFcn(hObject, eventdata, handles);
handles.closeImageAnalyzer = true;

handles.output = hObject;
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_file_exit_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(gcf);


% --------------------------------------------------------------------
function menu_help_about_Callback(hObject, eventdata, handles)
% hObject    handle to menu_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

about_text{1} = 'Master of Science project by Jukka Varjo';
about_text{2} = 'jukka.varjo@tut.fi';
about_text{3} = '';
about_text{4} = 'Department of Biomedical Engineering';
about_text{5} = 'Tampere University of Technology';
about_text{6} = 'October 2012';
msgbox(about_text, 'About' , 'help', 'modal');


% --------------------------------------------------------------------
function menu_fe_select_Callback(hObject, eventdata, handles)
% hObject    handle to menu_fe_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%set(handles.menu_view_visualization,'Checked','off')
%set(getappdata(0, 'hVisualization'),'Visible','off');
setappdata(0, 'hFeatures', features());

% --------------------------------------------------------------------
function menu_fe_save_Callback(hObject, eventdata, handles)
% hObject    handle to menu_fe_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_fe_load_Callback(hObject, eventdata, handles)
% hObject    handle to menu_fe_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_help_Callback(hObject, eventdata, handles)
% hObject    handle to menu_help_about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when user attempts to exit ImageAnalyzer, create new
% --- study, load existing study or close current study.
function menubar_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to manager (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Study Manager GUI handle has to be available in order to continue
% clearing the appdata.
if ishandle(getappdata(0, 'hManager'))
    
    modaldlgTitle = 'Saving Study';
    modaldlgString = 'Save changes?';
    
    % Prompt user for saving the changes made in current study.
    user_response = modaldlg('Title', modaldlgTitle, 'String', ...
        modaldlgString);
    
    switch lower(user_response)
        case 'no'
        case 'yes'
            menu_file_save_Callback(hObject, eventdata, handles);
    end
    
    app = getappdata(0);
    appdatas = fieldnames(app);
    myappdatas = {'ImageAnalyzerStudy'; 'manager_handles'; ...
        'hManager'; 'hVisualization'; 'visualization_axes'; ...
        'currentROI'; 'hFeatures'; 'h3DROIs'};
    
    for i = 1:length(appdatas)
        for j = 1:length(myappdatas)
            
            % Deleting handle structures and removing appdata only if
            % the appdata was created by ImageAnalyzer.
            if strcmp(appdatas{i},myappdatas{j})
                
                if ishandle(getappdata(0,appdatas{i}))
                    delete(getappdata(0,appdatas{i}));
                end
                
                rmappdata(0,appdatas{i});
            end
        end
    end
    
end

% Menubar is deleted only when not Loading, Creating New Study or
% Closing Study.
if handles.closeImageAnalyzer
    rmappdata(0, 'menubar_handles');
    delete(hObject);
else
    % Otherwise the Menubar is kept and menu items are disabled
    % accordingly.
    set(handles.menu_view_visualization,'Checked','off', 'Enable', 'off');
    set(handles.menu_view_study,'Checked', 'off', 'Enable', 'off');
    set(handles.menu_view_3DROIs, 'Checked', 'off', 'Enable', 'off');
    set(handles.menu_file_save, 'Enable', 'off');
    set(handles.menu_file_close, 'Enable', 'off');
end
