function [dataAB,mergeIm,motion] = Combine_Data(dataA,dataB,radius)
% Find the same neurons between 2 videos and get the data of them
%
%       [dataAB,motion] = Combine_Data(dataA,dataB,minmaxRadius)
%
% By Jesus Perez-Ortega, Feb 2020

if nargin == 2
    % Considering a cell radius of 4
    radius = 4;
end

% Get neurons
neuronsA = dataA.Neurons;
neuronsB = dataB.Neurons;
if isfield(neuronsA,'TuningID')
    fields = {'SortingID','TuningID','OrientationIndex','WeightsOrientation',...
        'LocomotionCorrelation','InterStimulusCorrelation'};
    neuronsA = rmfield(neuronsA,fields);
end
if isfield(neuronsB,'TuningID')
    fields = {'SortingID','TuningID','OrientationIndex','WeightsOrientation',...
        'LocomotionCorrelation','InterStimulusCorrelation'};
    neuronsB = rmfield(neuronsB,fields);
end

% Get masks
maskA = rescale(dataA.ROIs.CellWeightedMasksImage);
maskB = rescale(dataB.ROIs.CellWeightedMasksImage);

% Apply rigid motion between 2 videos
video(:,:,1) = maskA;
video(:,:,2) = maskB;

% Get motion
[~,motion] = Registration(video,'rigid');
motion = motion{2};

% Apply motion
maskB = Apply_Motion(maskB,motion,'rigid');

% Get intersection of mask
mask = maskA & maskB;

% This is for avoid that 2 neurons can be taken as 1
maskAB = double(mask);
maskAB(mask) = (rescale(maskA(mask))+rescale(maskB(mask)))/2;
maskAB = maskAB>0.1;

% Get merge image
mergeIm(:,:,1) = maskA;
mergeIm(:,:,2) = zeros(size(maskA));
mergeIm(:,:,3) = maskB;

% Get intersection
[neuronsSame,intIDA] = Find_Intersected_Neurons_With_Mask(neuronsA,maskAB,radius);
[intB,intIDB] = Find_Intersected_Neurons_With_Mask(neuronsB,maskAB,radius);

% Evaluate shape
[~,~,sameID] = Evaluate_Shape_Neurons(neuronsSame,intB,256,256);
neuronsSame = neuronsSame(sameID);

% Final ID
IDsameA = intIDA(sameID);
IDsameB = intIDB(sameID);

% Only ID
nA = length(neuronsA);
nB = length(neuronsB);
nSame = length(neuronsSame);
nTotal = nA+nB-nSame;
IDonlyA = setdiff(1:nA,IDsameA);
IDonlyB = setdiff(1:nB,IDsameB);

% Get coordinates
XY.Same = (dataA.XY.All(IDsameA,:)+dataB.XY.All(IDsameB,:))/2;
XY.OnlyA = dataA.XY.All(IDonlyA,:);
XY.OnlyB = dataB.XY.All(IDonlyB,:);
XYAB = [XY.OnlyA; XY.Same; XY.OnlyB];

%% Descriptive parameters between videos

% Number of neurons
NumSame = nSame;
NumOnlyA = nA-nSame;
NumOnlyB = nB-nSame;

% FractionA = nA/nTotal;
% FractionB = nB/nTotal;
% FractionSame = nSame/nTotal;
% FractionOnlyA = NumOnlyA/nTotal;
% FractionOnlyB = NumOnlyB/nTotal;

%% Join neurons
neuronsAB = [neuronsA(IDonlyA) neuronsSame neuronsB(IDonlyB)];

%% Join raster from the same neurons
rA = dataA.Transients.Raster(IDsameA,:);
rB = dataB.Transients.Raster(IDsameB,:);
rasterSame = [rA rB];

%% Raster from all neurons
framesA = dataA.Movie.Frames;
framesB = dataB.Movie.Frames;
rOnlyA = dataA.Transients.Raster(IDonlyA,:);
rOnlyB = dataB.Transients.Raster(IDonlyB,:);
rOnlyA = [rOnlyA zeros([NumOnlyA framesB])];
rOnlyB = [zeros([NumOnlyB framesA]) rOnlyB];
rasterAB = [rOnlyA; rasterSame; rOnlyB];

%% Plot
% Plot intersection of masks
Set_Figure(strrep([inputname(1) ' & ' inputname(2)],'_','-'))
im(:,:,1) = maskA;
im(:,:,2) = zeros(size(maskA));
im(:,:,3) = maskB;
imshow(imadjust(im,[0 0.2],[]))
%imshowpair(maskA,maskB)
viscircles(XY.Same,repmat(4,1,NumSame),'Color','w','LineWidth',1,'EnhanceVisibility',false);
viscircles(XY.OnlyA,repmat(4,1,NumOnlyA),'Color','r','LineWidth',1,'EnhanceVisibility',false);
viscircles(XY.OnlyB,repmat(4,1,NumOnlyB),'Color','b','LineWidth',1,'EnhanceVisibility',false);
title({strrep([dataA.Movie.DataName ' & ' dataB.Movie.DataName(end-10:end)],'_','-');...
    ['total: ' num2str(nTotal) ' - intersection: ' num2str(nSame)]})

%% Getting extra data
% STD image
stdA = dataA.Movie.ImageSTD;
stdB = dataB.Movie.ImageSTD;
stdB = Apply_Motion(stdB,motion,'rigid');
stdA(stdA<=stdB) = 0;
stdB(stdB<stdA) = 0;
stdAB = stdA+stdB;

% STD image
avgA = dataA.Movie.ImageAverage;
avgB = dataB.Movie.ImageAverage;
avgB = Apply_Motion(avgB,motion,'rigid');
avgA(avgA<=avgB) = 0;
avgB(avgB<avgA) = 0;
avgAB = avgA+avgB;

% Voltage recording
dataAB.VoltageRecording.Stimuli = [dataA.VoltageRecording.Stimuli; dataB.VoltageRecording.Stimuli];
dataAB.VoltageRecording.Locomotion = [dataA.VoltageRecording.Locomotion; dataB.VoltageRecording.Locomotion];

%% Data combined
dataAB.Neurons = neuronsAB;
dataAB.Transients.Raster = rasterAB;
dataAB.Transients.Cells = nTotal;
dataAB.XY.All = XYAB;
dataAB.ROIs.CellWeightedMasksImage = (maskA+maskB)./2;
dataAB.Movie.DataName = [dataA.Movie.DataName '_' dataB.Movie.DataName(end-1:end)];
dataAB.Movie.Frames = dataA.Movie.Frames+dataB.Movie.Frames;
dataAB.Movie.ImageAverage = avgAB;
dataAB.Movie.ImageSTD = stdAB;
dataAB.Movie.FileName = dataAB.Movie.DataName;

% Set data from A (the warning is produced if they are different)
dataAB.Movie.Depth = dataA.Movie.Depth;
dataAB.Movie.FPS = dataA.Movie.FPS;
dataAB.Movie.Height = dataA.Movie.Height;
dataAB.Movie.Width = dataA.Movie.Width;

if dataA.Movie.Depth ~= dataB.Movie.Depth
    warning('Depth is different between data A and B!')
end
if dataA.Movie.FPS ~= dataB.Movie.FPS
    warning('FPS is different between data A and B!')
end
if dataA.Movie.Height ~= dataB.Movie.Height
    warning('Height is different between data A and B!')
end
if dataA.Movie.Width ~= dataB.Movie.Width
    warning('Width is different between data A and B!')
end