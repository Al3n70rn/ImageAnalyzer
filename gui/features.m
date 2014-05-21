function varargout = features(varargin)
% FEATURES MATLAB code for features.fig
%      FEATURES, by itself, creates a new FEATURES or raises the existing
%      singleton*.
%
%      H = FEATURES returns the handle to a new FEATURES or the handle to
%      the existing singleton*.
%
%      FEATURES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FEATURES.M with the given input 
%      arguments.
%
%      FEATURES('Property','Value',...) creates a new FEATURES or raises 
%      the existing singleton*.  Starting from the left, property value 
%      pairs are applied to the GUI before features_OpeningFcn gets called.
%      An unrecognized property name or invalid value makes property 
%      application stop.  All inputs are passed to features_OpeningFcn via 
%      varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help features

% Last Modified by GUIDE v2.5 09-May-2014 19:24:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @features_OpeningFcn, ...
                   'gui_OutputFcn',  @features_OutputFcn, ...
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


% --- Executes just before features is made visible.
function features_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to features (see VARARGIN)

% Choose default command line output for features
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

set(gcf, 'Name', strcat('Feature selection') );
handles.study = getappdata(0, 'ImageAnalyzerStudy');

% UIWAIT makes features wait for user response (see UIRESUME)
%uiwait(handles.figure1);

