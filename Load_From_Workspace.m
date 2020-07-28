function varargout = Load_From_Workspace(varargin)
% LOAD_FROM_WORKSPACE MATLAB code for LOAD_FROM_WORKSPACE.fig
%      LOAD_FROM_WORKSPACE, by itself, creates a new LOAD_FROM_WORKSPACE or raises the existing
%      singleton*.
%
%      H = LOAD_FROM_WORKSPACE returns the handle to a new LOAD_FROM_WORKSPACE or the handle to
%      the existing singleton*.
%
%      LOAD_FROM_WORKSPACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOAD_FROM_WORKSPACE.M with the given input arguments.
%
%      LOAD_FROM_WORKSPACE('Property','Value',...) creates a new LOAD_FROM_WORKSPACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LOAD_FROM_WORKSPACE_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LOAD_FROM_WORKSPACE_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LOAD_FROM_WORKSPACE

% Last Modified by GUIDE v2.5 15-Apr-2019 10:02:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Load_From_Workspace_OpeningFcn, ...
                   'gui_OutputFcn',  @Load_From_Workspace_OutputFcn, ...
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

function Load_From_Workspace_OpeningFcn(hObject,~,handles,varargin)
handles.fig = varargin{1};
handles.output = hObject;
guidata(hObject, handles);

function varargout = Load_From_Workspace_OutputFcn(~,~,handles) 
varargout{1} = handles.output;

%% Start loading workspace
function popWorkspace_CreateFcn(hObject,~,~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
data_strings = evalin('base','who');
set(hObject,'String',[{'-- select --'};data_strings])
set(hObject,'Value',1)

%% Evaluate selection of variable
function popWorkspace_Callback(hObject,~,handles)
% Get item
data_num = get(hObject,'Value');

% If item selected
if data_num>1
    data_strings = get(hObject,'String');
    name = data_strings{data_num};

    % Check if exist
    compatible = false;
    if evalin('base',['exist(''' name ''',''var'')'])
        data = evalin('base',name);
        
        if strcmp(handles.fig.Tag,'btnLoadWorkspace')
            % Check if has movie field
            if isfield(data,'Movie')
                name = ['data_' data.Movie.DataName];
                assignin('base',name,data)
                compatible = true;
            end
        else
            % Check if variable has structure of a movie
            if ndims(data) == 3
                compatible = true;
            end
        end
    end
    
    % If variable is compatible
    if compatible
        % Save name in current figure
        handles.name = name;
        guidata(hObject,handles);

        % Load data
        Load(handles)
    else
        set(handles.txtMessage,'string','not compatible')
        set(handles.txtMessage,'ForeGroundColor',[0.5 0 0]);
    end
end

%% Return value
function Load(handles)

if strcmp(handles.fig.Tag,'btnOpenWorkspace')
    % Get data from video
    name = handles.name;
    movie = evalin('base',name);
    [h,w,n] = size(movie);
    
    switch class(movie)
    case {'single','double'}
        movie = uint16(rescale(movie).*double(intmax('uint16')));
    end
    d = class(movie);
    d = str2num(d(5:end));

    % Save name in current figure
    data_movie.Movie.FilePath = 'From workspace';
    data_movie.Movie.FileName = name;
    data_movie.Movie.DataName = name;
    data_movie.Movie.Width = w;
    data_movie.Movie.Height = h;
    data_movie.Movie.Depth = d;
    data_movie.Movie.Frames = n;
    data_movie.Movie.Images = movie;
    data_movie.Movie.CorrectedMotion = false;

    % defaults
    data_movie.ROIs.CellRadius = 4;
    data_movie.ROIs.AuraRadius = 30;
    data_movie.Movie.FPS = 12.5; %12.3457;
    
    % Save in workspace
    name = ['data_' name];
    assignin('base',name,data_movie)
else
    name = handles.name;
end

% Pass the name to the caller figure
handles_2 = guidata(handles.fig);
handles_2.name = name;
guidata(handles.fig,handles_2);
close
