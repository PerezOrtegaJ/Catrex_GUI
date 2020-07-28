function dataAB = Union_Data(dataA,dataB)
% Get the union of the neurons between 2 videos
%
%       dataAB = Union_Data(dataA,dataB)
%
% By Jesus Perez-Ortega, Feb 2020

% Default
thMask = 0.1;
radius = dataA.ROIs.CellRadius;

% Get neurons
neuronsA = dataA.Neurons;
neuronsB = dataB.Neurons;

% Remove tuning properties to be consistent between evoked and non-evoked activity
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

% Get intersection between masks
mask = maskA & maskB;
maskAB = double(mask);
maskAB(mask) = (rescale(maskA(mask))+rescale(maskB(mask)))/2;
maskAB = maskAB>thMask;
same = regionprops(maskAB,'centroid','area');

% Remove areas less than ~1/3 of cell area (pi/3*r^2 ~= r^2)
id2remove = [same.Area]<radius^2;
same(id2remove)=[];

% Get properties from intersection
xyAB = reshape([same.Centroid],2,[]);
nAB = size(xyAB,2);

% Get neurons from A
xy = [neuronsA.x_median; neuronsA.y_median];
da = squareform(pdist([xyAB xy]','euclidean'));
[~,idA] = min(da(1:nAB,nAB+1:end),[],2);
neuronsAsame = neuronsA(idA);

% Get neurons from B
xy = [neuronsB.x_median; neuronsB.y_median];
da = squareform(pdist([xyAB xy]','euclidean'));
[~,idB] = min(da(1:nAB,nAB+1:end),[],2);
neuronsBsame = neuronsB(idB);

% Sort neurons from top to bottom, left to right
[neuronsAsame,idNeurons] = Sort_Neuron_Data(neuronsAsame);
neuronsBsame = neuronsBsame(idNeurons);
xyAB = xyAB(:,idNeurons);
idA = idA(idNeurons);
idB = idB(idNeurons);

% Get pixels and areas
pixelsA = {neuronsAsame.pixels};
pixelsB = {neuronsBsame.pixels};
areasFraction = zeros(1,nAB);
for i = 1:nAB
    area = length(unique([pixelsA{i}; pixelsB{i}]));
    intersectAB = length(intersect(pixelsA{i},pixelsB{i}));
    areasFraction(i) = intersectAB/area;
end

% Remove intersection with less than 0.4 fraction of the area
id2remove = find(areasFraction<0.4);
neuronsBsame(id2remove) = [];
idA(id2remove) = [];
idB(id2remove) = [];
xyAB(:,id2remove) = [];
nAB = size(xyAB,2);


% Only ID
nA = length(neuronsA);
nB = length(neuronsB);
nTotal = nA+nB-nAB;
idOnlyA = setdiff(1:nA,idA);
idOnlyB = setdiff(1:nB,idB);
nOnlyA = length(idOnlyA);
nOnlyB = length(idOnlyB);


fractionAB = nAB/nTotal;
fractionOnlyA = nOnlyA/nTotal;
fractionOnlyB = nOnlyB/nTotal;

% Get coordinates
xyOnlyA = dataA.XY.All(idOnlyA,:);
xyOnlyB = dataB.XY.All(idOnlyB,:);
xyOnlyAB = [xyOnlyA; xyOnlyB];
xyAB = [xyOnlyA; xyAB'; xyOnlyB];

%% Plot and get data
% Create images of merge 
im(:,:,1) = maskA;
im(:,:,2) = maskB;
im(:,:,3) = maskA;
im = imadjust(im,[0 0.3],[]);

% Plot
Set_Figure(['Union - ' strrep([inputname(1) ' & ' inputname(2)],'_','-')],[0 0 600 600])
imshow(im,'InitialMagnification','fit')
hold on
%viscircles(xyAB,repmat(4,1,nAB),'Color','w','LineWidth',1,'EnhanceVisibility',false);
title({[strrep(dataA.Movie.DataName,'_','-') ' (magenta): '...
    num2str(nOnlyA) ' (' num2str(fractionOnlyA*100,'%.1f') '%)'];...
    [strrep(dataB.Movie.DataName,'_','-') ' (green): '...
    num2str(nOnlyB) ' (' num2str(fractionOnlyB*100,'%.1f') '%)'];...
    ['Intersection (white): ' num2str(nAB)  ' (' num2str(fractionAB*100,'%.1f') '%)']})
%text(xyAB(:,1),xyAB(:,2),num2str((1:nAB)'),'color','w')

% Join neurons
neuronsAB = [neuronsA(idOnlyA) neuronsBsame neuronsB(idOnlyB)];

% Get frames
framesA = dataA.Movie.Frames;
framesB = dataB.Movie.Frames;
framesAB = framesA+framesB;

% Get raster
rA = dataA.Transients.Raster(idA,:);
rB = dataB.Transients.Raster(idB,:);
rasterAB = [rA rB];
onlyA = dataA.Transients.Raster(idOnlyA,:);
onlyB = dataB.Transients.Raster(idOnlyB,:);
onlyA = [onlyA zeros([nOnlyA framesB])];
onlyB = [zeros([nOnlyB framesA]) onlyB];
rasterAB = [onlyA; rasterAB; onlyB];

% Get raw data
rawA = dataA.Transients.Raw(idA,:);
rawB = dataB.Transients.Raw(idB,:);
rawAB = [rawA rawB];
onlyA = dataA.Transients.Raw(idOnlyA,:);
onlyB = dataB.Transients.Raw(idOnlyB,:);
onlyA = [onlyA zeros([nOnlyA framesB])];
onlyB = [zeros([nOnlyB framesA]) onlyB];
rawAB = [onlyA; rawAB; onlyB];

% Get filtered data
fltA = dataA.Transients.Filtered(idA,:);
fltB = dataB.Transients.Filtered(idB,:);
fltAB = [fltA fltB];
onlyA = dataA.Transients.Filtered(idOnlyA,:);
onlyB = dataB.Transients.Filtered(idOnlyB,:);
onlyA = [onlyA zeros([nOnlyA framesB])];
onlyB = [zeros([nOnlyB framesA]) onlyB];
fltAB = [onlyA; fltAB; onlyB];

% Get smoothed data
smtA = dataA.Transients.Smoothed(idA,:);
smtB = dataB.Transients.Smoothed(idB,:);
smtAB = [smtA smtB];
onlyA = dataA.Transients.Smoothed(idOnlyA,:);
onlyB = dataB.Transients.Smoothed(idOnlyB,:);
onlyA = [onlyA zeros([nOnlyA framesB])];
onlyB = [zeros([nOnlyB framesA]) onlyB];
smtAB = [onlyA; smtAB; onlyB];

% Get F0
f0A = dataA.Transients.F0(idA,:);
f0B = dataB.Transients.F0(idB,:);
f0AB = [f0A f0B];
onlyA = dataA.Transients.F0(idOnlyA,:);
onlyB = dataB.Transients.F0(idOnlyB,:);
onlyA = [onlyA zeros([nOnlyA framesB])];
onlyB = [zeros([nOnlyB framesA]) onlyB];
f0AB = [onlyA; f0AB; onlyB];

% Get Inference
infA = dataA.Transients.Inference(idA,:);
infB = dataB.Transients.Inference(idB,:);
infAB = [infA infB];
onlyA = dataA.Transients.Inference(idOnlyA,:);
onlyB = dataB.Transients.Inference(idOnlyB,:);
onlyA = [onlyA zeros([nOnlyA framesB])];
onlyB = [zeros([nOnlyB framesA]) onlyB];
infAB = [onlyA; infAB; onlyB];

% Get Model
mdlA = dataA.Transients.Model(idA,:);
mdlB = dataB.Transients.Model(idB,:);
mdlAB = [mdlA mdlB];
onlyA = dataA.Transients.Model(idOnlyA,:);
onlyB = dataB.Transients.Model(idOnlyB,:);
onlyA = [onlyA zeros([nOnlyA framesB])];
onlyB = [zeros([nOnlyB framesA]) onlyB];
mdlAB = [onlyA; mdlAB; onlyB];

% Get Field
fldA = dataA.Transients.Field;
fldB = dataB.Transients.Field;
fldAB = [fldA; fldB];

% Get PSNR
psnrAB = mean([dataA.Transients.PSNR(idA) dataB.Transients.PSNR(idB)],2);
onlyA = dataA.Transients.PSNR(idOnlyA);
onlyB = dataB.Transients.PSNR(idOnlyB);
psnrAB = [onlyA; psnrAB; onlyB];

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
dataAB.Transients.Raw = rawAB;
dataAB.Transients.Filtered = fltAB;
dataAB.Transients.Smoothed = smtAB;
dataAB.Transients.F0 = f0AB;
dataAB.Transients.Field = fldAB;
dataAB.Transients.Inference = infAB;
dataAB.Transients.Model =mdlAB;
dataAB.Transients.Cells = nTotal;
dataAB.Transients.PSNR = psnrAB;
dataAB.XY.All = xyAB;
dataAB.ROIs.CellWeightedMasksImage = (maskA+maskB)./2;
dataAB.Movie.DataName = [dataA.Movie.DataName '_' dataB.Movie.DataName(end-1:end)];
dataAB.Movie.Frames = framesAB;
dataAB.Movie.ImageAverage = avgAB;
dataAB.Movie.ImageSTD = stdAB;
dataAB.Movie.FileName = dataAB.Movie.DataName;

% Set data from A (the warning is produced if they are different)
dataAB.ROIs.CellRadius = dataA.ROIs.CellRadius;
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
if dataA.ROIs.CellRadius ~= dataB.ROIs.CellRadius
    warning('Radius is different between data A and B!')
end
