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

% Last Modified by GUIDE v2.5 02-May-2019 12:03:05

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
function Initialize_Data(hObject,handles)
% Initialize handles
handles.ViewNorm = false;
handles.ROIsChanged = false;
handles.MinMax = [];
handles.MinMaxNorm = [];
guidata(hObject,handles)

% Read data
data = Read_Data(handles.name);

% Set values of the slider
n_cells = data.Movie.Frames;
set(handles.sldImage,'Value',1)
set(handles.sldImage,'enable','on')
set(handles.sldImage,'Max',n_cells)
set(handles.sldImage,'Min',1)
if(n_cells>1)
    set(handles.sldImage, 'SliderStep', [1/(n_cells-1) 10/(n_cells-1)]);
else
    set(handles.sldImage, 'SliderStep', [1 1]);
end
addlistener(handles.sldImage,'Value','PostSet',...
    @(~,~)Catrex_GUI('sldImage_Moving',guidata(hObject)));

% Plot the first image
image = data.Movie.Images(:,:,1);
if strcmp(get(hObject,'checked'),'on')
    image = Equalize_Image(image);
end
hImage = imshow(image,'parent',handles.axImage);

% Check the current menu item
Uncheck_Views(handles)
set(handles.btnVideo,'Checked','on')

% Set the file name in the title
title = ['/' num2str(n_cells) ' - ' data.Movie.FileName ' - fCatrex GUI'];
set(handles.figImage,'name',['1' title])

% Enable menu
set(handles.mnuView,'Enable','on')
set(handles.mnuROIs,'Enable','on')
set(handles.mnuProcess,'Enable','on')
set(handles.mnuOptions,'Enable','on')

% Enable cell slider if transients
if isfield(data,'Transients')
    Enable_Cell_Slider(handles)
    handles.Transients = true;
else
    set(handles.sldCell,'enable','off')
    handles.Transients = false;
end

% Save changes in handles
handles.hImage = hImage;
handles.title = title;
guidata(hObject,handles)


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

%% Check field existence
function exist_field = Exist_Field(data,field)
switch (field)
    % Inside ROIs field
    case {'XCorr','XY','CellRadius','AuraRadius','Accuracy'}
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
    case {'ImageSTD','FPS','Norm'}
        if isfield(data.Movie,field)
            exist_field = true;
        else
            exist_field = false;
        end
    otherwise
        exist_field = false;
end

%% Remove fields in data
function data = Remove_Data(data,field)
switch (field)
    case {'Norm','NormMax','ImageAverage','ImageSTD'}
        if isfield(data.Movie,field)
            data.Movie = rmfield(data.Movie,field);
        end
    case {'XCorr'}
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
set(handles.btnNormalized,'Checked','off')
set(handles.btnImageSTD,'Checked','off')
set(handles.btnNormMax,'Checked','off')
set(handles.btnXCorr,'Checked','off')
set(handles.btnMask,'Checked','off')


%% Delete ROIs
function [xy_updated,id_deleted] = Delete_ROIs(xy,xy_delete,radius)
% Get size
n = size(xy,1);

% Get the distance between coordinates
distance = squareform(pdist([xy; xy_delete]))+eye(n+size(xy_delete,1))*radius;

% find wheter distance is less than radius
[id_deleted,~] = find(distance<radius);
id_deleted(id_deleted>n) = []; 

% Delete 
if isempty(id_deleted)
    xy_updated = xy;
else
    keep = setdiff(1:n,id_deleted);
    xy_updated = xy(keep,:);
end

%% Compute normalization
function data = Compute_Normalization(data)
tic; disp('Normalizing movie...')
[normalized,max_norm,mean_movie,std_movie] = Normalize_Movie(data.Movie.Images);

% Write data
data.Movie.Norm = normalized;
data.Movie.NormMax = max_norm;
data.Movie.ImageAverage = mean_movie;
data.Movie.ImageSTD = std_movie;
Write_Data(data)

t=toc; disp(['   Done (' num2str(t) ' seconds)'])

%% Compute cross-correlation
function data = Compute_XCorr(handles,data)

% Check if normalized
if ~Exist_Field(data,'Norm')
    data = Compute_Normalization(data);
