function [dataAB,cells,registration,im] = Intersect_Data(dataA,dataB,blackBG,plotFigure)
% Get the intersection of the neurons between 2 videos
%
%       [dataAB,cells,registration,im] = Intersect_Data(dataA,dataB)
%
% By Jesus Perez-Ortega, Feb 2020

switch(nargin)
    case 2
        blackBG = false;
        plotFigure = false;
    case 3
        plotFigure = false;
end

disp('Finding intersection between data...')
tic
% Default
thMask = 0.1;
radius = dataA.ROIs.CellRadius;

% Get neurons
neuronsA = dataA.Neurons;
neuronsB = dataB.Neurons;

% Get masks
maskA = rescale(dataA.ROIs.CellWeightedMasksImage);
maskB = rescale(dataB.ROIs.CellWeightedMasksImage);

% Registration, first rigid (similarity) then nonrigid
[maskB,motion,displacement] = Register_Masks(maskA,maskB);
registration.Motion = motion;
registration.Displacement = displacement;

% Get intersection between masks
mask = maskA & maskB;
maskAB = double(mask);
maskAB(mask) = (rescale(maskA(mask))+rescale(maskB(mask)))/2;
maskAB = maskAB>thMask;
same = regionprops(maskAB,'centroid','area');

disp(['   ' num2str(length(same)) ' intersections'])

% Remove areas less than ~1/3 of cell area (pi/3*r^2 ~= r^2)
id2remove = [same.Area]<(pi*radius^2/2);
same(id2remove)=[];

disp(['   ' num2str(nnz(id2remove)) ' removed (area less than ' num2str(radius^2) ' pixels)'])

% Get properties from intersection
xyAB = reshape([same.Centroid],2,[]);
nAB = size(xyAB,2);

