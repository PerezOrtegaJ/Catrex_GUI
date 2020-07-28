function varargout = Catrex_GUI(varargin)
% CATREX_GUI MATLAB code for Catrex_GUI.fig
%      CATREX_GUI, by itself, creates a new CATREX_GUI or raises the existing
%      singleton*.
%
%      H = CATREX_GUI returns the handle to a new CATREX_GUI or the handle to
%      the existing singleton*.
%
%      CATREX_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CATREX_GUI.M with the given input arguments.
%
%      CATREX_GUI('Property','Value',...) creates a new CATREX_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Catrex_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Catrex_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Catrex_GUI

% Last Modified by GUIDE v2.5 09-Jan-2020 17:12:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Catrex_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @Catrex_GUI_OutputFcn, ...
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

function Catrex_GUI_OpeningFcn(hObject,~,handles,varargin)
handles.output = hObject;
guidata(hObject, handles);

function varargout = Catrex_GUI_OutputFcn(~,~,handles) 
varargout{1} = handles.output;

%% -- General functions --
%% Initialize data
function handles = Initialize_Data(hObject,handles)
% Initialize handles
handles.ViewKalman = false;
handles.MinMax = [0 255];
handles.MinMaxKalman = [];
guidata(hObject,handles)

% Read data
data = Read_Data(handles.name);

% Set values of the slider
nFrames = data.Movie.Frames;
set(handles.sldImage,'Value',1)
set(handles.sldImage,'enable','on')
set(handles.sldImage,'Max',nFrames)
set(handles.sldImage,'Min',1)
if(nFrames>1)
    set(handles.sldImage, 'SliderStep', [1/(nFrames-1) 10/(nFrames-1)]);
else
    set(handles.sldImage, 'SliderStep', [1 1]);
end
addlistener(handles.sldImage,'Value','PostSet',...
    @(~,~)Catrex_GUI('sldImage_Moving',guidata(hObject)));

% Enable menu
set(handles.mnuView,'Enable','on')
set(handles.mnuProcess,'Enable','on')
set(handles.mnuExport,'Enable','on')

% Check the current menu item
Uncheck_Views(handles)

% Check if variable contains images
if isfield(data.Movie,'Images')
    % Get min a max from video
    handles.MinMax = [min(data.Movie.Images(:)) max(data.Movie.Images(:))];
    if Exist_Field(data,'Kalman')
       handles.MinMaxKalman = [min(data.Movie.Kalman(:)) max(data.Movie.Kalman(:))];
    end
    % Get the first image
    image = data.Movie.Images(:,:,1);
    set(handles.btnVideo,'enable','on')
    set(handles.btnFiltered,'enable','on')
    set(handles.btnVideo,'Checked','on')
else
    % Get the standar deviation image
    image = cast(rescale(data.Movie.ImageAverage)*255,'uint8');
    
    set(handles.btnVideo,'enable','off')
    set(handles.btnFiltered,'enable','off')
    set(handles.sldImage,'enable','off')
    set(handles.btnAverage,'Checked','on')
end

% Plot image
hImage = imshow(image,'parent',handles.axImage);
set(hImage,'ButtonDownFcn',{@image_ButtonDown,handles});

% Set the file name in the title
title = ['/' num2str(nFrames) ' - ' data.Movie.FileName ' - Catrex GUI'];
set(handles.figImage,'name',['1' title])

% Enable cell slider if transients
if isfield(data,'Transients')
    Enable_Cell_Slider(handles)
else
    set(handles.sldCell,'enable','off')
end

% Save changes in handles
handles.hImage = hImage;
handles.title = title;
guidata(hObject,handles)

%  Update first image
%sldImage_Moving(handles)
%guidata(hObject,handles)