handles.output = hObject;
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = features_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in checkbox_dwt.
function checkbox_dwt_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_dwt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in checkbox_fft.
function checkbox_fft_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_fft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in checkbox_avg.
function checkbox_avg_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_avg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in checkbox_std.
function checkbox_std_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_std (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in checkbox_norm.
function checkbox_norm_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_norm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in checkbox_mean.
function checkbox_mean_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in checkbox_var.
function checkbox_var_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_var (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in checkbox_skew.
function checkbox_skew_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_skew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in checkbox_energy.
function checkbox_energy_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_energy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in checkbox_entr.
function checkbox_entr_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_entr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in pushbutton_compute.
function pushbutton_compute_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_compute (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Save Study each time so that the calculations take into 
% consideration all the possible changes made.
menubar_handles = getappdata(0, 'menubar_handles');
menubar_handles = get(menubar_handles.menu_file_save);
menubar_handles = menubar_handles.Callback;
menubar_handles(hObject, eventdata);

% Display waiting bar
hwb = waitbar(0,'Computing parameters, please wait...');

% Add all new parameters to this Titles cell. These values are saved
% to the first row of the .xls result file.
Titles = {'ROIName','STD','Mean','Variance','Skewness','Kurtosis',...
    'Energy','Contrast','Correlation','Homogeneity','DWT','FFT','LBP'...
    };

% Initialization of the results cell. The parameters columns must match
% with the Titles cell.
numberOfROIs = size(handles.study.imageSeriesList{...
    handles.study.imageSeriesId}.roiList, 2);
resultCell = cell(numberOfROIs,size(Titles,2));

% Loop for texture parameter calculations start here by checking each
% checkbox value.
for i = 1:numberOfROIs

    strComputeROIfeatures = ['Processing ROI ', num2str(i), '/', ...
        num2str(numberOfROIs),' ...'];
    waitbar(i/numberOfROIs,hwb,strComputeROIfeatures);
    
    currentROI = handles.study.imageSeriesList{handles.study.imageSeriesId}.roiList{i};
    currentROIvalues = getROIValues(handles.study, i);
    resultCell{i,1} = currentROI.roiText;

    % STANDARD DEVIATION
    if get(handles.checkbox_std,'Value') == 1
        resultCell{i,find(ismember(Titles,'STD'))} = std(double(currentROIvalues(:)));
    end
    
    % MEAN
    if get(handles.checkbox_mean,'Value') == 1
        resultCell{i,find(ismember(Titles,'Mean'))} = mean2(currentROIvalues);
    end
    
    % VARIANCE
    if get(handles.checkbox_var,'Value') == 1
        resultCell{i,find(ismember(Titles,'Variance'))} = var(double(currentROIvalues(:)));
    end
    
    % SKEWNESS
    if get(handles.checkbox_skew,'Value') == 1
        resultCell{i,find(ismember(Titles,'Skewness'))} = skewness(double(currentROIvalues(:)));
    end
    
    % KURTOSIS
    if get(handles.checkbox_skew,'Value') == 1
        resultCell{i,find(ismember(Titles,'Kurtosis'))} = kurtosis(double(currentROIvalues(:)));
    end
    
    % CO-OCCURRENCE MATRIX
    glcm = graycomatrix(currentROIvalues(:,:,1), 'GrayLimits',[]);
    %[featureVector,coocMat] = cooc3d (currentROIvalues);
    
    % ENERGY
    if get(handles.checkbox_energy,'Value') == 1
        resultStruct = graycoprops(glcm, 'Energy');
        resultCell{i,find(ismember(Titles,'Energy'))} = resultStruct.Energy;
    end
    
    % CONTRAST
    if get(handles.checkbox_contrast,'Value') == 1
        resultStruct = graycoprops(glcm, 'Contrast');
        resultCell{i,find(ismember(Titles,'Contrast'))} = resultStruct.Contrast;
    end
    
    % CORRELATION
    if get(handles.checkbox_correlation,'Value') == 1
        resultStruct = graycoprops(glcm, 'Correlation');
        resultCell{i,find(ismember(Titles,'Correlation'))} = resultStruct.Correlation;
    end
    
    % HOMOGENEITY
    if get(handles.checkbox_homogeneity,'Value') == 1
        resultStruct = graycoprops(glcm, 'Homogeneity');
        resultCell{i,find(ismember(Titles,'Homogeneity'))} = resultStruct.Homogeneity;
    end
    
    % FAST FOURIER TRANSFORM
    if get(handles.checkbox_fft,'Value') == 1
    end
    
    % DISCRETE WAVELET TRANSFORM
    if get(handles.checkbox_dwt,'Value') == 1
    end
    
    % LOCAL BINARY PATTERN
    if get(handles.checkbox_lbp,'Value') == 1
        %resultCell{i,13} = lbp(currentROIvalues(:));
    end
end


% Saving to .xsl file starts here.
strComputeROIfeatures = ['Saving results to Excel file '];
waitbar(1,hwb,strComputeROIfeatures);

ImageSeries = handles.study.imageSeriesList{handles.study.imageSeriesId};

if ~exist(handles.study.pathName, 'dir')
    mkdir(handles.study.pathName);
end

if ~exist(strcat(handles.study.pathName,'\',ImageSeries.name), 'dir')
    mkdir(handles.study.pathName,ImageSeries.name);
end

filename = strcat(handles.study.pathName,'\',...
        'Study_',handles.study.name,'_features','.xls');

titleRange = strcat('A1:', char(64)+size(Titles,2),'1');
[status,message] = xlswrite(filename,Titles,ImageSeries.name,titleRange);
[status,message] = xlswrite(filename,resultCell,ImageSeries.name,'A2');

if ~status
    close(hwb);
    error{1} = 'Unable to save to location:';
    error{2} = filename;
    error{3} = '';
    error{4} = message.message;
    warndlg(error, 'Error in saving parameters', 'modal');
    uiwait(gcf);
else
    close(hwb);
    modaldlgTitle = 'Confirm opening result file';
    modaldlgString = 'Open created Excel file?';
    
    user_response = modaldlg('Title', modaldlgTitle, 'String', modaldlgString);
    switch lower(user_response)
        case 'no'
        case 'yes'
            winopen(filename)
    end
    
end

handles.output = hObject;
guidata(hObject, handles);
close(getappdata(0, 'hFeatures'));

% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(getappdata(0, 'hFeatures'));


% --- Executes for each ROI in roiList in pushbutton_compute_Callback
function currentROI = getROIValues(study, index)

ROIs = study.imageSeriesList{study.imageSeriesId}.roiList;

switch ROIs{index}.roiShape
    case 'rectangular'
        
        % x = the right image x-coordinates
        xMin = ceil(ROIs{index}.roiCoordinates(1,1,3));
        xMax = floor(ROIs{index}.roiCoordinates(3,1,3));
        %
        % y = the right image y-coordinates
        yMin = ceil(ROIs{index}.roiCoordinates(1,2,3));
        yMax = floor(ROIs{index}.roiCoordinates(3,2,3));
        
        % z = the center image x-coordinates
        zMin = ceil(ROIs{index}.roiCoordinates(1,1,2));
        zMax = floor(ROIs{index}.roiCoordinates(3,1,2));
        
        currentImage = study.imageSeriesList{study.imageSeriesId}.stack;
        currentROI = currentImage(yMin:yMax, xMin:xMax, zMin:zMax);
        
    case 'ellipsoid'
        
end


% --- Executes on button press in checkbox_coocc.
function checkbox_coocc_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_coocc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_coocc


% --- Executes on button press in checkbox_lbp.
function checkbox_lbp_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_lbp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_lbp


% --- Executes on button press in checkbox_contrast.
function checkbox_contrast_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_contrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_contrast


% --- Executes on button press in checkbox_correlation.
function checkbox_correlation_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_correlation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_correlation


% --- Executes on button press in checkbox_homogeneity.
function checkbox_homogeneity_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_homogeneity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_homogeneity


% --- Executes on button press in checkbox_kurtosis.
function checkbox_kurtosis_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_kurtosis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_kurtosis
