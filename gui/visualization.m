function varargout = visualization(varargin)
% VISUALIZATION MATLAB code for visualization.fig
%      VISUALIZATION, by itself, creates a new VISUALIZATION or raises the
%      existing singleton*.
%
%      H = VISUALIZATION returns the handle to a new VISUALIZATION or the
%      handle to the existing singleton*.
%
%      VISUALIZATION('CALLBACK',hObject,eventData,handles,...) calls the
%      local function named CALLBACK in VISUALIZATION.M with the given
%      input arguments.
%
%      VISUALIZATION('Property','Value',...) creates a new VISUALIZATION or
%      raises the existing singleton*.  Starting from the left, property
%      value pairs are applied to the GUI before visualization_OpeningFcn
%      gets called.  An unrecognized property name or invalid value makes
%      property application stop.  All inputs are passed to
%      visualization_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help visualization

% Last Modified by GUIDE v2.5 18-May-2014 10:35:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @visualization_OpeningFcn, ...
    'gui_OutputFcn',  @visualization_OutputFcn, ...
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


% --- Executes just before visualization is made visible.
function visualization_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to visualization (see VARARGIN)

% Checking that the Study input has been received.
visualizationInput = find(strcmp(varargin, 'study'));

if ~isempty(visualizationInput)
    handles.study = varargin{visualizationInput+1};
    set(gcf, 'Name', strcat(['ImageSeries: ', handles.study.imageSeriesList{ ...
        handles.study.imageSeriesId}.name ]));
else
    return;
end

axis image
axis ij
axis off

% Initialising the variables related specifically to the Visualization GUI.

% Access to the ROI in progress is also required in many functions.
handles.currentROI = [];

% A flag representing the drawing process of ROI.
handles.activeROI = false;

% A flag representing the process of copying a single ROI.
handles.copyROI = false;

% A flag representing the ROI editing process.
handles.editInProgress = false;

% A flag representing the ROI importing process.
handles.importInProgress = false;

% The popupmenu ID number of the selected ROI.
handles.roiListId = 0;

% This ROI ID is incremented by one each time a new ROI is drawn. Deleting
% ROIs will not affect the ROI ID. This ROI ID is the default name for new
% ROIs.
handles.ROI_Id = 0;

% The default ROI drawing type.
handles.drawType = 'rectangular';

% The default ROI name.
handles.defaultROIname = 'Enter ROI name';

% The number of ROIs in current study.
handles.numberOfROIs = length(handles.study.imageSeriesList{ ...
    handles.study.imageSeriesId}.roiList);

% Saving the image set details to handles.
currentImage = handles.study.imageSeriesList{handles.study.imageSeriesId};
handles.width = currentImage.width;
handles.height = currentImage.height;
handles.slices = currentImage.numberOfSlices;
handles.sliceThickness = currentImage.sliceThickness;

% The image slice sliders are adjusted to match the image set data.
set(handles.slider_center, 'Max', handles.width)
set(handles.slider_center, 'SliderStep',[1 16]./handles.width)
set(handles.slider_left, 'Max', handles.height)
set(handles.slider_left, 'SliderStep',[1 16]./handles.height)
set(handles.slider_right, 'Max', handles.slices)
set(handles.slider_right, 'SliderStep',[1 16]./handles.slices)

% The slider positions are tracked and updated in order to resume positions from
% previous editing session.
sliderPositions = currentImage.sliderPositions;
set(handles.slider_left, 'Min', 1, 'Value', sliderPositions(1));
set(handles.slider_center, 'Min', 1, 'Value', sliderPositions(2));
set(handles.slider_right, 'Min', 1, 'Value', sliderPositions(3));
set(handles.leftSliderText, 'String', num2str(sliderPositions(1)));
set(handles.centerSliderText, 'String', num2str(sliderPositions(2)));
set(handles.rightSliderText, 'String', num2str(sliderPositions(3)));

% Displaying three 2D planes of image the set.
handles.leftImage = imagesc(squeeze(handles.study.imageSeriesList{ ...
    handles.study.imageSeriesId}.stack(round(sliderPositions(1)),:,:)), ...
    'Parent', handles.axes_left);
colormap(gray);
daspect(handles.axes_left, [1 handles.sliceThickness 1]);
axis off;

handles.centerImage = imagesc(squeeze(handles.study.imageSeriesList{ ...
    handles.study.imageSeriesId}.stack(:,round(sliderPositions(2)),:)), ...
    'Parent', handles.axes_center);
colormap(gray);
daspect(handles.axes_center, [1 handles.sliceThickness 1]);
axis off;

handles.rightImage = imagesc(squeeze(handles.study.imageSeriesList{ ...
    handles.study.imageSeriesId}.stack(:,:,round(sliderPositions(3)))), ...
    'Parent', handles.axes_right);
colormap(gray);
axis off;

% Updating the corresponding Menubar items.
menubar_handles = getappdata(0, 'menubar_handles');
set(menubar_handles.menu_view_visualization, 'Checked', 'on', ...
    'Enable', 'on');

% If no ROIs exist the ROI editing buttons are disabled.
if handles.numberOfROIs == 0
    set(menubar_handles.menu_fe, 'Enable', 'off');
    set(handles.edit_roi, 'Enable', 'off');
    set(handles.delete_roi, 'Enable', 'off');
    set(handles.save_roi, 'Enable', 'off');
    set(handles.roi_visibility, 'Enable', 'off');
    set(handles.copy_roi, 'Enable', 'off');
    set(handles.edit_roiName, 'Enable', 'off');
    manager_handles = getappdata(0, 'manager_handles');
    set(manager_handles.text_ROIVolume, 'String', 0);
else
    % If ROIs do exist, the Visualization GUI is updated accordingly.
    set(handles.save_roi, 'Enable', 'off');
    set(menubar_handles.menu_fe, 'Enable', 'on');
    set(menubar_handles.menu_view_3DROIs, 'Checked', 'off', ...
        'Enable', 'on');
    
    % The ROIs are added and drawn one by one.
    for i = 1:handles.numberOfROIs
        handles.ROI_Id = round(str2double(handles.study.imageSeriesList{ ...
            handles.study.imageSeriesId}.roiList{i}.roiName));
        handles.numberOfROIs = i;
        handles.roiListId = i;
        handles.currentROI = handles.study.imageSeriesList{ ...
            handles.study.imageSeriesId}.roiList{i};
        
        drawROIs(hObject, eventdata, handles);
        handles = guidata(hObject);
        updateROIVolume(hObject, eventdata, handles);
        
        if handles.currentROI.roiVisibility
            set(handles.roi_visibility, 'Value', true);
        else
            set(handles.roi_visibility, 'Value', false);
        end
    end
    
    % The ROI color is updated.
    RGB = handles.currentROI.roiColor;
    set(handles.roiSliderRed, 'Value', RGB(1));
    set(handles.roiSliderGreen, 'Value', RGB(2));
    set(handles.roiSliderBlue, 'Value', RGB(3));
    set(handles.textColor, 'BackgroundColor', RGB);
    set(handles.roiSliderAlpha, 'Value', handles.currentROI.roiAlpha)
    
    % Each axes evaluates which ROIs should be visible at current slider
    % positions.
    set(gcf, 'CurrentAxes', handles.axes_left);
    checkROIVisibilities(hObject, eventdata, handles);
    handles = guidata(hObject);
    
    set(gcf, 'CurrentAxes', handles.axes_center);
    checkROIVisibilities(hObject, eventdata, handles);
    handles = guidata(hObject);
    
    set(gcf, 'CurrentAxes', handles.axes_right);
    checkROIVisibilities(hObject, eventdata, handles);
    handles = guidata(hObject);
    
end