%% Read from worspace
function data = Read_Data(name)
if evalin('base',['exist(''' name ''')'])
    data = evalin('base',name);
else
    error('There is no data to read.')
end

%% Write in workspace
function Write_Data(data)
name = data.Movie.DataName;
assignin('base',['data_' name],data);

%% Exist field
function exist_field = Exist_Field(data,field)
switch (field)
    % Inside ROIs field
    case {'XCorr','XY','CellRadius','AuraRadius','Accuracy','SpatialMask'}
        if isfield(data,'ROIs')
            if isfield(data.ROIs,field)
                exist_field = true;
            else
                exist_field = false;
            end
        else
            exist_field = false;
        end
    % Inside Movie field
    case {'ImageSTD','FPS','Norm','Kalman','Summary','PNR'}
        if isfield(data.Movie,field)
            exist_field = true;
        else
            exist_field = false;
        end
    otherwise
        exist_field = false;
end

%% Remove data
function data = Remove_Data(data,field)
switch (field)
    case {'Norm','NormMax','ImageAverage','ImageSTD'}
        if isfield(data.Movie,field)
            data.Movie = rmfield(data.Movie,field);
        end
    case {'XCorr','SpatialMask'}
        if isfield(data,'ROIs')
            if isfield(data.ROIs,field)
                data.ROIs = rmfield(data.ROIs,field);
            end
        end
    case {'Transients'}
        if isfield(data,field)
            data = rmfield(data,field);
        end
end

%% Uncheck menu items
function Uncheck_Views(handles)
set(handles.btnVideo,'Checked','off')
set(handles.btnFiltered,'Checked','off')
set(handles.btnAverage,'Checked','off')
set(handles.btnImageSTD,'Checked','off')
set(handles.btnImagePSNR,'Checked','off')
set(handles.btnImageSVD,'Checked','off')
set(handles.btnMask,'Checked','off')

%% Normalize movie
function data = Compute_Normalization(data)
tic; disp('Normalizing movie...')
[normalized,maxMovie,meanMovie,stdMovie,PSNR] = Normalize_Movie(data.Movie.Images);

% Write data
data.Movie.Norm = normalized;
data.Movie.ImageMaximum = maxMovie;
data.Movie.ImageAverage = meanMovie;
data.Movie.ImageSTD = stdMovie;
data.Movie.ImagePSNR = PSNR;
Write_Data(data)

t=toc; disp(['   Done (' num2str(t) ' seconds)'])

%% Enable cell slider
function Enable_Cell_Slider(handles)
% Read data
data = Read_Data(handles.name);

% Set values of the slider
n_cells = data.Transients.Cells;
set(handles.sldCell,'Value',1)
set(handles.sldCell,'Max',n_cells)
set(handles.sldCell,'Min',1)
if(n_cells>1)
    set(handles.sldCell, 'SliderStep', [1/(n_cells-1) 10/(n_cells-1)]);
    set(handles.sldCell,'enable','on')
else
    set(handles.sldCell, 'SliderStep', [1 1]);
    set(handles.sldCell,'enable','off')
end

%% Remove transients
function Remove_All_Transients(handles)
% Read data
data = Read_Data(handles.name);

% Remove field
data = Remove_Data(data,'Transients');
Write_Data(data)

% Delete ROIs cell
if isfield(handles,'CellROI')
    axes(handles.axImage)
    delete(handles.CellROI)
end

% Disable cell slider
set(handles.sldCell,'Enable','off')

%% -- Callbacks --
%% Moving frame slider
function sldImage_Moving(handles)
% Read data
data = Read_Data(handles.name);

% Round value
value = round(get(handles.sldImage,'Value'));
set(handles.sldImage,'Value',value)

% Plot the current image
if handles.ViewKalman
    image = data.Movie.Kalman(:,:,value);
    min_max_data = handles.MinMaxKalman;
else
    image = data.Movie.Images(:,:,value);
    min_max_data = handles.MinMax;
end

% Enhance image
image = Equalize_Image(image,min_max_data);

if isvalid(handles.hImage)
    set(handles.hImage,'CData',image);
else
    % Plot the first image
    hImage = imshow(image,'parent',handles.axImage);

    % Save changes in handles
    handles.hImage = hImage;
    guidata(handles.sldImage,handles)
end

set(handles.figImage,'name',[num2str(value) handles.title])

%% Moving cell slider
function sldCell_Callback(hObject,~,handles)
% Read data
data = Read_Data(handles.name);

if isfield(data,'Transients')    

    % Round value
    value = round(get(hObject,'Value'));
    set(hObject,'Value',value)

    alpha = ones(data.Movie.Height,data.Movie.Width);
    alpha(data.Neurons(value).pixels) = 0.5;
    if isa(handles.axImage.Children(1),'matlab.graphics.primitive.Image')
        handles.axImage.Children(1).AlphaData = alpha;
    elseif isa(handles.axImage.Children(2),'matlab.graphics.primitive.Image')
        handles.axImage.Children(2).AlphaData = alpha;
    elseif isa(handles.axImage.Children(3),'matlab.graphics.primitive.Image')
        handles.axImage.Children(3).AlphaData = alpha;
    end
    
    inference = [];
    model = [];
    raster = [];
    stim = [];
    loco = [];
    
    if isfield(data.Transients,'Inference')
        inference = data.Transients.Inference(value,:);
        model = data.Transients.Model(value,:);
        if isfield(data.Transients,'Raster')
            raster = data.Transients.Raster(value,:);
        end
    end
    
    if isfield(data,'VoltageRecording')
        if isfield(data.VoltageRecording,'Stimuli')
            stim = data.VoltageRecording.Stimuli;
        end
        if isfield(data.VoltageRecording,'Locomotion')
            loco = data.VoltageRecording.Locomotion;
        end
    end
    
    % Plot transients
    Plot_Single_Transient(data.Transients.Raw(value,:),...
        data.Transients.Smoothed(value,:)-min(data.Transients.Smoothed(value,:)),...
        data.Transients.F0(value,:),inference,model,raster, value,handles.name,...
        data.Movie.FPS,get(handles.sldImage,'value'),stim,loco)
                
%     Plot_Single_Transient(data.Transients.Raw(value,:),data.Transients.Filtered(value,:),...
%         data.Transients.F0(value,:),value,handles.name,data.Movie.FPS,get(handles.sldImage,'value'))

end

%% -- Menu File --
%% Open video from file
function handles = btnOpenVideo_Callback(hObject,~,handles)
% Open dialog box
[fileName,path] = uigetfile('*.tif;*.avi','Select video.');
file = [path fileName];

if path 
    if strcmp(fileName(end-2:end),'avi')
        % Read AVI file
        [mov,prop] = Read_AVI_File(file);
    else
        % Read TIF file
        [mov,prop] = Read_Tiff_File(file);
    end
    
    % Assign data name
    % for windows
    id_path = find(path=='\');
    if isempty(id_path)
        % for mac
        id_path = find(path=='/');
    end
    path_name = path(id_path(end-2):end);
    name = fileName(1:end-4);
    name = Validate_Name([path_name '_' name]);
    
    % Write in handles
    handles.name = ['data_' name];
    guidata(hObject,handles)
    
    % Write data in workspace
    data.Movie.FilePath = path;
    data.Movie.FileName = fileName;
    data.Movie.DataName = name;
    data.Movie.Width = prop.width;
    data.Movie.Height = prop.height;
    data.Movie.Depth = prop.depth;
    data.Movie.Frames = prop.frames;
    data.Movie.Images = mov;
    
    % defaults
    data.ROIs.CellRadius = 3;
    data.ROIs.AuraRadius = 30;
    data.Movie.FPS = 12.3457; %12.3457 (81ms period) or 12.5 (80ms period)
    %data.Movie.FPS = 12.5;
    Write_Data(data)
    
    % Initialize properties
    handles = Initialize_Data(hObject,handles);
    guidata(hObject,handles)
    
     % Find voltage recording
    fileVoltage = [file(1:end-3) 'csv'];
    if exist(fileVoltage,'file')
        handles.fileVoltage = fileVoltage;
        handles.fileVoltageName = [fileName(1:end-3) 'csv'];
        btnAddVrecording_Callback(hObject,[],handles);
    end
end
handles.path = path;

%% Open and analize video from file
function btnOpenAnalizeVideo_Callback(hObject,~,handles)
% Open video
handles = btnOpenVideo_Callback(handles.btnOpenVideo,[],handles);

if handles.path
    % Find cells
    handles = btnFindCells_Callback(handles.btnFirstSearch,[],handles);

    % Get Raster
    btnRaster_Callback(handles.btnRaster,[],handles)

    % Remove inactive neurons
    btnRemoveInactive_Callback([],[],handles)

    % Get tunning
    data = Read_Data(handles.name);
    if isfield(data,'VoltageRecording')
        if nnz(data.VoltageRecording.Stimuli)
            btnNeuralTuning_Callback([],[],handles)
        end
    end
    
    % Save results
    SaveResults(handles)
end

%% Open video from workspace
function btnOpenWorkspace_Callback(hObject,~,~)
% Open GUI for loading
uiwait(Load_From_Workspace(hObject))

% Load new data
handles = guidata(hObject);
if isfield(handles,'name')
    % Initialize properties
    Initialize_Data(hObject,handles);
end

%% Save results selecting path
function SaveResults(handles)
% Read data
data = Read_Data(handles.name);

% Save data in file
tic
disp('Saving results in file (without video)...')
data.Movie = rmfield(data.Movie,'Images');
if isfield(data.Movie,'Norm')
    data.Movie = rmfield(data.Movie,'Norm');
end
if isfield(data.Movie,'Kalman')
    data.Movie = rmfield(data.Movie,'Kalman');
end
if isfield(data,'ROIs')
    data.ROIs = rmfield(data.ROIs,'SpatialMaskSmoothed');
    data.ROIs = rmfield(data.ROIs,'SpatialMask');
    data.ROIs = rmfield(data.ROIs,'CellMasks');
    data.ROIs = rmfield(data.ROIs,'CellWeightedMasks');
    data.ROIs = rmfield(data.ROIs,'AuraMasks');
end
    
eval([data.Movie.DataName '=data;'])
save(data.Movie.FileName(1:end-4),data.Movie.DataName)
    
t = toc; disp(['   Done (' num2str(t) ' seconds)'])

%% Save results selecting path
function btnSaveResults_Callback(~,~,handles)
 % Read data
data = Read_Data(handles.name);

% Select path
[file,path] = uiputfile({'*.mat','MATLAB variable files (*.mat)'},'Save results in file...',data.Movie.FileName(1:end-4));

if path
    % Save data in file
    tic
    disp('Saving results in file (without video)...')
    data.Movie = rmfield(data.Movie,'Images');
    if isfield(data.Movie,'Norm')
        data.Movie = rmfield(data.Movie,'Norm');
    end
    if isfield(data.Movie,'Kalman')
        data.Movie = rmfield(data.Movie,'Kalman');
    end
    if isfield(data,'ROIs')
        data.ROIs = rmfield(data.ROIs,'SpatialMaskSmoothed');
        data.ROIs = rmfield(data.ROIs,'SpatialMask');
        data.ROIs = rmfield(data.ROIs,'CellMasks');
        data.ROIs = rmfield(data.ROIs,'CellWeightedMasks');
        data.ROIs = rmfield(data.ROIs,'AuraMasks');
    end

    eval([data.Movie.DataName '=data;'])
    save(data.Movie.FileName(1:end-4),data.Movie.DataName)

    t = toc; disp(['   Done (' num2str(t) ' seconds)'])
end

%% Load data from workspace
function btnLoadWorkspace_Callback(hObject,~,~)
% Open GUI for loading
uiwait(Load_From_Workspace(hObject))

% Load new data
handles = guidata(hObject);
if isfield(handles,'name')
%     if ~strcmp(handles.name,name)
        % Initialize properties
        Initialize_Data(hObject,handles);
%     end
end

%% Close the GUI
function btnExit_Callback(~,~,~)
close

%% -- Menu View --
%% Reset enhancing
function btnResetEnhance_Callback(~,~,handles)
if strcmp(get(handles.btnVideo,'checked'),'on') || ...
   strcmp(get(handles.btnFiltered,'checked'),'on')
    % Read data
    data = Read_Data(handles.name);
    
    if handles.ViewKalman
        min_max_data = [min(data.Movie.Kalman(:)) max(data.Movie.Kalman(:))];
        handles.MinMaxKalman = min_max_data;
    else
        min_max_data = [min(data.Movie.Images(:)) max(data.Movie.Images(:))];
        handles.MinMax = min_max_data;
    end
    guidata(handles.sldImage,handles);
    sldImage_Moving(handles)
end

%% Enhance image
function btnEnhance_Callback(~,~,handles)
if strcmp(get(handles.btnVideo,'checked'),'on') || ...
        strcmp(get(handles.btnFiltered,'checked'),'on')
    % Read data
    data = Read_Data(handles.name);
    
    % Get image
    if handles.ViewKalman
        value = round(get(handles.sldImage,'Value'));
        image = data.Movie.Kalman(:,:,value);
    else
        value = round(get(handles.sldImage,'Value'));
        image = data.Movie.Images(:,:,value);
    end

    % Get the min max values to enhance
    min_max_data = minmax(image(:)');
    average = mean(image(:)');
    std_im = std(single(image(:)'));
    min_im = average-4*std_im;
    max_im = average+4*std_im;
    if min_im<min_max_data(1); min_im = min_max_data(1); end
    if max_im>min_max_data(2); max_im = min_max_data(2); end
    min_max_data = [min_im max_im];

    % Plot the current image
    if handles.ViewKalman
        handles.MinMaxKalman = min_max_data;
        guidata(handles.sldImage, handles);
    else
        handles.MinMax = min_max_data;
        guidata(handles.sldImage, handles);
    end
    sldImage_Moving(handles)
end

%% 1. View video
function btnVideo_Callback(hObject,~,handles)
if strcmp(get(hObject,'Checked'),'off')
    % Check the current menu item
    Uncheck_Views(handles)
    set(hObject,'Checked','on')

    % Set properties
    set(handles.sldImage,'Enable','on')
    handles.ViewKalman = false;
    guidata(hObject,handles)
    
    % Plot the current image
    sldImage_Moving(handles)
end

%% 2. View Kalman filter
function btnFiltered_Callback(hObject,~,handles)
if strcmp(get(hObject,'Checked'),'off')
    % Read data
    data = Read_Data(handles.name);
    
    % Check if Kalman
    if ~Exist_Field(data,'Kalman')
        tic; disp('Computing Kalman filter...')
        data.Movie.Kalman = Kalman_Stack_Filter(data.Movie.Images,0.95);
        Write_Data(data)
        t=toc; disp(['   Done (' num2str(t) ' seconds)'])
    end

    % Check the current menu item
    Uncheck_Views(handles)
    set(hObject,'Checked','on')

    % Set properties
    set(handles.sldImage,'Enable','on')
    
    % Write in handles
    handles.ViewKalman = true;
    guidata(hObject, handles);
    
    % Plot the current image
    sldImage_Moving(handles)
end

%% 3. View average image
function btnAverage_Callback(hObject,~, handles)
if strcmp(get(hObject,'Checked'),'off')
    % Read data
    data = Read_Data(handles.name);

    % Check the current menu item
    Uncheck_Views(handles)
    set(hObject,'Checked','on')

    % Check if normalized
    if ~isfield(data.Movie,'ImageAverage')
        data = Compute_Normalization(data);
    end
    
    % Plot summary
    image_class = class(handles.hImage.CData);
    factor = double(intmax(image_class));
    image = cast(rescale(data.Movie.ImageAverage)*factor,image_class);
    if isvalid(handles.hImage)
        set(handles.hImage,'CData',image);
    else
        % Plot the first image
        hImage = imshow(image,'parent',handles.axImage);

        % Save changes in handles
        handles.hImage = hImage;
        guidata(hObject,handles)
    end

    % Change title
    start = length(num2str(data.Movie.Frames))+2;
    set(handles.figImage,'name',['Average' handles.title(start:end)])
    
    % Set properties
    set(hObject,'Checked','on')
    set(handles.sldImage,'Enable','off')    
end

%% 4. View std image
function btnImageSTD_Callback(hObject,~,handles)
if strcmp(get(hObject,'Checked'),'off')
    % Read data
    data = Read_Data(handles.name);

    % Check the current menu item
    Uncheck_Views(handles)
    set(hObject,'Checked','on')

    % Check if normalized
    if ~isfield(data.Movie,'ImageSTD')
        data = Compute_Normalization(data);
    end
    
    % Plot summary
    image_class = class(handles.hImage.CData);
    factor = double(intmax(image_class));
    image = cast(rescale(data.Movie.ImageSTD)*factor,image_class);
    if isvalid(handles.hImage)
        set(handles.hImage,'CData',image);
    else
        % Plot the first image
        hImage = imshow(image,'parent',handles.axImage);

        % Save changes in handles
        handles.hImage = hImage;
        guidata(hObject,handles)
    end

    % Change title
    start = length(num2str(data.Movie.Frames))+2;
    set(handles.figImage,'name',['Standard deviation' handles.title(start:end)])
    
    % Set properties
    set(hObject,'Checked','on')
    set(handles.sldImage,'Enable','off')    
end

%% 5. Peak signal to noise ration (PSNR)
function btnImagePSNR_Callback(hObject,~,handles)
if strcmp(get(hObject,'Checked'),'off')
    % Read data
    data = Read_Data(handles.name);

    % Check the current menu item
    Uncheck_Views(handles)
    set(hObject,'Checked','on')

    % Check if normalized
    if ~isfield(data.Movie,'ImagePSNR')
        data = Compute_Normalization(data);
    end
    
    % Plot summary
    image_class = class(handles.hImage.CData);
    factor = double(intmax(image_class));
    image = cast(rescale(data.Movie.ImagePSNR)*factor,image_class);
    if isvalid(handles.hImage)
        set(handles.hImage,'CData',image);
    else
        % Plot the first image
        hImage = imshow(image,'parent',handles.axImage);

        % Save changes in handles
        handles.hImage = hImage;
        guidata(hObject,handles)
    end

    % Change title
    start = length(num2str(data.Movie.Frames))+2;
    set(handles.figImage,'name',['Peak signal-to-noise ratio (PSNR)' handles.title(start:end)])
    
    % Set properties
    set(hObject,'Checked','on')
    set(handles.sldImage,'Enable','off')    
end

%% 6. View summary image
function btnImageSVD_Callback(hObject,~,handles)
if strcmp(get(hObject,'Checked'),'off')
    % Read data
    data = Read_Data(handles.name);

    % Check the current menu item
    Uncheck_Views(handles)
    set(hObject,'Checked','on')

    % Check if normalized
    if ~Exist_Field(data,'Summary')
        
        % Check if normalized
        if ~Exist_Field(data,'Norm')
            Compute_Normalization(data);
            data = Read_Data(handles.name);
        end
        
        if Exist_Field(data,'SpatialMask')
             U_smoothed = data.ROIs.SpatialMaskSmoothed;
        else
            % Get spatial mask
            tic; disp('Computing spatial mask...')
            bin_seconds = 1;
            [U_smoothed,U_raw] = Get_Spatial_Mask(data.Movie.Images,...
                data.Movie.Norm,bin_seconds,data.Movie.FPS);

            data.ROIs.SpatialMaskSmoothed = U_smoothed;
            data.ROIs.SpatialMask = U_raw;
            Write_Data(data)
            t=toc; disp(['   Done (' num2str(t) ' seconds)'])
        end
        
        % Get Summary
        tic; disp(['Computing summary image...'])
        summary = Get_Summary_Image(U_smoothed,1);
        t=toc; disp(['   Done (' num2str(t) ' seconds)'])
        
        % Write data
        data.Movie.Summary = summary;
        Write_Data(data)
    end
    
    % Plot summary
    image_class = class(handles.hImage.CData);
    factor = double(intmax(image_class));
    image = cast(rescale(data.Movie.Summary)*factor,image_class);
    if isvalid(handles.hImage)
        set(handles.hImage,'CData',image);
    else
        % Plot the first image
        hImage = imshow(image,'parent',handles.axImage);

        % Save changes in handles
        handles.hImage = hImage;
        guidata(hObject,handles)
    end

    % Change title
    start = length(num2str(data.Movie.Frames))+2;
    set(handles.figImage,'name',['Summary' handles.title(start:end)])
    
    % Set properties
    set(hObject,'Checked','on')
    set(handles.sldImage,'Enable','off')    
end

%% 7. View cells mask
function handles = btnMask_Callback(hObject,~,handles)
if strcmp(get(hObject,'Checked'),'off')
    % Read data
    data = Read_Data(handles.name);

    % Check the current menu item
    Uncheck_Views(handles)
    set(hObject,'Checked','on')

    % Check PSNR from transients
    if isfield(data,'Transients') 
        if isfield(data.Transients,'PSNR')
            if length(data.Transients.PSNR)==length(data.Neurons)
                mask = Get_ROIs_Image(data.Neurons,data.Movie.Width,...
                    data.Movie.Height,data.Transients.PSNR);
            else
                mask = Get_ROIs_Image(data.Neurons,data.Movie.Width,...
                    data.Movie.Height);
            end
        else
            mask = Get_ROIs_Image(data.Neurons,data.Movie.Width,...
                data.Movie.Height);
        end
    else
        if isfield(data,'Neurons')
            mask = Get_ROIs_Image(data.Neurons,data.Movie.Width,...
                data.Movie.Height);
        else
            error('Ther are no ROIs to show!')
        end
    end
        
    % Get image with the same depth
    %image_class = class(handles.hImage.CData);
    image_class = 'uint8';
    factor = double(intmax(image_class));
    image = cast(rescale(mask)*factor,image_class);
    
    % Plot cross-correlation improved
    if isfield(handles,'hImage')
        if isvalid(handles.hImage)
            set(handles.hImage,'CData',image);
        else
            % Plot the first image
            hImage = imshow(image,'parent',handles.axImage);

            % Save changes in handles
            handles.hImage = hImage;
            guidata(hObject,handles)
        end
    else
        % Plot the first image
        hImage = imshow(image,'parent',handles.axImage);

        % Save changes in handles
        handles.hImage = hImage;
        guidata(hObject,handles)
    end
    
    % Write data
    data.Movie.ImageMask = image;
    Write_Data(data);
    
    % Change title
    start = length(num2str(data.Movie.Frames))+2;
    set(handles.figImage,'name',['Mask' handles.title(start:end)])
    
    % Set properties
    set(hObject,'Checked','on')
    set(handles.sldImage,'Enable','off')
end

%% -- Menu Process --
%% 1. Define:
%% Set Cell radius
function btnCellRadius_Callback(~,~,handles)
% Read data
data = Read_Data(handles.name);
        
% Configure dialog
prompt = {'Enter the cell radius'};
title = 'Enter parameters';
dims = [1 50];

% Set the current value as default
default_input = {num2str(data.ROIs.CellRadius)};

% Show dialog
answer = inputdlg(prompt,title,dims,default_input);

% Apply change
if ~isempty(answer)
    cell_radius = str2num(answer{1});
    if ~isempty(cell_radius) && cell_radius>0
        if cell_radius ~= data.ROIs.CellRadius
            % Set data
            data.ROIs.CellRadius = cell_radius;
            disp(['Cell radius was set to: ' num2str(cell_radius)])
            
            % Write data
            Write_Data(data);
        end
    end
end

%% Test cell radiuses
function btnTestRadiuses_Callback(~,~,handles)

% Read/Get the summary image
set(handles.btnImageSVD,'checked','off')
btnImageSVD_Callback(handles.btnImageSVD,[],handles)

% Read data
data = Read_Data(handles.name);

% Test different radiuses
Test_Cells_Radius(data.Movie.Summary,[2:14 15:5:65])

%% Set Aura radius
function btnAuraRadius_Callback(~,~,handles)
% Read data
data = Read_Data(handles.name);
        
% Configure dialog
prompt = {'Enter the aura radius'};
title = 'Enter parameters';
dims = [1 50];

% Set the current value as default
default_input = {num2str(data.ROIs.AuraRadius)};

% Show dialog
answer = inputdlg(prompt,title,dims,default_input);

% Apply change
if ~isempty(answer)
    aura_radius = str2num(answer{1});
    if ~isempty(aura_radius) && aura_radius>1
        if aura_radius ~= data.ROIs.AuraRadius
            % Set data
            data.ROIs.AuraRadius = aura_radius;
            disp(['Aura radius was set to: ' num2str(aura_radius)])

            % Write data
            Write_Data(data)
        end
    end
end

%% Set FPS
function btnFPS_Callback(~,~,handles)
% Read data
data = Read_Data(handles.name);
        
% Configure dialog
prompt = {'Enter the number of frames per second'};
title = 'Enter parameters';
dims = [1 50];

% Set the current value as default
default_input = {num2str(data.Movie.FPS,'%.10f')};

% Show dialog
answer = inputdlg(prompt,title,dims,default_input);

% Apply change
if ~isempty(answer)
    fps = str2double(answer{1});
    if ~isempty(fps)
        if fps ~= data.Movie.FPS
            % Set data
            data.Movie.FPS = fps;
            disp(['Frames per second was set to: ' num2str(fps)])

            % Write data
            Write_Data(data)
        end
    end
end

%% Add voltage recording
function btnAddVrecording_Callback(hObject,~,handles)
% Read data
data = Read_Data(handles.name);
fps = data.Movie.FPS;
samples = data.Movie.Frames;

if strcmp(get(hObject,'tag'),'btnAddVrecording')
    [fileName,path] = uigetfile({'*.csv','CSV files (*.csv)'},'Select file.');
    file = [path fileName];
else
    file = handles.fileVoltage;
    fileName = handles.fileVoltageName;
end

if ~isempty(file)
    tic; disp(['Loading ' fileName '...'])

    % Get data
    data.VoltageRecording = Read_Voltage_Recording(file,1/fps,samples);
    % Write data
    Write_Data(data)
    
    t=toc; disp(['   Done (' num2str(t) ' seconds)'])
end

%% 2. Motion correction
function btnRegistration_Callback(hObject,~,handles)
tic

if strcmp('btnRegistrationRigid',get(hObject,'tag'))
    nonrigid = false;
else
    nonrigid = true;
end

if nonrigid
    disp('Adjusting motion (non-rigid)...')
else
    disp('Adjusting motion (rigid)...')
end

% Read data
data = Read_Data(handles.name);
video = data.Movie.Images;

% Check if exist locomotion
if ~isfield(data,'VoltageRecording')
    disp('   Error: The voltage recording is missing')
    return;
end 

% Fast registration
video_registered = Fast_Registration(video,...
    data.VoltageRecording.Locomotion,data.Movie.FPS,nonrigid);
t=toc; disp(['   Done (' num2str(t) ' seconds)'])

% If previously corrected
if ~isfield(data.Movie,'BeforeRegistration')
    data.Movie.BeforeRegistration = video;
end

% Write data
data.Movie.Images = video_registered;
if nonrigid
    data.Movie.Registration = 'non-rigid';
else
    data.Movie.Registration = 'rigid';
end

% Remove data computed previously
Remove_All_Transients(handles)
data = Remove_Data(data,'Norm');
data = Remove_Data(data,'NormMax');
data = Remove_Data(data,'ImageAverage');
data = Remove_Data(data,'ImageSTD');
data = Remove_Data(data,'SpatialMask');
Write_Data(data)

% Write in handles
Uncheck_Views(handles)
set(handles.btnVideo,'Checked','on')
handles.ViewKalman = false;
guidata(hObject,handles)

% Update image
sldImage_Moving(handles)

%% 3. Find cells
% Based on Suite2P algorithm
function handles = btnFindCells_Callback(hObject, ~, handles)

% Read data
data = Read_Data(handles.name);
height = data.Movie.Height;
width = data.Movie.Width;
cellRadius = data.ROIs.CellRadius;
cellDiameter = cellRadius*2;

% Check if normalized
if ~Exist_Field(data,'Norm')
    Compute_Normalization(data);
    data = Read_Data(handles.name);
end

% Check if exist spatial mask
if Exist_Field(data,'SpatialMask')
     U_smoothed = data.ROIs.SpatialMaskSmoothed;
     U_raw = data.ROIs.SpatialMask;
else
    tic; disp('Computing spatial mask...')
    bin_seconds = 1;
    [U_smoothed,U_raw] = Get_Spatial_Mask(data.Movie.Images,...
        data.Movie.Norm,bin_seconds,data.Movie.FPS);

    data.ROIs.SpatialMaskSmoothed = U_smoothed;
    data.ROIs.SpatialMask = U_raw;
    Write_Data(data)
    t=toc; disp(['   Done (' num2str(t) ' seconds)'])
end

% Find cells
if strcmp(get(hObject,'tag'),'btnFirstSearch')
    tic; disp('Finding cells...')
    [neuronalData,summary,options] = Find_Cells_J2P(U_smoothed,U_raw,cellDiameter);

    % Old search
%     [neuronalData,summary,convImage,convDiscarded] = Find_Cells_Suit2P(U_smoothed(:,:,1:50),...
%         U_raw(:,:,1:50),cellDiameter);

    disp(['   ROIs found: ' num2str(length(neuronalData))])
    
    [neuronalData,criteria] = EvaluateCells(neuronalData,width,height,cellRadius);
    disp(['   ROIs after evaluation: ' num2str(length(neuronalData))])
elseif strcmp(get(hObject,'tag'),'btn5Iterations')
    tic; disp('Finding more cells...')
    neuronalData = data.Neurons;
    nNeurons = length(neuronalData);
    if isfield(neuronalData,'PSNR')
        neuronalData = rmfield(neuronalData,'PSNR');
    end
    options = data.ROIs.SearchOptions;
    
    for i = 1:5
        disp(['Iteration ' num2str(num2str(i)) '/5'])
        [neuronalDataPart,summary,options] = Find_Cells_J2P(U_smoothed,U_raw,cellDiameter,options);
        [neuronalDataPart,criteria] = EvaluateCells(neuronalDataPart,width,height,cellRadius);
        neuronalData = [neuronalData neuronalDataPart];

        % Evaluate overlapping between cells
        maxOverlaping = 0.6;
        neuronalData = Join_Overlaped_Neurons(neuronalData,maxOverlaping,width,height);
        neuronalData = Get_Overlaping(neuronalData,width,height);

        % Sort neurons
        neuronalData = Sort_Neuron_Data(neuronalData);
        nNew = length(neuronalData)-nNeurons;
        nNeurons = length(neuronalData);
        disp(['   +' num2str(num2str(nNew)) ' ROIs'])
        disp(['   ' num2str(num2str(nNeurons)) ' total ROIs'])
    end
else
    tic; disp('Finding more cells...')
    neuronalData = data.Neurons;
    if isfield(neuronalData,'PSNR')
        neuronalData = rmfield(neuronalData,'PSNR');
    end
    
    options = data.ROIs.SearchOptions;
    [neuronalDataPart,summary,options] = Find_Cells_J2P(U_smoothed,U_raw,cellDiameter,options);
    [neuronalDataPart,criteria] = EvaluateCells(neuronalDataPart,width,height,cellRadius);
    neuronalData = [neuronalData neuronalDataPart];
    
    % Evaluate overlapping between cells
    maxOverlaping = 0.6;
    neuronalData = Join_Overlaped_Neurons(neuronalData,maxOverlaping,width,height);
    neuronalData = Get_Overlaping(neuronalData,width,height);
        
    % Sort neurons
    neuronalData = Sort_Neuron_Data(neuronalData);
    disp(['   +' num2str(num2str(length(neuronalDataPart))) ' ROIs'])
    disp(['   ' num2str(num2str(length(neuronalData))) ' total ROIs'])
%     options.max_iterations = 10;
%     [neuronalData,summary,convImage,convDiscarded] = Find_Cells_Suit2P(U_smoothed,U_raw,cellDiameter,options);
end

if isfield(data,'NeuronsBeforeEvaluation')
    data = rmfield(data,'NeuronsBeforeEvaluation');
end
if isfield(data,'Transients')
    data = rmfield(data,'Transients');
end

% Write data
%data.ROIs.Criteria = criteria;
data.ROIs.SearchOptions = options;
data.XY.All = [neuronalData.x_median; neuronalData.y_median]';
data.Movie.Summary = summary;
data.Neurons = neuronalData;
Write_Data(data)

t=toc; disp(['   Done (' num2str(t) ' seconds)'])

% Update the mask cells
set(handles.btnMask,'Checked','off')
handles = btnMask_Callback(handles.btnMask,[],handles);


%% Evaluate cells
function [neuronalData,criteria] = EvaluateCells(neuronalData,width,height,cellRadius)
% Evaluate ROIs
%tic; disp('   Evaluating ROIs detected...')
minArea = pi*cellRadius^2/2;
maxArea = minArea*8;
outline = cellRadius;
%maxOverlaping = 0.6;
minCircularity = 0.2;
maxPerimeter = pi*(2*cellRadius+5);
maxEccentricity = 0.9;
neuronalData = Evaluate_Neurons(neuronalData,minArea,maxArea,minCircularity,maxPerimeter,...
    maxEccentricity,width,height,outline);

% Get overlaping
neuronalData = Get_Overlaping(neuronalData,width,height);

% Neurons with > fraction of overlaped pixels
% id = [neuronalData.overlap_fraction]>maxOverlaping;
% neuronalData(id) = [];

% Write constrains
criteria.MinimumPixels = minArea;
criteria.MaximumPixels = maxArea;
%criteria.MaximumOverlapingPixels = maxOverlaping;
criteria.MinimumCircularity = minCircularity;
criteria.Outline = outline;
%data.XY.All = [neuronalData.x_median; neuronalData.y_median]';
%disp(['   ' num2str(length(neuronalData)) ' ROIs after evaluation.'])


% Evaluate cells 
%{
%function btnEvaluateCells_Callback(~,~,handles)
% Read data
data = Read_Data(handles.name);
width = data.Movie.Width;
height = data.Movie.Height;
cellRadius = data.ROIs.CellRadius;

if isfield(data,'NeuronsBeforeEvaluation')
    neuronalData = data.NeuronsBeforeEvaluation;
else
    neuronalData = data.Neurons;
    
    % Back up before evaluate
    data.NeuronsBeforeEvaluation = neuronalData;
end

% Check if normalized
% Evaluate ROIs
tic; disp('Evaluating ROIs detected...')
minArea = pi*cellRadius^2/3;
maxArea = minArea*4;
outline = 2;
maxOverlaping = 0.6;
minCircularity = 0.3; 
neuronalData = Evaluate_Neurons(neuronalData,minArea,maxArea,minCircularity,width,height,...
    outline);

% Evaluate overlapping between cells
neuronalData = Join_Overlaped_Neurons(neuronalData,maxOverlaping,width,height);

% Get overlaping
neuronalData = Get_Overlaping(neuronalData,width,height);
 
% % Neurons with > fraction of overlaped pixels
% id = [neuronalData.overlap_fraction]>maxOverlaping;
% neuronalData(id) = [];

% Write constrains
data.ROIs.MinimumPixels = minArea;
data.ROIs.MaximumPixels = maxArea;
data.ROIs.MaximumOverlapingPixels = maxOverlaping;
data.ROIs.MinimumCircularity = minCircularity;
data.ROIs.Outline = outline;
data.XY.All = [neuronalData.x_median; neuronalData.y_median]';
data.Neurons = neuronalData;
Write_Data(data)
disp(['   ' num2str(length(neuronalData)) ' total ROIs after evaluation.'])

% Update the mask cells
set(handles.btnMask,'Checked','off')
btnMask_Callback(handles.btnMask,[],handles)
%}

%% 4. Get transients
function btnTransients_Callback(~,~,handles)
% Read data
data = Read_Data(handles.name);
width = data.Movie.Width;
height = data.Movie.Height;

if isfield(data,'Neurons')
    % Get masks
    tic; disp('Generating neuropil mask...')
    neuropil = Get_Neuropil_Mask(data.Neurons,[height width]);
    t=toc; disp(['   Done (' num2str(t) ' seconds)'])

    tic; disp('Creating cell and aura masks...')
    [cellMasks,auraMasks,cellWMasks] = Get_Neuronal_Masks(data.Neurons,neuropil,...
        data.ROIs.AuraRadius,[height width]);

    cellMaskImage = sum(cellMasks,3);
    cellWMaskImage = sum(cellWMasks,3);
    auraMaskImage = sum(auraMasks,3);
    t=toc; disp(['   Done (' num2str(t) ' seconds)'])

    % Get transient
    cells = length(data.Neurons);
    frames = data.Movie.Frames;
    estimated_time = round(cells*frames*4.6e-06);
    tic; fprintf('Computing transients from %i cells... (estimated time: %i s)\n',...
        cells,estimated_time)

    [filtered,raw,f0,field] = Get_Transients(data.Movie.Images,...
       cellWMasks,auraMasks);
   
    % Smooth transients (1 s window)
    smoothed = Smooth_Transients(filtered,round(data.Movie.FPS));

    % Get Peak signal-to-noise ratio PSNR max(S-N)/std(N)
    % based on https://en.wikipedia.org/wiki/Signal-to-noise_ratio_(imaging)
    PSNR = max((raw-f0),[],2)./std(f0,[],2);

    % Set PSNR to neural data
    for i = 1:cells
        data.Neurons(i).PSNR = PSNR(i);
    end

    % Write data in workspace
    data.ROIs.CellMasks = cellMasks;
    data.ROIs.CellWeightedMasks = cellWMasks;
    data.ROIs.AuraMasks = auraMasks;
    data.ROIs.CellMasksImage = cellMaskImage;
    data.ROIs.CellWeightedMasksImage = cellWMaskImage;
    data.ROIs.AuraMasksImage = auraMaskImage;
    data.ROIs.NeuropilMask = reshape(neuropil,height,width);
    data.Transients.Raw = raw;
    data.Transients.Filtered = filtered;
    data.Transients.Smoothed = smoothed;
    data.Transients.F0 = f0;
    data.Transients.Field = field;
    data.Transients.Cells = cells;
    data.Transients.PSNR = PSNR;
    

    Write_Data(data)

    % Update cell slider
    Enable_Cell_Slider(handles)

    t=toc; disp(['   Done (' num2str(t) ' seconds)'])
    
    % Plot all transients
    %Plot_Transients(data.Transients.Filtered,handles.name,'raster',data.Movie.FPS)
    %Save_Figure(name)
    
    % Update the mask cells
    set(handles.btnMask,'Checked','off')
    btnMask_Callback(handles.btnMask,[],handles);
else
    warning('There are no ROIs.')
end

%% 5. Get spike inference
function btnGetInference_Callback(hObject,~,handles)
% Read data
data = Read_Data(handles.name);

% Compute transients
if isfield(data,'Transients')
    cells = length(data.Neurons);
    frames = data.Movie.Frames;
    estimated_time = round(cells*frames*2.9598e-05);
    
    % dB = 20*log10(PSNR) Rose criterion: 5 is needed to distinguish features with certainty
    % Get only neurons above th (8: ~18dB; 12: ~22 dB; 20: ~26 dB)
    thPSNR = 8;
    id = find(data.Transients.PSNR>thPSNR);
    nFinal = length(id);
    
    tic; fprintf('Doing spike inference from %i of %i cells above %i PSNR... (estimated time: %i s)\n',...
            nFinal,cells,thPSNR,estimated_time)
    
    % Get spike inference
    inferenceMethod = 'foopsi';    % 'foopsi', 'oasis' or 'derivative'
    transients = data.Transients.Smoothed; % Filtered, Smoothed or Raw
    [inf,mdl] = Get_Spike_Inference(transients(id,:),inferenceMethod);
    
    % Assign to the variables
    inference = zeros(cells,frames);
    inference(id,:) = inf;
    model = zeros(cells,frames);
    model(id,:) = mdl;    
    
    % Write data
    data.Transients.Inference = inference;
    data.Transients.Model = model;
    data.Transients.InferenceMethod = inferenceMethod;
    data.Transients.ThresholdPSNR = thPSNR;
    
    Write_Data(data)
    t=toc; disp(['   Done (' num2str(t) ' seconds)'])
    
    % Plot raster
%     Plot_Raster(inference,[' inference ' handles.name])
%     if size(inference,1)==1
%         Plot_Coactivity(inference,[ ' inference ' handles.name],[],data.Movie.FPS)
%     else
%         Plot_Coactivity(sum(inference),[ ' inference ' handles.name],[],data.Movie.FPS)
%     end
else
    btnTransients_Callback(handles.btnTransients,[],handles)
    btnGetInference_Callback(handles.btnGetInference,[],handles)
end

%% 6. Get raster
function btnRaster_Callback(hObject,~,handles)
% Read data
data = Read_Data(handles.name);

% Compute transients
if isfield(data,'Transients')
    if isfield(data.Transients,'Inference')
        cells = length(data.Neurons);
        tic; fprintf('Computing raster from %i cells...\n',cells)

        % Get raster
%         sameTh = false;
%         th = 3;
        sameTh = true;
        th = 0;
        [raster,inferenceTh] = Get_Raster_From_Inference(data.Transients.Inference,sameTh,th);
       
        % Write data
        data.Transients.Raster = raster;
        data.Transients.InferenceTh = inferenceTh;
        data.Transients.SameThreshold = sameTh;
        data.Transients.Threshold = th;
        Write_Data(data)
        t=toc; disp(['   Done (' num2str(t) ' seconds)'])

        % Plot raster
%         Plot_Raster(raster,handles.name)
%         if size(raster,1)==1
%             Plot_Coactivity(raster,handles.name,[],data.Movie.FPS)
%         else
%             Plot_Coactivity(sum(raster),handles.name,[],data.Movie.FPS)
%         end
    else
        btnGetInference_Callback(hObject,[],handles)
        btnRaster_Callback(hObject,[],handles)
    end
else
    btnTransients_Callback(hObject,[],handles)
    btnGetInference_Callback(hObject,[],handles)
    btnRaster_Callback(hObject,[],handles)
end

%% 7. Remove inactive neurons
function btnRemoveInactive_Callback(~,~,handles)
% Read data
data = Read_Data(handles.name);

if isfield(data,'Transients')
    if isfield(data.Transients,'Raster')
        raster = data.Transients.Raster;
        active = sum(raster,2)>0;
        
        % Remove from Neurons vairable
        data.InactiveNeurons = data.Neurons(~active);
        data.Neurons = data.Neurons(active);
        
        % Remove from Transients
        data.Transients.Raw = data.Transients.Raw(active,:);
        data.Transients.Filtered =data.Transients.Filtered(active,:);
        data.Transients.Smoothed = data.Transients.Smoothed(active,:);
        data.Transients.F0 = data.Transients.F0(active,:);
        data.Transients.Cells = nnz(active);
        data.Transients.PSNR = data.Transients.PSNR(active);
        data.Transients.Inference = data.Transients.Inference(active,:);
        data.Transients.Model = data.Transients.Model(active,:);
        data.Transients.Raster = data.Transients.Raster(active,:);
        data.Transients.InferenceTh = data.Transients.InferenceTh(active,:);
        
        % Remove from ROIs
        data.ROIs.CellMasks = data.ROIs.CellMasks(:,:,active);
        data.ROIs.CellWeightedMasks = data.ROIs.CellWeightedMasks(:,:,active);
        data.ROIs.AuraMasks = data.ROIs.AuraMasks(:,:,active);
        data.ROIs.CellMasksImage = sum(data.ROIs.CellMasks,3);
        data.ROIs.CellWeightedMasksImage = sum(data.ROIs.CellWeightedMasks,3);
        data.ROIs.AuraMasksImage = sum(data.ROIs.AuraMasks,3);
        
        % Remove from XY
        data.XY.All = data.XY.All(active,:);
        
        % Write data
        Write_Data(data)
        
        % Display neurons removed
        disp([num2str(nnz(~active)) ' neurons removed'])
        
        % Update the mask cells
        set(handles.btnMask,'Checked','off')
        btnMask_Callback(handles.btnMask,[],handles);
    end
end

%% 8. Get neural tuning
function btnNeuralTuning_Callback(~,~,handles)
% Read data
data = Read_Data(handles.name);

if ~isfield(data,'Transients')
    btnTransients_Callback(handles.btnTransients,[],handles);
    btnRaster_Callback(handles.btnRaster,[],handles)
    % Read data
    data = Read_Data(handles.name);
else
    if ~isfield(data.Transients,'Raster')
        btnRaster_Callback(handles.btnRaster,[],handles)
        % Read data
        data = Read_Data(handles.name);
    end
end
% 0.01-111, 0.02-133, 0.03-142, 0.04-144, 0.05-147,
% 0.06-138, 0.1-100, 0.2-50
if isfield(data,'VoltageRecording')
    tic; disp('Finding tuned neurons...')
    % It is better to use the raster to find tuned neurons
    % The inference and inference thresholded find less tuned neurons
    %activity = double(data.Transients.Inference>0.06);
    %activity = double(data.Transients.ModelTh>0);
    %activity = data.Transients.Inference;
    raster = double(data.Transients.Raster);
    activity = raster;
    
    if nnz(data.VoltageRecording.Stimuli)
        [sorting_id,tuning_id,oi,weights,dist_loco,dist_inter] = ...
            Get_Tuned_Neurons(activity,raster,...
            data.VoltageRecording.Stimuli,data.VoltageRecording.Locomotion,...
            true,[data.Movie.DataName '_Tuning'],data.Movie.FPS,data.Transients.PSNR);
    else
        [sorting_id,tuning_id,oi,weights,dist_loco,dist_inter] = ...
            Get_Tuned_Neurons(activity,raster,...
            data.VoltageRecording.Locomotion>2,data.VoltageRecording.Locomotion,...
            true,[data.Movie.DataName '_Tuning'],data.Movie.FPS,data.Transients.PSNR);
    end
    
    % Set tunning data
    id = 1;
    for i = sorting_id
        data.Neurons(i).SortingID = id;
        data.Neurons(i).TuningID = tuning_id(i);
        data.Neurons(i).OrientationIndex = oi(i);
        data.Neurons(i).WeightsOrientation = weights(i,:)';
        data.Neurons(i).LocomotionCorrelation = 1-dist_loco(i);
        data.Neurons(i).InterStimulusCorrelation = 1-dist_inter(i);
        id = id+1;
    end
    
    % Get coordinates of ensembles
    for i=1:8
        x = [data.Neurons([data.Neurons.TuningID]==i).x_median]';
        y = [data.Neurons([data.Neurons.TuningID]==i).y_median]';
        data.XY.Ensemble{i} = [x y];
    end
    
    % Get coordinates of inter-stimulus neurons
    x = [data.Neurons([data.Neurons.TuningID]==-1).x_median]';
    y = [data.Neurons([data.Neurons.TuningID]==-1).y_median]';
    data.XY.Inter = [x y];
    
    % Get coordinates of locomotion neurons
    x = [data.Neurons([data.Neurons.TuningID]==-2).x_median]';
    y = [data.Neurons([data.Neurons.TuningID]==-2).y_median]';
    data.XY.Locomotion = [x y];
    
    % Get coordinates of locomotion neurons
    x = [data.Neurons([data.Neurons.TuningID]==0).x_median]';
    y = [data.Neurons([data.Neurons.TuningID]==0).y_median]';
    data.XY.Other = [x y];
    
    % Write data
    Write_Data(data)
    
    t=toc; disp(['   Done (' num2str(t) ' seconds)'])
    
    
    % Update the mask cells
    set(handles.btnMask,'Checked','off')
    btnMask_Callback(handles.btnMask,[],handles);
else
    disp('Error: add the voltage recording to the experiment')
end

%% Menu Export

%% Extract neuronal activity in variables
function btnExtractInVariables_Callback(hObject, eventdata, handles)
% Read data
data = Read_Data(handles.name);

if isfield(data,'Transients')
    %assignin('base',['transients_' data.Movie.DataName],data.Transients.Filtered);
    if isfield(data.Transients,'Inference')
        %assignin('base',['inference_' data.Movie.DataName],data.Transients.Inference);
        if isfield(data.Transients,'Raster')
            assignin('base',['raster_' data.Movie.DataName],data.Transients.Raster);
        else
            disp('There is no raster computed!')
        end
    else
        disp('There is no spike inference computed!')
    end
else
    disp('There are no transients computed!')
end

%% Generate files for stimulation
function btnCreateFile_Callback(~,~,handles)
% Read data
data = Read_Data(handles.name);

if isfield(data,'Neurons')
    if isfield(data.Neurons,'TuningID')
        % Input from user to select the ensembles
        prompt = {'Enter the ensemble numbers separated by comas',...
            'Enter the number of stimulations:'};
        title = 'Enter ensembles';
        dims = [1 50; 1 50];
        default_input = {'1','600'};
        answer = inputdlg(prompt,title,dims,default_input);
        
        if(~isempty(answer))
            % validate user entry
            ensemblesStr = answer{1};
            nStims = str2num(answer{2});
            
            if isnan(nStims)
                warning('The input for stimulations is incorrect. Value of 1 is used instead')
                nStims = 1;
            end
            if ~isnan(ensemblesStr)
                ensembles = strsplit(ensemblesStr,',');
                n = length(ensembles);
                xy = [];
                for i = 1:n
                    num = str2num(ensembles{i});
                    if isempty(num)
                        error('The input is incorrect! Try: "1" or "1,2"')
                        break;
                    end
                    xy = [xy; data.XY.Ensemble{num}];
                end
                % Open dialog box
                path = uigetdir('','Select a folder to save files.');
                if path
                    tic; disp('Generating files...')
                    XYrand = Create_Prairie_Stim_Files(xy,nStims,true,path,'random');
                    XYseq = Create_Prairie_Stim_Files(xy,nStims,false,path,'sequence');   

                    % Save stimulation xy generated
                    data.Stimulation.XYrand = XYrand;
                    data.Stimulation.XYseq = XYseq;
                    Write_Data(data)
                    t=toc; disp(['   Done (' num2str(t) ' seconds)'])
                end
            else
                error('The input for ensembles is incorrect! Try: "1" or "1,2"')
            end
        end
    else
        error('There are not tuning data!')
    end
else
    error('There are not neuronal data!')
end

%% -- Menu Help --
%% About
function btnAbout_Callback(~,~,~)
msgbox(sprintf(['This program was developed by: \n\n'...
    'Jesus E. Perez-Ortega\n'...
    'jesus.epo@gmail.com\n\n'...
    '2019']),...
    'About','help','modal')

%% -- Toolbar --
%% Save figure
function btnSave_ClickedCallback(~,~,handles)
% Read data
data = Read_Data(handles.name);
name = data.Movie.DataName;
save_video = false;

% Open dialog box
if strcmp(get(handles.btnVideo,'Checked'),'on')
    [file_name, path] = uiputfile({'*.avi','AVI Video - Uncompressed (*.avi)';...
        '*.mat','MATLAB file (*.mat)'},...
        'Save video',name);
    save_video = true;
elseif strcmp(get(handles.btnFiltered,'Checked'),'on')
    [file_name, path] = uiputfile({'*.avi','Video AVI uncompressed (*.avi)';...
        '*.mat','MATLAB file (*.mat)'},...
        'Save video',[name '_normalized']);
    save_video = true;
elseif strcmp(get(handles.btnAverage,'Checked'),'on')
    name = [name '_average'];
    [file_name, path] = uiputfile({'*.png','PNG image (*.png)'}, 'Save image',name);
    image = data.Movie.ImageAverage;
elseif strcmp(get(handles.btnImageSTD,'Checked'),'on')
    name = [name '_std'];
    [file_name, path] = uiputfile({'*.png','PNG image (*.png)'}, 'Save image',name);
    image = data.Movie.ImageSTD;
elseif strcmp(get(handles.btnImageSVD,'Checked'),'on')
    name = [name '_summary'];
    [file_name, path] = uiputfile({'*.png','PNG image (*.png)'}, 'Save image',name);
    image = data.Movie.Summary;
elseif strcmp(get(handles.btnImagePSNR,'Checked'),'on')
    name = [name '_PSNR'];
    [file_name, path] = uiputfile({'*.png','PNG image (*.png)'}, 'Save image',name);
    image = data.Movie.ImagePSNR;
elseif strcmp(get(handles.btnMask,'Checked'),'on')
    name = [name '_mask'];
    [file_name, path] = uiputfile({'*.png','PNG image (*.png)'}, 'Save image',name);
    image = data.Movie.ImageMask;
end

if ~(isequal(file_name,0) || isequal(path,0))
    full_path = [path file_name];
    if save_video
        options.Profile = 'Grayscale AVI';
        options.FrameRate = data.Movie.FPS;
        if strcmp(get(handles.btnVideo,'Checked'),'on')
            movie = data.Movie.Images;
        else
            movie = data.Movie.Norm;
        end
        
        if strcmp(file_name(end-2:end),'avi')
            Save_Video(movie,full_path,options)
        else
            % MAT file
            save(full_path,'movie');
        end
    else
        % Get original position
        position = get(handles.figImage,'position');

        % Create a new figure
        fig_new = Set_Figure(name,[0 0 position(3:4)]);

        % Copy axes
        copyobj(handles.axImage,fig_new);
        Set_Axes('',[0.015 0.006 0.96 .06])
        text(0.5,0.5,strrep(name,'_','-'),'horizontalalignment','center')
        axis off

        % Save figure
        Save_Figure([full_path(1:end-4) '_text']);
        
        % Save image
        imwrite(rescale(image),full_path)
    end
end


% Update cursor in the transients plot
function sldImage_Callback(~,eventdata,handles)
if Hold_Figure(['Cell transient - ' handles.name])
    sldCell_Callback(handles.sldCell,eventdata,handles)
end

%% Select a ROI and show it with its signal
function image_ButtonDown(~,eventdata,handles)
x = round(eventdata.IntersectionPoint(1));
y = round(eventdata.IntersectionPoint(2));
%disp(sprintf('x:%d y:%d',x,y))
if ~isnan(x)
    set(handles.figImage,'WindowButtonMotionFcn',[]);
    % Read data
    data = Read_Data(handles.name);
    if isfield(data,'XY')
        neuron = Find_Cell_by_XY(x,y,data.XY.All,data.ROIs.CellRadius*1.5);
        
        if ~isempty(neuron)
            neuronID = neuron(1);
            disp(['   neuron ' num2str(neuronID)])
            %disp(data.Neurons(neuronID));
            alpha = ones(data.Movie.Height,data.Movie.Width);
            alpha(data.Neurons(neuronID).pixels) = 0.7;
            if isa(handles.axImage.Children(1),'matlab.graphics.primitive.Image')
                handles.axImage.Children(1).AlphaData = alpha;
            elseif isa(handles.axImage.Children(2),'matlab.graphics.primitive.Image')
                handles.axImage.Children(2).AlphaData = alpha;
            elseif isa(handles.axImage.Children(3),'matlab.graphics.primitive.Image')
                handles.axImage.Children(3).AlphaData = alpha;
            end

            if isfield(data,'Transients')
%                 Plot_Single_Transient(data.Transients.Raw(neuronID,:),...
%                     data.Transients.Smoothed(neuronID,:),...
%                     data.Transients.F0(neuronID,:),data.Transients.Inference(neuronID,:),...
%                     data.Transients.Model(neuronID,:),data.Transients.Raster(neuronID,:),...
%                     neuronID,handles.name,data.Movie.FPS,get(handles.sldImage,'value'))
                set(handles.sldCell,'Value',neuronID)
                sldCell_Callback(handles.sldCell,[],handles)
            end
        else
            disp('   no neuron selected')
            alpha = ones(data.Movie.Height,data.Movie.Width);
            if isa(handles.axImage.Children(1),'matlab.graphics.primitive.Image')
                handles.axImage.Children(1).AlphaData = alpha;
            elseif isa(handles.axImage.Children(2),'matlab.graphics.primitive.Image')
                handles.axImage.Children(2).AlphaData = alpha;
            elseif isa(handles.axImage.Children(3),'matlab.graphics.primitive.Image')
                handles.axImage.Children(3).AlphaData = alpha;
            end
        end
    end
end