% Get neurons from A
xy = [neuronsA.x_median; neuronsA.y_median];
da = squareform(pdist([xyAB xy]','euclidean'));
[~,idA] = min(da(1:nAB,nAB+1:end),[],2);
neuronsAsame = neuronsA(idA);
xyA = [neuronsAsame.x_median; neuronsAsame.y_median];

% Get neurons from B
xy = [neuronsB.x_median; neuronsB.y_median];
da = squareform(pdist([xyAB xy]','euclidean'));
[~,idB] = min(da(1:nAB,nAB+1:end),[],2);
neuronsBsame = neuronsB(idB);
xyB = [neuronsBsame.x_median; neuronsBsame.y_median];

% Sort neurons from top to bottom, left to right
[neuronsAB,idNeurons] = Sort_Neuron_Data(neuronsAsame);
xyAB = xyAB(:,idNeurons);
idA = idA(idNeurons);
idB = idB(idNeurons);
xyA = xyA(:,idNeurons);
xyB = xyB(:,idNeurons);

d = zeros(1,nAB);
for i = 1:nAB
    % Motion correction on coordinates 
    [x,y] = transformPointsForward(motion,xyB(1,i),xyB(2,i));
    
    % Displcement correction
    if x<1, x = 1; end
    if y<1, y = 1; end
    if x>dataA.Movie.Width, x = dataA.Movie.Width; end
    if y>dataA.Movie.Height, y = dataA.Movie.Height; end
    xt = x-displacement(round(y),round(x),1);
    yt = y-displacement(round(y),round(x),2);
    xyT(:,i) = [xt;yt];
    
    % Compute distance between centroids
    d(i) = pdist([xyA(:,i) [xt;yt]]','euclidean');
end

% Remove intersection with less than thFraction of the area
id2remove = d>radius;
neuronsAB(id2remove) = [];
idA(id2remove) = [];
idB(id2remove) = [];
xyAB(:,id2remove) = [];
nAB = size(xyAB,2);

disp(['   ' num2str(nnz(id2remove)) ' removed (centroids distance between cells bigger than ' num2str(radius) ' pixels)'])
disp(['   Total intersected neurons: ' num2str(nAB)])

%% Number of neurons
% Only ID
nA = length(neuronsA);
nB = length(neuronsB);
nTotal = nA+nB-nAB;
idOnlyA = setdiff(1:nA,idA);
idOnlyB = setdiff(1:nB,idB);
nOnlyA = length(idOnlyA);
nOnlyB = length(idOnlyB);

fractionA = nA/nTotal;
fractionB = nB/nTotal;
fractionAB = nAB/nTotal;
fractionOnlyA = nOnlyA/nTotal;
fractionOnlyB = nOnlyB/nTotal;

%% Collect data
% Get raster
rA = dataA.Transients.Raster(idA,:);
rB = dataB.Transients.Raster(idB,:);
rasterAB = [rA rB];

% Get raw data
rawA = dataA.Transients.Raw(idA,:);
rawB = dataB.Transients.Raw(idB,:);
rawAB = [rawA rawB];

% Get filtered data
fltA = dataA.Transients.Filtered(idA,:);
fltB = dataB.Transients.Filtered(idB,:);
fltAB = [fltA fltB];

% Get smoothed data
smtA = dataA.Transients.Smoothed(idA,:);
smtB = dataB.Transients.Smoothed(idB,:);
smtAB = [smtA smtB];

% Get F0
f0A = dataA.Transients.F0(idA,:);
f0B = dataB.Transients.F0(idB,:);
f0AB = [f0A f0B];

% Get Inference
infA = dataA.Transients.Inference(idA,:);
infB = dataB.Transients.Inference(idB,:);
infAB = [infA infB];

% Get Model
mdlA = dataA.Transients.Model(idA,:);
mdlB = dataB.Transients.Model(idB,:);
mdlAB = [mdlA mdlB];

% Get Field
fldA = dataA.Transients.Field;
fldB = dataB.Transients.Field;
fldAB = [fldA; fldB];

%% Getting extra data
% STD image
stdA = dataA.Movie.ImageSTD;
stdB = dataB.Movie.ImageSTD;
stdB = Apply_Motion(stdB,motion,'rigid');
stdB = Apply_Motion(stdB,displacement,'nonrigid');
stdA(stdA<=stdB) = 0;
stdB(stdB<stdA) = 0;
stdAB = stdA+stdB;

% STD image
avgA = dataA.Movie.ImageAverage;
avgB = dataB.Movie.ImageAverage;
avgB = Apply_Motion(avgB,motion,'rigid');
avgB = Apply_Motion(avgB,displacement,'nonrigid');
avgA(avgA<=avgB) = 0;
avgB(avgB<avgA) = 0;
avgAB = avgA+avgB;

% Summary image
sumA = dataA.Movie.Summary;
sumB = dataB.Movie.Summary;
sumB = Apply_Motion(sumB,motion,'rigid');
sumB = Apply_Motion(sumB,displacement,'nonrigid');
sumAB = (sumA+sumB)/2;

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
dataAB.Transients.Cells = nAB;
dataAB.Transients.PSNR = mean([dataA.Transients.PSNR(idA) dataB.Transients.PSNR(idB)],2);
dataAB.XY.All = xyAB';
dataAB.ROIs.CellWeightedMasksImage = (maskA+maskB)./2;
dataAB.Movie.DataName = [dataA.Movie.DataName '_' dataB.Movie.DataName(end-1:end)];
dataAB.Movie.Frames = dataA.Movie.Frames+dataB.Movie.Frames;
dataAB.Movie.ImageAverage = avgAB;
dataAB.Movie.ImageSTD = stdAB;
dataAB.Movie.Summary = sumAB;
dataAB.Movie.FileName = dataAB.Movie.DataName;

% Set data from A (the warning is produced if they are different)
dataAB.ROIs.CellRadius = dataA.ROIs.CellRadius;
dataAB.Movie.Depth = dataA.Movie.Depth;
dataAB.Movie.FPS = dataA.Movie.FPS;
dataAB.Movie.Height = dataA.Movie.Height;
dataAB.Movie.Width = dataA.Movie.Width;

% Cells data
cells.NumSame = nAB;
cells.NumA = nA;
cells.NumB = nB;
cells.NumOnlyA = nOnlyA;
cells.NumOnlyB = nOnlyB;

cells.Total = nTotal;
cells.FractionA = fractionA;
cells.FractionB = fractionB;
cells.FractionAB = fractionAB;
cells.FractionOnlyA = fractionOnlyA;
cells.FractionOnlyB = fractionOnlyB;

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

%% Get image and plot
% Create images of merge
if blackBG
    % black background
    im(:,:,1) = maskA;
    im(:,:,2) = maskB;
    im(:,:,3) = maskA;
    im = imadjust(im,[0 0.3],[]);
else
    % white background
    im(:,:,1) = maskA;
    im(:,:,2) = maskB;
    im(:,:,3) = maskA;
    im = 1 -im;
    im = imadjust(im,[0.7 1],[]);
end

if plotFigure
    Set_Figure(['Intersection - ' strrep([inputname(1) ' & ' inputname(2)],'_','-')],[0 0 600 600])
    imshow(im,'InitialMagnification','fit')
    hold on

    if blackBG
        %viscircles(xyAB',repmat(radius*1.5,1,nAB),'Color','w','LineWidth',1,'EnhanceVisibility',false);
        title({[strrep(dataA.Movie.DataName,'_','-') ' (red): '...
            num2str(nOnlyA) ' (' num2str(fractionOnlyA*100,'%.1f') '%)'];...
            [strrep(dataB.Movie.DataName,'_','-') ' (blue): '...
            num2str(nOnlyB) ' (' num2str(fractionOnlyB*100,'%.1f') '%)'];...
            ['Intersection (purple): ' num2str(nAB)  ' (' num2str(fractionAB*100,'%.1f') '%)']})
        %text(xyAB(1,:),xyAB(2,:),num2str((1:nAB)'),'color','w')
    else
    %     viscircles(xyA',repmat(radius*1.5,1,nAB+nnz(id2remove)),'Color',[1 0 0],'LineWidth',1,'EnhanceVisibility',false);
    %     viscircles(xyT',repmat(radius*1.5,1,nAB+nnz(id2remove)),'Color',[1 0 0],'LineWidth',1,'EnhanceVisibility',false);
    %     viscircles(xyAB',repmat(radius*1.2,1,nAB),'Color',[0.3 0.3 0.3],'LineWidth',1,'EnhanceVisibility',false);
        title({[strrep(dataA.Movie.DataName,'_','-') ' (magenta): '...
            num2str(nOnlyA) ' (' num2str(fractionOnlyA*100,'%.1f') '%)'];...
            [strrep(dataB.Movie.DataName,'_','-') ' (green): '...
            num2str(nOnlyB) ' (' num2str(fractionOnlyB*100,'%.1f') '%)'];...
            ['Intersection (white): ' num2str(nAB)  ' (' num2str(fractionAB*100,'%.1f') '%)']})
    end
end
t = toc; disp(['   Done (' num2str(t) ' seconds)'])