Red     = get(handles.roiSliderRed,    'Value');
Green   = get(handles.roiSliderGreen,  'Value');
Blue    = get(handles.roiSliderBlue,   'Value');

set(handles.textColor, 'BackgroundColor', [Red Green Blue]);

set(handles.axes_left, 'visible', 'off');
set(handles.axes_center, 'visible', 'off');
set(handles.axes_right, 'visible', 'off');

axes_right_ButtonDownFcn(hObject, eventdata, handles);

setappdata(0, 'visualization_axes', {handles.axes_left, ...
    handles.axes_center} );

handles.output = hObject;
guidata(hObject, handles);


% --- Executes with GUI Visualization and save_roi_Callback.
function drawROIs(hObject, eventdata, handles)

roiColor = handles.currentROI.roiColor;
roiAlpha = handles.currentROI.roiAlpha;

imageAxes = {handles.axes_left, handles.axes_center, handles.axes_right};

for i = 1:length(imageAxes)
    
    set(gcf, 'CurrentAxes', imageAxes{i})
    hold on
    
    handles.currentROI.roiPatchHandles{i} = ...
        fill(handles.currentROI.roiCoordinates(:,1,i), ...
        handles.currentROI.roiCoordinates(:,2,i), roiColor, 'Parent', ...
        imageAxes{i});
    set(handles.currentROI.roiPatchHandles{i}, 'FaceAlpha', roiAlpha)
end


% If 'Edit ROI' button was not pressed, add new item to popupmenu_rois.
% Else, replace selected ROI with currentROI in roiList and reset ROI_Id
% to match the latest ROI name.
if ~handles.editInProgress
    handles.study.imageSeriesList{handles.study.imageSeriesId}. ...
        roiList{handles.roiListId} = handles.currentROI;
    
    hRoiPopup = get(handles.popupmenu_rois);
    hRoiPopup.String = char(hRoiPopup.String, handles.currentROI.roiText);
    
    set(handles.popupmenu_rois, 'String', hRoiPopup.String);
    set(handles.popupmenu_rois, 'Value', handles.roiListId + 1);
    set(handles.edit_roiName, 'String', handles.currentROI.roiText);
else
    handles.study.imageSeriesList{handles.study.imageSeriesId}. ...
        roiList{handles.roiListId} = handles.currentROI;
    
    handles.ROI_Id = str2double(handles.study.imageSeriesList{ ...
        handles.study.imageSeriesId}.roiList{end}.roiName);
end

% Enable and set roi_visibility radio button values according to
% currentROI's roiVisibility parameter. If the the value is set to false
% the roiPatchHandle in each image is hidden.
set(handles.roi_visibility, 'Enable', 'on');

if handles.currentROI.roiVisibility
    set(handles.roi_visibility, 'Value', true);
else
    set(handles.roi_visibility, 'Value', false);
    set(handles.currentROI.roiPatchHandles{1}, 'Visible', 'off')
    set(handles.currentROI.roiPatchHandles{2}, 'Visible', 'off')
    set(handles.currentROI.roiPatchHandles{3}, 'Visible', 'off')
end

% Update the Study to appdata.
setappdata(0, 'ImageAnalyzerStudy', handles.study);

handles.output = hObject;
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = visualization_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Function for checking if current axes contain visible ROIs at current
% --- slider position.
function checkROIVisibilities(hObject, eventdata, handles)

if handles.numberOfROIs > 0
    
    for i = 1:handles.numberOfROIs
        hROI = handles.study.imageSeriesList{ ...
            handles.study.imageSeriesId}.roiList{i};
        
        % The min and max values, the image ID and the slider value depend
        % on the axes currently active.
        switch gca
            case handles.axes_left
                polyMin = round(hROI.roiPolys(2,2));
                polyMax = polyMin + round(hROI.roiPolys(2,4));
                imageId = 1;
                sliderValue = round(get(handles.slider_left,'Value'));
            case handles.axes_center
                polyMin = round(hROI.roiPolys(1,2));
                polyMax = polyMin + round(hROI.roiPolys(1,4));
                imageId = 2;
                sliderValue = round(get(handles.slider_center,'Value'));
            case handles.axes_right
                polyMin = round(hROI.roiPolys(1,1));
                polyMax = polyMin + round(hROI.roiPolys(1,3));
                imageId = 3;
                sliderValue = round(get(handles.slider_right,'Value'));
        end
        
        % Adjust the ROI patch visibilites accordingly. If the slider value
        % fits between the ROI values and the ROI is checked to be visible,
        % then the patch visibility is turned on.
        
        % Current ROI is empty when 'All ROIs' is selected in popupmenu.
        if isempty(handles.currentROI)
            if sliderValue < polyMin || sliderValue > polyMax || ...
                    ~hROI.roiVisibility
                
                set(hROI.roiPatchHandles{imageId}, 'Visible', 'off');
            else
                set(hROI.roiPatchHandles{imageId}, 'Visible', 'on');
            end
        else
            
            
            if str2double(handles.currentROI.roiName) ~= ...
                    str2double(hROI.roiName) || ~handles.editInProgress
                
                if sliderValue < polyMin || sliderValue > polyMax || ...
                        ~hROI.roiVisibility
                    
                    set(hROI.roiPatchHandles{imageId}, 'Visible', 'off');
                else
                    set(hROI.roiPatchHandles{imageId}, 'Visible', 'on');
                end
            end
        end
    end
end

handles.output = hObject;
guidata(hObject, handles);


% --- Executes on left slider movement.
function slider_left_Callback(hObject, eventdata, handles)

sliderValue = round(get(hObject,'Value'));
set(handles.leftSliderText, 'String',num2str(sliderValue));

% Update the image to match the new sliderValue.
set(handles.leftImage, 'CData', squeeze(handles.study.imageSeriesList{ ...
    handles.study.imageSeriesId}.stack ...
    (sliderValue,:,:)));

% Set left axes active and check ROI visibilities.
set(gcf, 'CurrentAxes', handles.axes_left);
checkROIVisibilities(hObject, eventdata, handles);
handles = guidata(hObject);

% Saving the slider positions
save_slider_positions(hObject, eventdata, handles);
handles = guidata(hObject);

axes_left_ButtonDownFcn(hObject, eventdata, handles);

% Update the Study to appdata.
setappdata(0, 'ImageAnalyzerStudy', handles.study);