end
    
tic; disp('Computing cross-correlation image...')

% Read properties
image_class = class(handles.hImage.CData);
factor = double(intmax(image_class));
image = cast(Scale(double(data.Movie.NormMax)+data.Movie.ImageSTD)*factor,image_class);
%image = cast(Scale(data.Movie.ImageSTD)*factor,image_class);
%image = cast(Scale(data.Movie.NormMax)*factor,image_class);

% Get template
template = Generate_Cell_Template(Get_Cell_Radius(data));

% Compute cross-correlation 
xcorr = Get_Correlation_Image(image,template);

% Write data in workspace
data.ROIs.XCorr = xcorr;
data.ROIs.Template = template;
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
handles.Transients = false;
Write_Data(data)

% Delete ROIs cell
if isfield(handles,'CellROI')
    axes(handles.axImage)
    delete(handles.CellROI)
end

% Disable cell slider
set(handles.sldCell,'Enable','off')

%% -- Update --
%% Update ROIs
function handles = Update_ROIs(handles)
if strcmp(get(handles.btnDrawROIs,'Checked'),'on')
    % Delete the ROIs
    if isfield(handles,'ROIs')
        delete(handles.ROIs)
    end
    % Draw again
    set(handles.btnDrawROIs,'Checked','off')
    btnDrawROIs_Callback(handles.btnDrawROIs,[],handles)
    handles = guidata(handles.btnDrawROIs);
end
if  strcmp(get(handles.btnDrawNumbers,'Checked'),'on')
    % Delete the ROIs
    if isfield(handles,'ROIsNumber')
        delete(handles.ROIsNumber)
    end
    % Draw again
    set(handles.btnDrawNumbers,'Checked','off')
    btnDrawNumbers_Callback(handles.btnDrawNumbers,[],handles)
    handles = guidata(handles.btnDrawNumbers);
end

%% Update cross-correlation
function Update_XCorr(handles)
if strcmp(get(handles.btnXCorr,'Checked'),'on')
    set(handles.btnXCorr,'Checked','off')
    btnXCorr_Callback(handles.btnXCorr,[],handles)
end

%% Update transients
function Update_Transients(handles,id,process)
if handles.Transients
    % Read data
    data = Read_Data(handles.name);

    switch (process)
        case 'delete'
            data.Transients.Raw(id,:) = [];
            data.Transients.Filtered(id,:) = [];
            data.Transients.F0(id,:) = [];
            data.Transients.Normalized(id,:) = [];
            data.Transients.Cells = data.Transients.Cells-length(id);
            
        case 'add'
            
    end
    
    
    % Write data
    Write_Data(data)
    
    % Update cell slider
    Enable_Cell_Slider(handles)
end

%% -- Get data --
%% Get cell radius
function cell_radius = Get_Cell_Radius(data)
if Exist_Field(data,'CellRadius')
    % Get the size
    cell_radius = data.ROIs.CellRadius;
else
    % Set default size
    cell_radius = 4;
    data.ROIs.CellRadius = cell_radius;
    Write_Data(data);
end

%% Get aura radius
function aura_radius = Get_Aura_Radius(data)
if Exist_Field(data,'AuraRadius')
    % Get the size
    aura_radius  = data.ROIs.AuraRadius;
else
    % Set default size
    aura_radius  = 4*Get_Cell_Radius(data);
    data.ROIs.AuraRadius = aura_radius;
    Write_Data(data);
end

%% Get accuracy
function accuracy = Get_Accuracy(data)
if Exist_Field(data,'Accuracy')
    % Get the size
    accuracy = data.ROIs.Accuracy;
else
    % Set default size
    accuracy  = 0.7;
    data.ROIs.Accuracy = accuracy;
    Write_Data(data);
end

%% Get FPS
function fps = Get_FPS(data)
if Exist_Field(data,'FPS')
    % Get the size
    fps = data.Movie.FPS;
else
    % Set default size
    fps  = 4;
    data.Movie.FPS = fps;
    Write_Data(data);
end

%% -- Callbacks --
%% Moving frame slider
function sldImage_Moving(handles)
% Read data
data = Read_Data(handles.name);