handles.output = hObject;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_left_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on slider movement.
function slider_center_Callback(hObject, eventdata, handles)
% hObject    handle to slider_center (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sliderValue = round(get(hObject,'Value'));
set(handles.centerSliderText, 'String',num2str(sliderValue));

image = handles.study.imageSeriesList{handles.study.imageSeriesId};
set(handles.centerImage, 'CData', squeeze(image.stack(:,sliderValue,:)));

set(gcf, 'CurrentAxes', handles.axes_center);

checkROIVisibilities(hObject, eventdata, handles);
handles = guidata(hObject);

% Saving the slider positions
save_slider_positions(hObject, eventdata, handles);
handles = guidata(hObject);

axes_center_ButtonDownFcn(hObject, eventdata, handles);

% Update the Study to appdata.
setappdata(0, 'ImageAnalyzerStudy', handles.study);

handles.output = hObject;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_center_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_center (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on slider movement.
function slider_right_Callback(hObject, eventdata, handles)
% hObject    handle to slider_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sliderValue = round(get(hObject,'Value'));
set(handles.rightSliderText, 'String',num2str(sliderValue));

set(handles.rightImage, 'CData', squeeze(handles.study.imageSeriesList{ ...
    handles.study.imageSeriesId}.stack(:,:,sliderValue)));

set(gcf, 'CurrentAxes', handles.axes_right);

checkROIVisibilities(hObject, eventdata, handles);
handles = guidata(hObject);

% Saving the slider positions
save_slider_positions(hObject, eventdata, handles);
handles = guidata(hObject);

axes_right_ButtonDownFcn(hObject, eventdata, handles);

% Update the Study to appdata.
setappdata(0, 'ImageAnalyzerStudy', handles.study);

handles.output = hObject;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_right_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in add_roi.
function add_roi_Callback(hObject, eventdata, handles)
% hObject    handle to add_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

currentImage = handles.study.imageSeriesList{handles.study.imageSeriesId};

set(handles.edit_roi, 'Enable', 'off')
set(handles.delete_roi, 'Enable', 'off')
set(handles.import_roi, 'Enable', 'off')
set(handles.copy_roi, 'Enable', 'off')
set(handles.visualize_roi, 'Enable', 'off')
set(handles.add_roi, 'Enable', 'off')

switch handles.drawType
    case 'rectangular'
        switch gca
            case handles.axes_left
                
                % Draw ROI to selected axes
                roi_handle_left = imrect(gca);
                roi_position_left = getPosition(roi_handle_left);
                roi_position_center = [roi_position_left(1) ...
                    get(handles.slider_left,'Value') roi_position_left(3) 0];
                roi_position_right = [roi_position_left(2) ...
                    get(handles.slider_left,'Value') roi_position_left(4) 0];
                
                roi_coordinates_left = positionToCoordinates(roi_position_left);
                roi_coordinates_center = positionToCoordinates(roi_position_center);
                roi_coordinates_right = positionToCoordinates(roi_position_right);
                
                % Check ROI position
                if isempty(roi_position_left(roi_position_left < 0)) && ...
                        isempty(roi_coordinates_left(roi_coordinates_left > handles.width))
                    
                    % Setting sliderValues for images
                    sliderValueCenter = round(roi_position_left(2));
                    set(handles.centerImage, 'CData', squeeze( ...
                        currentImage.stack(:,sliderValueCenter,:)));
                    
                    sliderValueRight = round(roi_position_left(1));
                    set(handles.rightImage, 'CData', currentImage.stack ...
                        (:,:,sliderValueRight));
                    
                    % Update Sliders
                    set(handles.slider_center, 'Value', sliderValueCenter);
                    set(handles.slider_right, 'Value', sliderValueRight);
                    set(handles.centerSliderText, 'String',num2str(sliderValueCenter));
                    set(handles.rightSliderText, 'String',num2str(sliderValueRight));
                    
                    roi_handle_center = imrect(handles.axes_center, roi_position_center);
                    roi_handle_right = imrect(handles.axes_right, roi_position_right);
                else
                    delete(roi_handle_left);
                    warndlg('Invalid ROI indexes', 'ROI Error', 'modal')
                    uiwait(gcf)
                    add_roi_Callback(hObject, eventdata, handles)
                    return
                end
                
            case handles.axes_center
                
                roi_handle_center = imrect(gca);
                roi_position_center = getPosition(roi_handle_center);
                roi_position_left = [roi_position_center(1) ...
                    get(handles.slider_center,'Value') ...
                    roi_position_center(3) 0];
                roi_position_right = [get(handles.slider_center,'Value') ...
                    roi_position_center(2) ...
                    0 roi_position_center(4)];
                
                roi_coordinates_left = positionToCoordinates(roi_position_left);
                roi_coordinates_center = positionToCoordinates(roi_position_center);
                roi_coordinates_right = positionToCoordinates(roi_position_right);
                
                % Check ROI position
                if isempty(roi_position_center(roi_position_center < 0)) && ...
                        isempty(roi_coordinates_center(roi_coordinates_center > handles.width))
                    
                    % Setting sliderValues for images
                    sliderValueLeft = round(roi_position_center(2));
                    set(handles.leftImage, 'CData', squeeze(currentImage.stack ...
                        (sliderValueLeft,:,:)));
                    
                    sliderValueRight = round(roi_position_center(1));
                    set(handles.rightImage, 'CData', currentImage.stack ...
                        (:,:,sliderValueRight));
                    
                    % Update Sliders
                    set(handles.slider_left, 'Value', sliderValueLeft);
                    set(handles.slider_right, 'Value', sliderValueRight);
                    set(handles.leftSliderText, 'String',num2str(sliderValueLeft));
                    set(handles.rightSliderText, 'String',num2str(sliderValueRight));
                    
                    
                    roi_handle_left = imrect(handles.axes_left, roi_position_left);
                    roi_handle_right = imrect(handles.axes_right, roi_position_right);
                else
                    delete(roi_handle_center);
                    warndlg('Invalid ROI indexes', 'ROI Error', 'modal')
                    uiwait(gcf)
                    add_roi_Callback(hObject, eventdata, handles)
                    return
                end
                
            case handles.axes_right
                
                roi_handle_right = imrect(gca);
                roi_position_right = getPosition(roi_handle_right);
                roi_position_left = [ get(handles.slider_right,'Value') ...
                    roi_position_right(1) 0 roi_position_right(3)];
                roi_position_center = [get(handles.slider_right,'Value') ...
                    roi_position_right(2) 0 roi_position_right(4)];
                
                roi_coordinates_left = positionToCoordinates(roi_position_left);
                roi_coordinates_center = positionToCoordinates(roi_position_center);
                roi_coordinates_right = positionToCoordinates(roi_position_right);
                
                % Check ROI position
                if isempty(roi_position_right(roi_position_right < 0)) && ...
                        isempty(roi_coordinates_right(roi_coordinates_right > handles.width))
                    
                    % Setting sliderValues for images
                    sliderValueLeft = round(roi_position_right(2));
                    set(handles.leftImage, 'CData', squeeze(currentImage.stack ...
                        (sliderValueLeft,:,:)));
                    
                    sliderValueCenter = round(roi_position_right(1));
                    
                    set(handles.centerImage, 'CData', squeeze(currentImage.stack ...
                        (:,sliderValueCenter,:)));
                    
                    % Update Sliders
                    set(handles.slider_left, 'Value', sliderValueLeft);
                    set(handles.slider_center, 'Value', sliderValueCenter);
                    set(handles.leftSliderText, 'String', num2str(sliderValueLeft));
                    set(handles.centerSliderText, 'String', num2str(sliderValueCenter));
                    
                    roi_handle_left = imrect(handles.axes_left, roi_position_left);
                    roi_handle_center = imrect(handles.axes_center, roi_position_center);
                else
                    delete(roi_handle_right);
                    warndlg('Invalid ROI indexes', 'ROI Error', 'modal')
                    uiwait(gcf)
                    add_roi_Callback(hObject, eventdata, handles)
                    return
                end
        end
        
        % Constraining the popupmenu_rois
        fcn1 = makeConstrainToRectFcn('imrect',get(handles.axes_left,'XLim'), ...
            get(handles.axes_left,'YLim'));
        setPositionConstraintFcn(roi_handle_left,fcn1);
        fcn2 = makeConstrainToRectFcn('imrect',get(handles.axes_center,'XLim'), ...
            get(handles.axes_center,'YLim'));
        setPositionConstraintFcn(roi_handle_center,fcn2);
        fcn3 = makeConstrainToRectFcn('imrect',get(handles.axes_right,'XLim'), ...
            get(handles.axes_right,'YLim'));
        setPositionConstraintFcn(roi_handle_right,fcn3);
        
        
    case 'ellipse'
        
        switch gca
            case handles.axes_left
                
            case handles.axes_center
                
            case handles.axes_right
                
        end
        % Future extension.
end

if handles.numberOfROIs > 0
    handles.ROI_Id = str2double(handles.study.imageSeriesList{ ...
        handles.study.imageSeriesId}.roiList{end}.roiName) + 1;
else
    handles.ROI_Id = handles.ROI_Id + 1;
end

handles.activeROI = true;
handles.currentROI = roi(num2str(handles.ROI_Id));
handles.currentROI.roiShape = handles.drawType;
%handles.currentROI.roiText = get(handles.edit_roiName, 'String');

Red     = get(handles.roiSliderRed,    'Value');
Green   = get(handles.roiSliderGreen,  'Value');
Blue    = get(handles.roiSliderBlue,   'Value');

RGB = [Red Green Blue];
handles.currentROI.roiColor = RGB;
handles.currentROI.roiAlpha = get(handles.roiSliderAlpha, 'Value');

handles.currentROI.roiPolys = [roi_position_left; roi_position_center; ...
    roi_position_right];
handles.currentROI.roiCoordinates = cat(3,roi_coordinates_left, ...
    roi_coordinates_center, roi_coordinates_right);
handles.currentROI.roiPatchHandles = {roi_handle_left ...
    roi_handle_center roi_handle_right};


set(handles.add_roi, 'Enable', 'off');
set(handles.edit_roi, 'Enable', 'off');
set(handles.copy_roi, 'Enable', 'off');
set(handles.delete_roi, 'Enable', 'off');
set(handles.popupmenu_rois, 'Enable', 'off');

set(handles.roiSliderRed, 'Enable', 'off')
set(handles.roiSliderGreen, 'Enable', 'off')
set(handles.roiSliderBlue, 'Enable', 'off')
set(handles.roiSliderAlpha, 'Enable', 'off')

% Disabling image sliders
set(handles.slider_left, 'Enable', 'off');
set(handles.slider_center, 'Enable', 'off');
set(handles.slider_right, 'Enable', 'off');

addNewPositionCallback(handles.currentROI.roiPatchHandles{1},@(p) ...
    LeftROIaction(p, hObject, eventdata, handles));
addNewPositionCallback(handles.currentROI.roiPatchHandles{2},@(p) ...
    CenterROIaction(p, hObject, eventdata, handles));
addNewPositionCallback(handles.currentROI.roiPatchHandles{3},@(p) ...
    RightROIaction(p, hObject, eventdata, handles));

% Enable saving of ROI
set(handles.save_roi, 'Enable', 'on');

handles.output = hObject;
guidata(hObject, handles);


% ------------------------------------------------------------------------
function LeftROIaction(p,hObject, eventdata, handles)

set(gcf, 'CurrentAxes', handles.axes_left);

p1 = getPosition(handles.currentROI.roiPatchHandles{1});
p2 = getPosition(handles.currentROI.roiPatchHandles{2});
p3 = getPosition(handles.currentROI.roiPatchHandles{3});
p2(1) = p(1);
p2(3) = p(3);
p3(1) = p(2);
p3(3) = p(4);

% TODO: update patch positions to data structures!
handles.currentROI.roiPolys = [p1; p2; p3];
handles.currentROI.roiCoordinates(:,:,1) = positionToCoordinates(p1);
handles.currentROI.roiCoordinates(:,:,2) = positionToCoordinates(p2);
handles.currentROI.roiCoordinates(:,:,3) = positionToCoordinates(p3);

% THIS was required to update polys!
handles.output = hObject;
guidata(hObject, handles);

% Updating the correct slice for RIGHT image
sliderValueRight = round(p(1));
currentImage = handles.study.imageSeriesList{handles.study.imageSeriesId};

% UPDATE OTHER ROI VISIBILITIES TOO!
if sliderValueRight > 0 && sliderValueRight <= handles.slices
    %set(handles.currentROI.roiPatchHandles{3}, 'Visible', 'on');
    set(handles.rightImage, 'CData', currentImage.stack(:,:,sliderValueRight));
end

% Update Sliders
set(handles.slider_right, 'Value', sliderValueRight);
set(handles.rightSliderText, 'String',num2str(sliderValueRight));

% -----------------------------------------------
checkROIVisibilities(hObject, eventdata, handles);
handles = guidata(hObject);
% -----------------------------------------------

% -----------------------------------------------
updateROIVolume(hObject, eventdata, handles);
handles = guidata(hObject);
% -----------------------------------------------

setPosition(handles.currentROI.roiPatchHandles{2},p2);
setPosition(handles.currentROI.roiPatchHandles{3},p3);

handles.output = hObject;
guidata(hObject, handles);


% ------------------------------------------------------------------------
function CenterROIaction(p,hObject, eventdata, handles)

set(gcf, 'CurrentAxes', handles.axes_center);

p1 = getPosition(handles.currentROI.roiPatchHandles{1});
p2 = getPosition(handles.currentROI.roiPatchHandles{2});
p3 = getPosition(handles.currentROI.roiPatchHandles{3});
p1(1) = p(1);
p1(3) = p(3);
p3(2) = p(2);
p3(4) = p(4);

% Update all three polys and coordinates.
handles.currentROI.roiPolys = [p1; p2; p3];
handles.currentROI.roiCoordinates(:,:,1) = positionToCoordinates(p1);
handles.currentROI.roiCoordinates(:,:,2) = positionToCoordinates(p2);
handles.currentROI.roiCoordinates(:,:,3) = positionToCoordinates(p3);

% THIS was required to update polys!
handles.output = hObject;
guidata(hObject, handles);

% Updating the correct slice for RIGHT image
sliderValueLeft = round(p(2));
currentImage = handles.study.imageSeriesList{handles.study.imageSeriesId};

if sliderValueLeft > 0 && sliderValueLeft <= handles.width
    set(handles.currentROI.roiPatchHandles{1}, 'Visible', 'on');
    set(handles.leftImage, 'CData', squeeze(currentImage.stack ...
        (sliderValueLeft,:,:)));
end

% Update Sliders
set(handles.slider_left, 'Value', sliderValueLeft);
set(handles.leftSliderText, 'String',num2str(sliderValueLeft));

% -----------------------------------------------
checkROIVisibilities(hObject, eventdata, handles);
handles = guidata(hObject);
% -----------------------------------------------

% -----------------------------------------------
updateROIVolume(hObject, eventdata, handles);
handles = guidata(hObject);
% -----------------------------------------------

setPosition(handles.currentROI.roiPatchHandles{1},p1);
setPosition(handles.currentROI.roiPatchHandles{3},p3);

handles.output = hObject;
guidata(hObject, handles);


% ------------------------------------------------------------------------
function RightROIaction(p,hObject, eventdata, handles)

set(gcf, 'CurrentAxes', handles.axes_right);

p1 = getPosition(handles.currentROI.roiPatchHandles{1});
p2 = getPosition(handles.currentROI.roiPatchHandles{2});
p3 = getPosition(handles.currentROI.roiPatchHandles{3});

p1(2) = p(1);
p1(4) = p(3);
p2(2) = p(2);
p2(4) = p(4);

handles.currentROI.roiPolys = [p1; p2; p3];
handles.currentROI.roiCoordinates(:,:,1) = positionToCoordinates(p1);
handles.currentROI.roiCoordinates(:,:,2) = positionToCoordinates(p2);
handles.currentROI.roiCoordinates(:,:,3) = positionToCoordinates(p3);

% THIS was required to update polys!
handles.output = hObject;
guidata(hObject, handles);

% Updating the correct slice for CENTER image
sliderValueCenter = round(p(1));
currentImage = handles.study.imageSeriesList{handles.study.imageSeriesId};

if sliderValueCenter > 0 && sliderValueCenter <= handles.width
    set(handles.currentROI.roiPatchHandles{2}, 'Visible', 'on');
    set(handles.centerImage, 'CData', squeeze(currentImage.stack ...
        (:,sliderValueCenter,:)));
end

% Update Sliders
set(handles.slider_center, 'Value', sliderValueCenter);
set(handles.centerSliderText, 'String',num2str(sliderValueCenter));

% -----------------------------------------------
checkROIVisibilities(hObject, eventdata, handles);
handles = guidata(hObject);
% -----------------------------------------------

% -----------------------------------------------
updateROIVolume(hObject, eventdata, handles);
handles = guidata(hObject);
% -----------------------------------------------

setPosition(handles.currentROI.roiPatchHandles{1},p1);
setPosition(handles.currentROI.roiPatchHandles{2},p2);

handles.output = hObject;
guidata(hObject, handles);


% --- Executes when selected object is changed in roi_shape.
function roi_shape_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in roi_shape
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

switch get(eventdata.NewValue,'Tag')
    case 'roi_rect'
        handles.drawType = 'rectangular';
    case 'roi_elli'
        handles.drawType = 'rectangular';
        warndlg('Ellipsoid shape currently unavailable', 'Draw Type Error', 'modal')
        uiwait(gcf)
        set(eventdata.OldValue, 'Value', 1);
        return
    otherwise
end

handles.output = hObject;
guidata(hObject, handles);


% --- Executes on button press in delete_roi.
function delete_roi_Callback(hObject, eventdata, handles)

modaldlgTitle = 'Confirm RoI deleting';
if handles.roiListId <= 0
    modaldlgString = 'Delete ALL ROIs?';
else
    modaldlgString = ['Delete ROI "', ...
        num2str(handles.currentROI.roiText), '" ?'];
end

user_response = modaldlg('Title', modaldlgTitle, 'String', modaldlgString);
switch lower(user_response)
    case 'no'
        return
    case 'yes'
        
        imageSet = handles.study.imageSeriesList{handles.study.imageSeriesId};
        
        % In case 'All ROIs' is selected from the popupmenu, all the ROIs
        % and the .roi files are deleted.
        if handles.roiListId <= 0
            
            for j = 1:length(imageSet.roiList)
                handles.currentROI = imageSet.roiList{j};
                for i = 1:3
                    delete(handles.currentROI.roiPatchHandles{i});
                    handles.currentROI.roiPatchHandles{i} = [];
                end
                
                handles.study.imageSeriesList{handles.study.imageSeriesId}. ...
                    roiList(1) = [];
            end
            
            handles.numberOfROIs = 0;
            handles.currentROI = [];
            
            set(handles.popupmenu_rois, 'Value', 1 );
            set(handles.popupmenu_rois, 'String', 'All ROIs');
            
            folderStr = strcat(handles.study.pathName,'\', ...
                imageSet.name,'\', 'ROIs');
            
            if exist(folderStr, 'dir') == 7
                delete(strcat(folderStr,'\','*.roi'))
            end
            
        else
            
            % Deleting the roiPatchHandles of currentROI.
            for i = 1:length(handles.currentROI.roiPatchHandles)
                delete(handles.currentROI.roiPatchHandles{i});
                handles.currentROI.roiPatchHandles{i} = [];
            end
            
            % Deleting the selected ROI from the popupmenu and study.
            popupmenuString = get(handles.popupmenu_rois, 'String');
            popupmenuCell = cellstr(popupmenuString);
            popupmenuCell(handles.roiListId + 1) = [];
            
            handles.study.imageSeriesList{handles.study.imageSeriesId}. ...
                roiList(handles.roiListId) = [];
            
            handles.roiListId = length(popupmenuCell) - 1;
            handles.numberOfROIs = length(handles.study.imageSeriesList{ ...
                handles.study.imageSeriesId}.roiList);
            
            folderStr = strcat(handles.study.pathName,'\', ...
                handles.study.imageSeriesList{handles.study.imageSeriesId}. ...
                name,'\','ROIs');
            
            if exist(folderStr, 'dir')
                fileStr = strcat(folderStr, '\', ...
                    handles.currentROI.roiName, '.roi');
                if exist(fileStr, 'file')
                    delete(fileStr);
                end
            end
            
            handles.currentROI = [];
            
            % If there are ROIs left, set the ROI_Id to match the name of the
            % most recently added ROI.
            if handles.numberOfROIs > 0
                handles.ROI_Id = num2str(handles.study.imageSeriesList{ ...
                    handles.study.imageSeriesId}.roiList{end}.roiName);
            else
                set(handles.copy_roi, 'Enable', 'off');
            end
            
            set(handles.popupmenu_rois, 'Value', length(popupmenuCell));
            set(handles.popupmenu_rois, 'String', char(popupmenuCell));
            
        end
end

if handles.numberOfROIs == 0
    % Updating corresponding Menubar items.
    menubar_handles = getappdata(0, 'menubar_handles');
    set(menubar_handles.menu_fe, 'Enable', 'off');
    manager_handles = getappdata(0, 'manager_handles');
    set(manager_handles.text_ROIVolume, 'String', 0);
end

% Updating Manager text fields
manager_handles = getappdata(0, 'manager_handles');
set(manager_handles.text_numberOfROIs, 'String', ...
    num2str(handles.numberOfROIs));

% Calling popupmenu_rois_Callback for GUI updates.
popupmenu_rois_Callback(hObject, eventdata, handles);
handles = guidata(hObject);

% Update the Study to appdata.
setappdata(0, 'ImageAnalyzerStudy', handles.study);

handles.output = hObject;
guidata(hObject, handles);


% --- Executes on selection change in popupmenu_rois.
function popupmenu_rois_Callback(hObject, eventdata, handles)

% roiListId is updated to match popupmenu value. The first popupmenu item
% is the default text with value '1' so the value is decreased by one.
handles.roiListId = get(handles.popupmenu_rois, 'Value') - 1;

% If the 'All ROIs' text is selected the ROI editing buttons are
% disabled and currentROI handle is deleted.
if handles.roiListId <= 0
    
    set(handles.copy_roi, 'Enable', 'off');
    set(handles.edit_roi, 'Enable', 'off');
    set(handles.save_roi, 'Enable', 'off');
    set(handles.delete_roi, 'Enable', 'off');
    set(handles.edit_roiName, 'Enable', 'off');
    
    handles.currentROI = [];
    
    % Checking if ROIs exist.
    if handles.numberOfROIs > 0
        
        % The roi_visibility checkbox is enabled in case the previous
        % popupmenu value had disabled it.
        set(handles.roi_visibility, 'Enable', 'on');
        
        % Deleting is also enabled and an attempt to delete all ROIs will
        % prompt the user for confirmation (delete_roi_Callback).
        set(handles.delete_roi, 'Enable', 'on');
        
        % The roi_visibility checkbox is set checked (value: true) if all
        % the ROIs are visible. Otherwise it is set unchecked (value:
        % false).
        for i=1:handles.numberOfROIs
            if ~handles.study.imageSeriesList{ ...
                    handles.study.imageSeriesId}.roiList{i}.roiVisibility
                set(handles.roi_visibility, 'Value', false);
                break;
            else
                set(handles.roi_visibility, 'Value', true);
            end
        end
    else
        % If no ROIs exist, the ROI_Id is set to zero and the visibility
        % checkbox is disabled.
        handles.ROI_Id = 0;
        set(handles.roi_visibility, 'Value', false);
        set(handles.roi_visibility, 'Enable', 'off');
        set(handles.edit_roiName, 'String', handles.defaultROIname);
    end
    
else
    % When one of the ROIs is selected, the currentROI is set to match that
    % ROI in the roiList by the roiListId.
    handles.currentROI = handles.study.imageSeriesList{ ...
        handles.study.imageSeriesId}.roiList{handles.roiListId};
    
    setappdata(0, 'currentROI', handles.currentROI);
    
    % Setting ROI name edit box string to match current ROIs roiText.
    set(handles.edit_roiName, 'String', handles.currentROI.roiText);
    
    % Enabling ROI edit buttons and the visibility checkbox.
    set(handles.roi_visibility, 'Enable', 'on');
    set(handles.add_roi, 'Enable', 'on');
    set(handles.copy_roi, 'Enable', 'on');
    set(handles.edit_roi, 'Enable', 'on');
    set(handles.delete_roi, 'Enable', 'on');
    set(handles.edit_roiName, 'Enable', 'on');
    set(handles.roi_visibility, 'Value', handles.currentROI.roiVisibility);
    
    RGB = handles.currentROI.roiColor;
    set(handles.roiSliderRed, 'Value', RGB(1) );
    set(handles.roiSliderGreen, 'Value', RGB(2));
    set(handles.roiSliderBlue, 'Value', RGB(3));
    set(handles.textColor, 'BackgroundColor', RGB);
    set(handles.roiSliderAlpha, 'Value', handles.currentROI.roiAlpha)
    
    updateROIVolume(hObject, eventdata, handles)
end

handles.output = hObject;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popupmenu_rois_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_rois (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in save_roi.
function save_roi_Callback(hObject, eventdata, handles)
% hObject    handle to save_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


delete(handles.currentROI.roiPatchHandles{1})
delete(handles.currentROI.roiPatchHandles{2})
delete(handles.currentROI.roiPatchHandles{3})


% When adding new ROIs, currentROI is pushed to roiList and roiListId is
% set to match numberOfROIs.
if ~handles.editInProgress
    handles.study.imageSeriesList{handles.study.imageSeriesId}. ...
        roiList{handles.numberOfROIs + 1} = handles.currentROI;
    
    handles.roiListId = handles.numberOfROIs + 1;
else
    handles.study.imageSeriesList{handles.study.imageSeriesId}. ...
        roiList{handles.roiListId} = handles.currentROI;
end

% Saving the slider positions
save_slider_positions(hObject, eventdata, handles);
handles = guidata(hObject);

drawROIs(hObject, eventdata, handles);
handles = guidata(hObject);

% Enabling ROI edit buttons
set(handles.edit_roi, 'Enable', 'on');
set(handles.delete_roi, 'Enable', 'on');
set(handles.save_roi, 'Enable', 'off');
set(handles.add_roi, 'Enable', 'on');
set(handles.copy_roi, 'Enable', 'on');
set(handles.popupmenu_rois, 'Enable', 'on');
set(handles.edit_roiName, 'Enable', 'on');
set(handles.visualize_roi, 'Enable', 'on')

% Setting the ROI state parameters to false.
handles.activeROI = false;
handles.editInProgress = false;
handles.importInProgress = false;

handles.numberOfROIs = length(handles.study.imageSeriesList{ ...
    handles.study.imageSeriesId}.roiList);

manager_handles = getappdata(0, 'manager_handles');
set(manager_handles.text_numberOfROIs, 'String', ...
    num2str(handles.numberOfROIs));

menubar_handles = getappdata(0, 'menubar_handles');
set(menubar_handles.menu_fe, 'Enable', 'on');

% Setting the visibility for the ROI Visible -checkbox
if handles.currentROI.roiVisibility
    set(handles.roi_visibility, 'Value', true);
    set(handles.roi_visibility, 'Enable', 'on');
else
    set(handles.roi_visibility, 'Value', false);
    set(handles.roi_visibility, 'Enable', 'on');
end

% Enabling ROI Color and Image sliders.
set(handles.roiSliderRed, 'Enable', 'on')
set(handles.roiSliderGreen, 'Enable', 'on')
set(handles.roiSliderBlue, 'Enable', 'on')
set(handles.roiSliderAlpha, 'Enable', 'on')
set(handles.slider_left, 'Enable', 'on');
set(handles.slider_center, 'Enable', 'on');
set(handles.slider_right, 'Enable', 'on');

set(handles.add_roi, 'Enable', 'on');
set(handles.edit_roi, 'Enable', 'on');
set(handles.delete_roi, 'Enable', 'on');
set(handles.import_roi, 'Enable', 'on');

setappdata(0, 'ImageAnalyzerStudy', handles.study);
setappdata(0, 'currentROI', handles.currentROI);

set(gcf, 'CurrentAxes', handles.axes_left);
checkROIVisibilities(hObject, eventdata, handles);
handles = guidata(hObject);

set(gcf, 'CurrentAxes', handles.axes_center);
checkROIVisibilities(hObject, eventdata, handles);
handles = guidata(hObject);

set(gcf, 'CurrentAxes', handles.axes_right);
checkROIVisibilities(hObject, eventdata, handles);
handles = guidata(hObject);

handles.copyROI = false;

handles.output = hObject;
guidata(hObject, handles);


% --- Executes on button press in edit_roi.
function edit_roi_Callback(hObject, eventdata, handles)
% hObject    handle to edit_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.add_roi, 'Enable', 'off');
set(handles.edit_roi, 'Enable', 'off');
set(handles.delete_roi, 'Enable', 'off');
set(handles.save_roi, 'Enable', 'on');
set(handles.import_roi, 'Enable', 'off');
set(handles.copy_roi, 'Enable', 'off');
set(handles.popupmenu_rois, 'Enable', 'off');
set(handles.edit_roiName, 'Enable', 'off');
set(handles.visualize_roi, 'Enable', 'off')
set(handles.roiSliderRed, 'Enable', 'off');
set(handles.roiSliderGreen, 'Enable', 'off');
set(handles.roiSliderBlue, 'Enable', 'off');
set(handles.roiSliderAlpha, 'Enable', 'off');

% Disabling image sliders
set(handles.slider_left, 'Enable', 'off');
set(handles.slider_center, 'Enable', 'off');
set(handles.slider_right, 'Enable', 'off');

if ~handles.copyROI
    handles.editInProgress = true;
    handles.ROI_Id = str2double(handles.currentROI.roiName);
else
    handles.ROI_Id = str2double(handles.currentROI.roiName) + 1;
    handles.currentROI.roiName = int2str(handles.ROI_Id);
    handles.currentROI.roiText = strcat(handles.currentROI.roiText, '_copy');
end

if ~handles.importInProgress
    delete(handles.currentROI.roiPatchHandles{1})
    handles.currentROI.roiPatchHandles{1} = [];
    delete(handles.currentROI.roiPatchHandles{2})
    handles.currentROI.roiPatchHandles{2} = [];
    delete(handles.currentROI.roiPatchHandles{3})
    handles.currentROI.roiPatchHandles{3} = [];
end

switch handles.drawType
    case 'rectangular'
        handles.currentROI.roiPatchHandles{1} = imrect(handles.axes_left, ...
            handles.currentROI.roiPolys(1,:));
        handles.currentROI.roiPatchHandles{2} = imrect(handles.axes_center, ...
            handles.currentROI.roiPolys(2,:));
        handles.currentROI.roiPatchHandles{3} = imrect(handles.axes_right, ...
            handles.currentROI.roiPolys(3,:));
        
    case 'ellipse'
        handles.currentROI.roiPatchHandles{1} = imellipse(handles.axes_left, ...
            handles.currentROI.roiPolys(1,:));
        handles.currentROI.roiPatchHandles{2} = imellipse(handles.axes_center, ...
            handles.currentROI.roiPolys(2,:));
        handles.currentROI.roiPatchHandles{3} = imellipse(handles.axes_right, ...
            handles.currentROI.roiPolys(3,:));
end


fcn1 = makeConstrainToRectFcn('imrect',get(handles.axes_left,'XLim'), ...
    get(handles.axes_left,'YLim'));
setPositionConstraintFcn(handles.currentROI.roiPatchHandles{1},fcn1);
fcn2 = makeConstrainToRectFcn('imrect',get(handles.axes_center,'XLim'), ...
    get(handles.axes_center,'YLim'));
setPositionConstraintFcn(handles.currentROI.roiPatchHandles{2},fcn2);
fcn3 = makeConstrainToRectFcn('imrect',get(handles.axes_right,'XLim'), ...
    get(handles.axes_right,'YLim'));
setPositionConstraintFcn(handles.currentROI.roiPatchHandles{3},fcn3);

% Callbacks for the popupmenu_rois
addNewPositionCallback(handles.currentROI.roiPatchHandles{1},@(p) ...
    LeftROIaction(p, hObject, eventdata, handles));
addNewPositionCallback(handles.currentROI.roiPatchHandles{2},@(p) ...
    CenterROIaction(p, hObject, eventdata, handles));
addNewPositionCallback(handles.currentROI.roiPatchHandles{3},@(p) ...
    RightROIaction(p, hObject, eventdata, handles));

handles.copyROI = false;

handles.output = hObject;
guidata(hObject, handles);


% --- Executes on button press in roi_visibility.
function roi_visibility_Callback(hObject, eventdata, handles)
% hObject    handle to roi_visibility (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

roiVisibility = get(hObject,'Value');
roiPopupmenu = get(handles.popupmenu_rois, 'Value');

if roiVisibility
    
    if roiPopupmenu == 1 && handles.numberOfROIs > 0
        for i = 1:handles.numberOfROIs
            handles.study.imageSeriesList{handles.study.imageSeriesId}. ...
                roiList{i}.roiVisibility = true;
        end
    else
        handles.study.imageSeriesList{handles.study.imageSeriesId}. ...
            roiList{handles.roiListId}.roiVisibility = true;
        handles.currentROI.roiVisibility = true;
    end
    
else
    
    if roiPopupmenu == 1 && handles.numberOfROIs > 0
        for i = 1:handles.numberOfROIs
            handles.study.imageSeriesList{handles.study.imageSeriesId}. ...
                roiList{i}.roiVisibility = false;
        end
    else
        handles.study.imageSeriesList{handles.study.imageSeriesId}. ...
            roiList{handles.roiListId}.roiVisibility = false;
        handles.currentROI.roiVisibility = false;
    end
end

set(gcf, 'CurrentAxes', handles.axes_left);
checkROIVisibilities(hObject, eventdata, handles);
handles = guidata(hObject);

set(gcf, 'CurrentAxes', handles.axes_center);
checkROIVisibilities(hObject, eventdata, handles);
handles = guidata(hObject);

set(gcf, 'CurrentAxes', handles.axes_right);
checkROIVisibilities(hObject, eventdata, handles);
handles = guidata(hObject);

handles.output = hObject;
guidata(hObject, handles);


% --- Executes on slider movement.
function save_slider_positions(hObject, eventdata, handles)

handles.study.imageSeriesList{handles.study.imageSeriesId}. ...
    sliderPositions(1) = round(get(handles.slider_left, 'Value'));
handles.study.imageSeriesList{handles.study.imageSeriesId}. ...
    sliderPositions(2) = round(get(handles.slider_center, 'Value'));
handles.study.imageSeriesList{handles.study.imageSeriesId}. ...
    sliderPositions(3) = round(get(handles.slider_right, 'Value'));

handles.output = hObject;
guidata(hObject, handles);


% --- Executes when user attempts to close manager.
function visualization_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to manager (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Closing the Study Visualization window only hides it.
menubar_handles = getappdata(0, 'menubar_handles');

if ~isempty(menubar_handles)
    set(menubar_handles.menu_view_visualization,'Checked','off');
    set(getappdata(0,'hVisualization'),'Visible','off');
else
    delete(hObject);
end

% --- Executes on slider movement.
function roiSliderRed_Callback(hObject, eventdata, handles)
% hObject    handle to roiSliderRed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

updateROIColors(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function roiSliderRed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roiSliderRed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on slider movement.
function roiSliderGreen_Callback(hObject, eventdata, handles)
% hObject    handle to roiSliderGreen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

updateROIColors(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function roiSliderGreen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roiSliderGreen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on slider movement.
function roiSliderBlue_Callback(hObject, eventdata, handles)
% hObject    handle to roiSliderBlue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

updateROIColors(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function roiSliderBlue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roiSliderBlue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on slider movement.
function roiSliderAlpha_Callback(hObject, eventdata, handles)
% hObject    handle to roiSliderAlpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

roiAlpha = get(hObject, 'Value');

if handles.numberOfROIs > 0 && ~isempty(handles.currentROI)
    handles.currentROI.roiAlpha = roiAlpha;
    set(handles.currentROI.roiPatchHandles{1}, 'FaceAlpha', roiAlpha);
    set(handles.currentROI.roiPatchHandles{2}, 'FaceAlpha', roiAlpha);
    set(handles.currentROI.roiPatchHandles{3}, 'FaceAlpha', roiAlpha);
    
    % Update also the corresponding ImageSeriesList ROI object.
    handles.study.imageSeriesList{handles.study.imageSeriesId}. ...
        roiList{handles.roiListId} = handles.currentROI;
end

% Update the Study to appdata.
setappdata(0, 'ImageAnalyzerStudy', handles.study);

handles.output = hObject;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function roiSliderAlpha_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roiSliderAlpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% ------------------------------------------------------------------------
function updateROIColors(hObject, eventdata, handles)
% hObject    handle to roiSliderBlue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Red     = get(handles.roiSliderRed,    'Value');
Green   = get(handles.roiSliderGreen,  'Value');
Blue    = get(handles.roiSliderBlue,   'Value');

RGB = [Red Green Blue];
set(handles.textColor, 'BackgroundColor', RGB);
if handles.numberOfROIs > 0 && ~isempty(handles.currentROI)
    handles.currentROI.roiColor = RGB;
    set(handles.currentROI.roiPatchHandles{1}, 'FaceColor', RGB);
    set(handles.currentROI.roiPatchHandles{2}, 'FaceColor', RGB);
    set(handles.currentROI.roiPatchHandles{3}, 'FaceColor', RGB);
    
    % Update also the corresponding ImageSeriesList ROI object.
    handles.study.imageSeriesList{handles.study.imageSeriesId}. ...
        roiList{handles.roiListId} = handles.currentROI;
end

% Update the Study to appdata.
setappdata(0, 'ImageAnalyzerStudy', handles.study);

handles.output = hObject;
guidata(hObject, handles);


% --- Transforms the [x, y, height, width] format to coordinate pairs.
function [roi_coordinates] = positionToCoordinates(roi_position)

x(1) = roi_position(1);
x(2) = x(1);
x(3) = x(1) + roi_position(3);
x(4) = x(3);

y(1) = roi_position(2);
y(2) = y(1) + roi_position(4);
y(3) = y(2);
y(4) = y(1);

roi_coordinates = [x' y'];


% --- Executes on button press in import_roi.
function import_roi_Callback(hObject, eventdata, handles)
% hObject    handle to import_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the latest ImageAnalyzerStudy if possible
if ~isempty(getappdata(0, 'ImageAnalyzerStudy'))
    handles.study = getappdata(0, 'ImageAnalyzerStudy');
end

[fileName, pathName] = uigetfile( {'*.roi', 'Region of Interest Files (*.roi)'}, ...
    'Import Region of Interest', 'MultiSelect', 'off');

if fileName~=0
    
    h = load(strcat(pathName,fileName),'-mat');
    handles.currentROI = h.roiObject;
    handles.currentROI.roiName = int2str(handles.ROI_Id + 1);
    handles.importInProgress = true;
    edit_roi_Callback(hObject, eventdata, handles);
    handles = guidata(hObject);
    handles.editInProgress = false;
    
end

% Update the Study to appdata.
setappdata(0, 'ImageAnalyzerStudy', handles.study);

handles.output = hObject;
guidata(hObject, handles);


% --- Executes instead of default CloseRequestFcn of the 3D ROIs figure.
function hide3DROIs(hObject, eventdata, handles)

menubar_handles = getappdata(0, 'menubar_handles');
set(menubar_handles.menu_view_3DROIs, 'Checked', 'off', 'Enable', 'on');
set(getappdata(0, 'h3DROIs'), 'Visible', 'off');

handles.output = hObject;
guidata(hObject, handles);


% --- Executes on button press in copy_roi.
function copy_roi_Callback(hObject, eventdata, handles)
% hObject    handle to copy_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.numberOfROIs > 0
    
    handles.copyROI = true;
    handles.importInProgress = true;
    
    edit_roi_Callback(hObject, eventdata, handles);
    
    handles.copyROI = false;
    handles.importInProgress = false;
    handles = guidata(hObject);
    
end

handles.output = hObject;
guidata(hObject, handles);


% --- Executes on ROI editing.
function updateROIVolume(hObject, eventdata, handles)

% x = the right image x-coordinates
xMin = handles.currentROI.roiCoordinates(1,1,3);
xMax = handles.currentROI.roiCoordinates(3,1,3);

% y = the right image y-coordinates
yMin = handles.currentROI.roiCoordinates(1,2,3);
yMax = handles.currentROI.roiCoordinates(3,2,3);

% z = the center image x-coordinates
zMin = handles.currentROI.roiCoordinates(1,1,2);
zMax = handles.currentROI.roiCoordinates(3,1,2);

manager_handles = getappdata(0, 'manager_handles');

width = get(manager_handles.edit_pixelWidth, 'Value');
height = get(manager_handles.edit_pixelHeight, 'Value');
thickness = get(manager_handles.edit_sliceThickness, 'Value');

roiVolume = round((xMax-xMin)*width*(yMax-yMin)*height*(zMax-zMin)* ...
    thickness);

set(manager_handles.text_ROIVolume, 'String', ...
    num2str(roiVolume));

handles.output = hObject;
guidata(hObject, handles);


% --- Executes on ROI name editing.
function edit_roiName_Callback(hObject, eventdata, handles)
% hObject    handle to edit_roiName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(handles.currentROI)
    
    handles.study.imageSeriesList{handles.study.imageSeriesId}.roiList{ ...
        handles.roiListId}.roiText = get(handles.edit_roiName, 'String');
    handles.currentROI.roiText = get(handles.edit_roiName, 'String');
    hRoiPopup = get(handles.popupmenu_rois);
    cellString = cellstr(hRoiPopup.String);
    cellString{handles.roiListId + 1} = get(handles.edit_roiName, 'String');
    hRoiPopup.String = char(cellString);
    
    %set(handles.currentROI.roiText,
    set(handles.popupmenu_rois, 'String', hRoiPopup.String);
    set(handles.popupmenu_rois, 'Value', handles.roiListId + 1);
end

setappdata(0, 'ImageAnalyzerStudy', handles.study);
handles.output = hObject;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_roiName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_roiName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in visualize_roi.
function visualize_roi_Callback(hObject, eventdata, handles)
% hObject    handle to visualize_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

menubar_handles = getappdata(0, 'menubar_handles');
set(menubar_handles.menu_view_3DROIs, 'Checked', 'on', ...
    'Enable', 'on');
set(getappdata(0, 'h3DROIs'),'Visible','on')

if isempty(getappdata(0, 'h3DROIs'))
    winHandle = figure();
    set(winHandle, 'Position', [500 400 560 420], 'Name', ...
        'Visualization of all ROIs', 'NumberTitle', ...
        'off', 'Renderer',  'opengl', 'Menubar', 'none', ...
        'ToolBar','figure');
    daspect([1 1 1])
    view(3);
    axis([0 256 0 256 0 176]);
    camlight
    lighting gouraud
    alpha(0.5)
    rotate3d on
    
    setappdata(0, 'h3DROIs', winHandle)
else
    winHandle = getappdata(0, 'h3DROIs');
    
    for j = 1:length(handles.p)
        delete(handles.p{1});
        handles.p(1) = [];
    end
end

totalVolume = zeros(256,256,176);
clr = zeros(handles.numberOfROIs,3);

for i = 1:handles.numberOfROIs
    
    currentROI = handles.study.imageSeriesList{ ...
        handles.study.imageSeriesId}.roiList{i};
    
    % x = the right image x-coordinates
    xMin = ceil(currentROI.roiCoordinates(1,1,3));
    xMax = floor(currentROI.roiCoordinates(3,1,3));
    
    % y = the right image y-coordinates
    yMin = ceil(currentROI.roiCoordinates(1,2,3));
    yMax = floor(currentROI.roiCoordinates(3,2,3));
    
    % z = the center image x-coordinates
    zMin = ceil(currentROI.roiCoordinates(1,1,2));
    zMax = floor(currentROI.roiCoordinates(3,1,2));
    
    totalVolume(yMin:yMax, xMin:xMax, zMin:zMax) = i;
    
    volume_zp = padarray(totalVolume,[1 1 1]);
    set(0, 'CurrentFigure', winHandle)
    set(gcf, 'CurrentAxes', get(winHandle, 'CurrentAxes'));

    handles.p{i} = patch(isosurface(double(volume_zp)));
    set(handles.p{i}, 'CData',i);
    set(handles.p{i},'CDataMapping','direct','FaceColor','flat','EdgeColor','none');
    clr(i,:) = currentROI.roiColor;
end
colormap(clr)
set(gcf,'CloseRequestFcn',@hide3DROIs)

handles.output = hObject;
guidata(hObject, handles);


% --- Executes on mouse press over axes background.
function axes_left_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.axes_left, 'XTick', []);
set(handles.axes_left, 'YTick', []);
set(handles.axes_left, 'XColor', [1 0.5 0.5]);
set(handles.axes_left, 'YColor', [1 0.5 0.5]);
set(handles.axes_left, 'LineWidth', 2);
set(handles.axes_left, 'Visible', 'on');
set(handles.axes_right, 'Visible', 'off');
set(handles.axes_center, 'Visible', 'off');

% --- Executes on mouse press over axes background.
function axes_right_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.axes_right, 'XTick', []);
set(handles.axes_right, 'YTick', []);
set(handles.axes_right, 'XColor', [1 0.5 0.5]);
set(handles.axes_right, 'YColor', [1 0.5 0.5]);
set(handles.axes_right, 'LineWidth', 2);
set(handles.axes_left, 'Visible', 'off');
set(handles.axes_right, 'Visible', 'on');
set(handles.axes_center, 'Visible', 'off');

% --- Executes on mouse press over axes background.
function axes_center_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.axes_center, 'XTick', []);
set(handles.axes_center, 'YTick', []);
set(handles.axes_center, 'XColor', [1 0.5 0.5]);
set(handles.axes_center, 'YColor', [1 0.5 0.5]);
set(handles.axes_center, 'LineWidth', 2);
set(handles.axes_right, 'Visible', 'off');
set(handles.axes_left, 'Visible', 'off');
set(handles.axes_center, 'Visible', 'on');

function axes_right_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.axes_left, 'XTick', []);
set(handles.axes_left, 'YTick', []);
set(handles.axes_left, 'XColor', [1 0.5 0.5]);
set(handles.axes_left, 'YColor', [1 0.5 0.5]);
set(handles.axes_left, 'LineWidth', 2);
set(handles.axes_left, 'Visible', 'on');