% Round value
value = round(get(handles.sldImage,'Value'));
set(handles.sldImage,'Value',value)

% Plot the current image
if handles.ViewNorm
    image = data.Movie.Norm(:,:,value);
else
    image = data.Movie.Images(:,:,value);
end

if strcmp(get(handles.btnEnhance,'checked'),'on')
    if handles.ViewNorm
        if isempty(handles.MinMaxNorm)
            min_max_data = minmax(data.Movie.Norm(:)');
            handles.MinMaxNorm = min_max_data;
            guidata(handles.sldImage, handles);
        else
            min_max_data = handles.MinMaxNorm;
        end
    else
        if isempty(handles.MinMax)
            min_max_data = minmax(data.Movie.Images(:)');
            handles.MinMax = min_max_data;
            guidata(handles.sldImage, handles);
        else
            min_max_data = handles.MinMax;
        end
    end
    
    image = Equalize_Image(image,min_max_data);
end


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
if handles.Transients
    % Read data
    data = Read_Data(handles.name);

    % Round value
    value = round(get(hObject,'Value'));
    set(hObject,'Value',value)

    % Get ROIs
    xy = data.ROIs.XY(value,:);

    % Delete the cell ROI
    if isfield(handles,'CellROI')
        axes(handles.axImage)
        delete(handles.CellROI)
    end

    % Draw cell ROI
    cell_size = Get_Cell_Radius(data)+1;
    cell_ROI = viscircles(handles.axImage,xy, cell_size,'Color','g','LineWidth',3,...
        'EnhanceVisibility',false);

    % Plot transients
    Plot_Single_Transient(data.Transients.Raw(value,:),smooth(data.Transients.Filtered(value,:))',...
        data.Transients.F0(value,:),value,handles.name,Get_FPS(data),get(handles.sldImage,'value'))

    % Save ROIs object
    handles.CellROI = cell_ROI;
    guidata(hObject,handles)
end

%% -- Menu File --
%% Open video from file
function btnOpenVideo_Callback(hObject,~,handles)
% Open dialog box
[file_name,path] = uigetfile('*.tif','Select video.');
file = [path file_name];

if path
    tic; disp('Loading file info...')
    
    % Assign data name
    name = file_name(1:end-4);
    name = strrep(name,'-','_');
    name = strrep(name,'.','_');
    
    % Get info from the file
    info = imfinfo(file);
    w = info(1).Width;
    h = info(1).Height;
    depth = info(1).BitDepth;
    
    % Get offset and byte strip
    strip_offset = info(1).StripOffsets;
    strip_byte = info(1).StripByteCounts;

    if length(info) == 1
        frames = floor((info(1).FileSize-strip_offset)/strip_byte);
    else
        frames = length(info);
    end
    
    t=toc; disp(['   Done (' num2str(t) ' seconds)'])
    
    % Estimated time from a MacBook Air core i5: 750 frames/s (256x256 8bit)
    switch (depth)
        case 8
            estimated_time = round(frames/1500);
            mov = zeros(h,w,frames,'uint8');
        case 16
            estimated_time = round(frames/750);
            mov = zeros(h,w,frames,'uint16');
        case 32
            estimated_time = round(frames/750);
            mov = zeros(h,w,frames,'single');
    end
    tic; fprintf('Loading %i-bit frames... (estimated time: %i s)\n',depth,estimated_time)
    
    % Read images
    file_id = fopen (file,'r');
    start_point = strip_offset+(0:(frames-1)).*strip_byte;
    for i = 1:frames
        % Go through each strip of data.
        fseek(file_id, start_point(i)+1, 'bof');

        % Read data of each frame depending of the depth
        switch(depth)
            case 8
                A = fread(file_id,[w h],'uint8=>uint8');
            case 16
                A = fread(file_id,[w h],'uint16=>uint16');
            case 32
                A = fread(file_id,[w h],'sinlge=>single');
        end
        mov(:,:,i) = A';
    end
    
    if depth == 32
        mov = uint16(mov);
        depth = 16;
    end
    
    t=toc; disp(['   Done (' num2str(t) ' seconds)'])
    
    % Write in handles
    handles.name = ['data_' name];
    guidata(hObject,handles)
    
    % Write data in workspace
    data.Movie.FilePath = path;
    data.Movie.FileName = file_name;
    data.Movie.DataName = name;
    data.Movie.Width = w;
    data.Movie.Height = h;
    data.Movie.Depth = depth;
    data.Movie.Frames = frames;
    data.Movie.Images = mov;
    Write_Data(data)
    
    % Initialize properties
    Initialize_Data(hObject,handles)
end


%% Open video from workspace
function btnOpenWorkspace_Callback(hObject,~,handles)
if isfield(handles,'name')
    name = handles.name;
else
    name = [];
end

% Open GUI for loading
uiwait(Load_From_Workspace(hObject))

% Load new data
handles = guidata(hObject);
if isfield(handles,'name')
    % Initialize properties
    Initialize_Data(hObject,handles)
end

%% Load data from workspace
function btnLoadWorkspace_Callback(hObject,~,handles)
if isfield(handles,'name')
    name = handles.name;
else
    name = [];
end

% Open GUI for loading
uiwait(Load_From_Workspace(hObject))

% Load new data
handles = guidata(hObject);
if isfield(handles,'name')
    % Initialize properties
    Initialize_Data(hObject,handles)
end

%% Close the GUI
function btnExit_Callback(~,~,~)
close

%% -- Menu View --
%% 1. View video
function btnVideo_Callback(hObject,~,handles)
if strcmp(get(hObject,'Checked'),'off')
    % Read data
    data = Read_Data(handles.name);

    % Check the current menu item
    Uncheck_Views(handles)
    set(hObject,'Checked','on')

    % Set properties
    set(handles.sldImage,'Enable','on')
    handles.ViewNorm = false;
    guidata(hObject,handles)
    
    % Plot the current image
    sldImage_Moving(handles)
end

%% 2. View normalized video
function btnNormalized_Callback(hObject,~,handles)
if strcmp(get(hObject,'Checked'),'off')
    % Read data
    data = Read_Data(handles.name);
    
    % Check if normalized
    if ~Exist_Field(data,'Norm')
        Compute_Normalization(data);
    end

    % Check the current menu item
    Uncheck_Views(handles)
    set(hObject,'Checked','on')

    % Set properties
    set(handles.sldImage,'Enable','on')
    
    % Write in handles
    handles.ViewNorm = true;
    guidata(hObject, handles);
    
    % Plot the current image
    sldImage_Moving(handles)
end
        
%% 3. View std image
function btnImageSTD_Callback(hObject,~,handles)
if strcmp(get(hObject,'Checked'),'off')
    % Read data
    data = Read_Data(handles.name);

    % Check the current menu item
    Uncheck_Views(handles)
    set(hObject,'Checked','on')

    % Check if normalized
    if ~Exist_Field(data,'Norm')
        data = Compute_Normalization(data);
    end
    
    % Plot summary
    image_class = class(handles.hImage.CData);
    factor = double(intmax(image_class));
    image = cast(Scale(data.Movie.ImageSTD)*factor,image_class);
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

%% 4. View maximum normalized image
function btnNormMax_Callback(hObject,~,handles)
if strcmp(get(hObject,'Checked'),'off')
    % Read data
    data = Read_Data(handles.name);

    % Check the current menu item
    Uncheck_Views(handles)
    set(hObject,'Checked','on')

    % Check if normalized
    if ~Exist_Field(data,'Norm')
        data = Compute_Normalization(data);
    end
    
    % Plot summary
    image_class = class(handles.hImage.CData);
    factor = double(intmax(image_class));
    image = cast(Scale(data.Movie.NormMax)*factor,image_class);
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
    set(handles.figImage,'name',['Maximum after normalization' handles.title(start:end)])
    
    % Set properties
    set(hObject,'Checked','on')
    set(handles.sldImage,'Enable','off')    
end


%% 5. View cross correlation
function btnXCorr_Callback(hObject,~,handles)
if strcmp(get(hObject,'Checked'),'off')
    % Read data
    data = Read_Data(handles.name);

    % Check if exist XCorr image
    if ~Exist_Field(data,'XCorr')
        data = Compute_XCorr(handles,data);
    end

    % Get image with the same depth
    if data.Movie.Depth==8
        image = Equalize_Image(uint8(data.ROIs.XCorr*255));
    else
        image = Equalize_Image(uint16(data.ROIs.XCorr*255));
    end
    
    % Plot cross-correlation
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
    set(handles.figImage,'name',['Cross-correlation' handles.title(start:end)])
    
    % Set properties
    Uncheck_Views(handles)
    set(hObject,'Checked','on')
    set(handles.sldImage,'Enable','off')
end

%% 6. View mask
function btnMask_Callback(hObject,~,handles)
if strcmp(get(hObject,'Checked'),'off')
    % Read data
    data = Read_Data(handles.name);

    % Check the current menu item
    Uncheck_Views(handles)
    set(hObject,'Checked','on')

    % Check if exist XCorr image
    if ~Exist_Field(data,'XCorr')
        data = Compute_XCorr(handles,data);
    end

    %test delete
    image_class = class(handles.hImage.CData);
    factor = double(intmax(image_class));
    image = cast(Scale(double(data.Movie.NormMax).*data.Movie.ImageSTD)*factor,image_class);
    %test delete
    
    
    % Get image with the same depth
%     accuracy = Get_Accuracy(data);
%     if data.Movie.Depth==8
%         image = Equalize_Image(uint8((data.ROIs.XCorr>accuracy)*255));
%     else
%         image = Equalize_Image(uint16((data.ROIs.XCorr>accuracy)*255));
%     end
    
    % Plot cross-correlation improved
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
    set(handles.figImage,'name',['Mask' handles.title(start:end)])
    
    % Set properties
    set(hObject,'Checked','on')
    set(handles.sldImage,'Enable','off')
end
    
%% -- Menu ROIs --
%% Select ROIs manually
function btnSelectROIs_Callback(hObject,~,handles)
% Read data
data = Read_Data(handles.name);

% Change propertie
title = get(handles.figImage,'Name');
set(handles.figImage,'Name','Press enter to finish...')
set(handles.mnuROIs,'Text','Selecting ROIs...')

% Disable menu items
set(handles.mnuFile,'Enable','off')
set(handles.mnuROIs,'Enable','off')
set(handles.mnuProcess,'Enable','off')
set(handles.mnuOptions,'Enable','off')

% Ask for coordinates
xy = ginput;

if ~isempty(xy)
    % Add to existing prevoius ROIs
    if Exist_Field(data,'XY')
        cell_radius = Get_Cell_Radius(data);
        xy = Add_ROIs(data.ROIs.XY,xy,cell_radius);
    end
    
    % Write in handles
    handles.ROIsChanged = true;
    guidata(hObject, handles);
    
    % Write in workspace
    data.ROIs.XY = xy;
    Write_Data(data)
end

% Return the property values
set(handles.figImage,'Name',title)
set(handles.mnuROIs,'Text','ROIs')

% Enable menu items
set(handles.mnuFile,'Enable','on')
set(handles.mnuROIs,'Enable','on')
set(handles.mnuProcess,'Enable','on')
set(handles.mnuOptions,'Enable','on')

% Draw is checked
Update_ROIs(handles)

%% Draw ROIs
function btnDrawROIs_Callback(hObject,~,handles)
% Detect the state
if strcmp(get(hObject,'Checked'),'off')
    % Read data
    data = Read_Data(handles.name);
    
    % Draw ROIs
    if Exist_Field(data,'XY')
        xy = data.ROIs.XY;
        if ~isempty(xy)
            % Draw ROIs
            cell_size = Get_Cell_Radius(data);
            n = size(xy,1);
            axes(handles.axImage)
            ROIs = viscircles(xy, repmat(cell_size,1,n),'Color','g','LineWidth',1,...
                'EnhanceVisibility',false);
            
            % Save ROIs object
            handles.ROIs = ROIs;
            guidata(hObject,handles)
        end
    end
    
    % Change properties
    set(hObject,'Checked','on')
else
    % Delete the ROIs
    if isfield(handles,'ROIs')
        delete(handles.ROIs)
    end
    
    % Change properties
    set(hObject,'Checked','off')
end

%% Draw ROIs' number
function btnDrawNumbers_Callback(hObject,~,handles)
% Detect the state
if strcmp(get(hObject,'Checked'),'off')
    % Read data
    data = Read_Data(handles.name);
    
    % Draw ROIs
    if Exist_Field(data,'XY')
        xy = data.ROIs.XY;
        if ~isempty(xy)
            % Draw ROIs
            n = size(xy,1);
            number = text(xy(:,1),xy(:,2),num2str((1:n)'),'Color','g',...
                'HorizontalAlignment','Center');
            
            % Save ROIs object
            handles.ROIsNumber = number;
            guidata(hObject,handles)
        end
    end
    
    % Change properties
    set(hObject,'Checked','on')
else
    % Delete the ROIs
    if isfield(handles,'ROIsNumber')
        delete(handles.ROIsNumber)
    end
    
    % Change properties
    set(hObject,'Checked','off')
end

%% Delete ROIs manually
function btnDeleteManual_Callback(hObject,~,handles)
% Read data
data = Read_Data(handles.name);

% Change propertie
title = get(handles.figImage,'Name');
set(handles.figImage,'Name','Press enter to finish...')
set(handles.mnuROIs,'Text','Select ROIs to delete...')

% Disable menu items
set(handles.mnuFile,'Enable','off')
set(handles.mnuROIs,'Enable','off')
set(handles.mnuProcess,'Enable','off')
set(handles.mnuOptions,'Enable','off')

% Ask for coordinates
xy = ginput;

if ~isempty(xy)
    % Add to existing prevoius ROIs
    if Exist_Field(data,'XY')
        cell_radius = Get_Cell_Radius(data);
        [xy,id]= Delete_ROIs(data.ROIs.XY,xy,cell_radius);
        
        % Write in handles
        handles.ROIsChanged = true;
        guidata(hObject, handles);

        % Write in workspace
        data.ROIs.XY = xy;
        Write_Data(data)
    
        if isfield(data,'Transients')
            % Update Transients
            Update_Transients(handles,id,'delete')
        
            % Update ROI
            sldCell_Callback(handles.sldCell,[],handles)
        end
    end
end

% Return the property values
set(handles.figImage,'Name',title)
set(handles.mnuROIs,'Text','ROIs')

% Enable menu items
set(handles.mnuFile,'Enable','on')
set(handles.mnuROIs,'Enable','on')
set(handles.mnuProcess,'Enable','on')
set(handles.mnuOptions,'Enable','on')

% Draw is checked
Update_ROIs(handles)

%% Delete All ROIs
function btnDeleteROIs_Callback(hObject,~,handles)
% Read data
data = Read_Data(handles.name);
    
% Write in handles
handles.ROIsChanged = true;
guidata(hObject, handles);
    
% Write in workspace
data.ROIs.XY = [];
data = Remove_Data(data,'Transients');
Write_Data(data)

% Remove transinets
Remove_All_Transients(handles)

% Udpate ROIs drawn
Update_ROIs(handles)

%% -- Menu Process --
%% Motion correction
function btnMotion_Callback(hObject,~,handles)
tic
disp('Adjusting motion...')

% Read data
data = Read_Data(handles.name);

% If previously corrected
if isfield(data.Movie,'ImagesBeforeCorrected')
    video = data.Movie.ImagesBeforeCorrected;
else
    video = data.Movie.Images;
end

% Get default options to monomodal motion correction
options.iterations = [64 32 4];
options.pyramid_levels = 3;
options.AccumulatedFieldSmoothing = 1; %1.5 ok
options.MaximumDisplacement = 15;
%options.MaximumDisplacement = 100;

% Pre-procesing video
%video_filtered = Scale(video);
%video_filtered = Scale(imfilter(Scale(video),Generate_Cell_Template(4),'symmetric'));

% Detect motion
[~,corrected] = Correct_Non_Rigid(video,options);

t=toc; disp(['   Done (' num2str(t) ' seconds)'])

% Write data
data.Movie.ImagesBeforeCorrected = video;
data.Movie.Images = corrected;

% Remove data computed previously
Remove_All_Transients(handles)
data = Remove_Data(data,'Norm');
data = Remove_Data(data,'NormMax');
data = Remove_Data(data,'ImageAverage');
data = Remove_Data(data,'ImageSTD');
data = Remove_Data(data,'XCorr');
Write_Data(data)

% Write in handles
Uncheck_Views(handles)
set(handles.btnVideo,'Checked','on')
handles.ViewNorm = false;
guidata(hObject,handles)

% Update image
sldImage_Moving(handles)

%% Find cells
function btnFindCells_Callback(hObject,~,handles)
% Read data
data = Read_Data(handles.name);

% Check if exist XCorr image
if ~Exist_Field(data,'XCorr')
    data = Compute_XCorr(handles,data);
end

% Find cells
tic; disp('Finding cells...')
cell_radius = Get_Cell_Radius(data);
xy = Find_Cells(data.ROIs.XCorr,Get_Accuracy(data),cell_radius);

% Write data
Write_Data(data)

if ~isempty(xy)
    % Write in handles
    handles.ROIsChanged = true;
    guidata(hObject, handles);

    % Write data in workspace
    if Exist_Field(data,'XY')
        data.ROIs.XY = Add_ROIs(data.ROIs.XY,xy,cell_radius);
    else
        data.ROIs.XY = Add_ROIs([],xy,cell_radius);
    end  
    
    % Write data
    Write_Data(data)

    % Update ROIs
    Update_ROIs(handles)
else
    disp('   No cells found!')
end

t=toc; disp(['   Done (' num2str(t) ' seconds)'])

%% Get transients
function btnTransients_Callback(hObject,~,handles)
% Read data
data = Read_Data(handles.name);

% Get manual and auto ROIs
xy = [];
if Exist_Field(data,'XY')
    xy = data.ROIs.XY;
end

% Check if there are ROIs
if isempty(xy)
    warning('There are no ROIs.')
else
    if ~isfield(data,'Transients') || handles.ROIsChanged
        % Get transient
        cells = size(xy,1);
        frames = data.Movie.Frames;
        estimated_time = round(cells*frames*2.8493e-04);
        
        tic; fprintf('Computing transients from %i cells... (estimated time: %i s)\n',...
            cells,estimated_time)

        cell_radius = Get_Cell_Radius(data);
        aura_radius = Get_Aura_Radius(data);
        [filtered,raw,f0,bleaching] = Get_Ca_Transients(data.Movie.Images,xy,...
            cell_radius,aura_radius);

        % Write data in workspace
        data.Transients.Raw = raw;
        data.Transients.Filtered = filtered;
        data.Transients.F0 = f0;
        data.Transients.Bleaching = bleaching;
        %data.Transients.Normalized = norm;
        data.Transients.Cells = cells;
        Write_Data(data)
        assignin('base',['transients_' data.Movie.DataName],filtered);
        
        % Write in handles
        handles.ROIsChanged = false;
        handles.Transients = true;
        guidata(hObject, handles);
        
        % Update cell slider
        Enable_Cell_Slider(handles)
        
        t=toc; disp(['   Done (' num2str(t) ' seconds)'])
    end
    
    % Plot all transients
    Plot_Transients(data.Transients.Filtered,handles.name,'separated',Get_FPS(data))
    %Save_Figure(name)
end

%% Get raster
function btnRaster_Callback(hObject,~,handles)
% Read data
data = Read_Data(handles.name);

% Compute transients
if isfield(data,'Transients')
    tic; disp('Get raster form transients...')
    raster = Get_Raster_From_Transients(data.Transients.Filtered,1);
    data.Transients.Raster = raster;
    Write_Data(data)
    t=toc; disp(['   Done (' num2str(t) ' seconds)'])
    Plot_Raster(raster,handles.name)
    Plot_Coactivity(sum(raster),handles.name,[],Get_FPS(data))
    assignin('base',['raster_' data.Movie.DataName],raster);
else
    btnTransients_Callback(hObject,[],handles)
end


%% -- Menu Options --
%% Enhance image
function btnEnhance_Callback(hObject,~,handles)
if strcmp(get(hObject,'checked'),'off')
    set(hObject,'checked','on')
else
    set(hObject,'checked','off')
    handles.MinMax = [];
    handles.MinMaxNorm = [];
    guidata(hObject,handles);
end
if strcmp(get(handles.btnVideo,'checked'),'on') || ...
    strcmp(get(handles.btnNormalized,'checked'),'on')
    sldImage_Moving(handles)
end

%% Set Cell radius
function btnCellRadius_Callback(~,~,handles)
% Read data
data = Read_Data(handles.name);
        
% Configure dialog
prompt = {'Enter the cell radius'};
title = 'Enter parameters';
dims = [1 50];

% Set the current value as default
default_input = {num2str(Get_Cell_Radius(data))};

% Show dialog
answer = inputdlg(prompt,title,dims,default_input);

% Apply change
if ~isempty(answer)
    cell_radius = str2num(answer{1});
    if ~isempty(cell_radius) && cell_radius>1
        if cell_radius ~= Get_Cell_Radius(data)
            % Set data
            data.ROIs.CellRadius = cell_radius;
            disp(['Cell radius was set to: ' num2str(cell_radius)])
            data = Compute_XCorr(handles,data);

            % Write data
            Write_Data(data)

            % Update
            Update_ROIs(handles)
            Update_XCorr(handles)
        end
    else
        warning('Cell radius was set to: 4')
    end
else
    warning('Cell radius was set to: 4')
end

%% Set Aura radius
function btnAuraRadius_Callback(~,~,handles)
% Read data
data = Read_Data(handles.name);
        
% Configure dialog
prompt = {'Enter the aura radius'};
title = 'Enter parameters';
dims = [1 50];

% Set the current value as default
default_input = {num2str(Get_Aura_Radius(data))};

% Show dialog
answer = inputdlg(prompt,title,dims,default_input);

% Apply change
if ~isempty(answer)
    aura_radius = str2num(answer{1});
    if ~isempty(aura_radius) && aura_radius>1
        if aura_radius ~= Get_Aura_Radius(data)
            % Set data
            data.ROIs.AuraRadius = aura_radius;
            disp(['Aura radius was set to: ' num2str(aura_radius)])

            % Write data
            Write_Data(data)

            % Update ROIs
            Update_ROIs(handles)
        end
    end
end

%% Set accuracy
function btnAcurracy_Callback(~,~,handles)
% Read data
data = Read_Data(handles.name);

% Configure dialog
prompt = {'Enter the accuracy to match pattern:'};
title = 'Enter parameters';
dims = [1 50];

data.ROIs.Accuracy = Get_Accuracy(data);

% Set the current value as default
default_input = {num2str(data.ROIs.Accuracy)};

% Show dialog
answer = inputdlg(prompt,title,dims,default_input);

% Apply change
if ~isempty(answer)
    accuracy = str2num(answer{1});
    if ~isempty(accuracy) && accuracy<=1 && accuracy>0
        if accuracy ~= data.ROIs.Accuracy
            % Set data
            data.ROIs.Accuracy = accuracy;
            disp(['Accuracy was set to: ' num2str(accuracy)])
            
            % Write data
            Write_Data(data)
        end
    else
        warning('Accuracy should be between 0-1')
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
default_input = {num2str(Get_FPS(data))};

% Show dialog
answer = inputdlg(prompt,title,dims,default_input);

% Apply change
if ~isempty(answer)
    fps = str2double(answer{1});
    if ~isempty(fps)
        if fps ~= Get_FPS(data)
            % Set data
            data.Movie.FPS = fps;
            disp(['Frames per second was set to: ' num2str(fps)])

            % Write data
            Write_Data(data)
        end
    end
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

% Open dialog box
[file_name, path] = uiputfile('*.png', 'Save figure',name);

if ~(isequal(file_name,0) || isequal(path,0))
    % Get original position
    position = get(handles.figImage,'position');
    
    % Create a new figure
    fig_new = Set_Figure(name,[0 0 position(3:4)]);
    
    % Copy axes
    copyobj(handles.axImage,fig_new);
    
    % Save figure
    full_path = [path file_name];
    Save_Figure(full_path(1:end-4));
end
