function [raster,cells,XY,rasterAll] = Get_Raster_Between_2_Videos(data1,data2,radius)
% Find the same neurons between 2 videos and get the raster of them
%
%       [raster,cells,XY,rasterAll] = Get_Raster_Between_2_Videos(data1,data2,minimumCoincidenceArea)
%
% By Jesus Perez-Ortega, Dec 2019

if nargin == 2
    % Considering a cell radius of 4
    radius = 4;
end

% Get neurons
neurons1 = data1.Neurons;
neurons2 = data2.Neurons;

% Get masks
mask1 = rescale(data1.ROIs.CellWeightedMasksImage);
mask2 = rescale(data2.ROIs.CellWeightedMasksImage);

% Apply rigid motion between 2 videos
% video(:,:,1) = data1.Movie.ImageAverage;
% video(:,:,2) = data2.Movie.ImageAverage;
video(:,:,1) = mask1;
video(:,:,2) = mask2;

% Get motion
[~,motion] = Registration(video,'rigid');

% Apply motion
mask2 = Apply_Motion(mask2,motion{2},'rigid');

% Get intersection of mask
mask = mask1 & mask2;

% Get intersection
[int1,intID1] = Find_Intersected_Neurons_With_Mask(neurons1,mask,radius);
[int2,intID2] = Find_Intersected_Neurons_With_Mask(neurons2,mask,radius);

% Evaluate shape
[~,~,sameID] = Evaluate_Shape_Neurons(int1,int2,256,256);

% Final ID
cells.FinalID1 = intID1(sameID);
cells.FinalID2 = intID2(sameID);

% Only ID
cells.OnlyID1 = setdiff(1:length(neurons1),cells.FinalID1);
cells.OnlyID2 = setdiff(1:length(neurons2),cells.FinalID2);

% Get coordinates
XY.Same = (data1.XY.All(cells.FinalID1,:)+data2.XY.All(cells.FinalID2,:))/2;
XY.Only1 = data1.XY.All(cells.OnlyID1,:);
XY.Only2 = data2.XY.All(cells.OnlyID2,:);

%% Descriptive parameters between videos

% Number of neurons
cells.NumSame = nnz(sameID);
cells.Num1 = length(neurons1);
cells.Num2 = length(neurons2);
cells.NumOnly1 = cells.Num1-cells.NumSame;
cells.NumOnly2 = cells.Num2-cells.NumSame;

cells.Total = cells.NumOnly1+cells.NumOnly2+cells.NumSame;
cells.Fraction1 = cells.Num1/cells.Total;
cells.Fraction2 = cells.Num2/cells.Total;
cells.FractionSame = cells.NumSame/cells.Total;
cells.FractionOnly1 = cells.NumOnly1/cells.Total;
cells.FractionOnly2 = cells.NumOnly2/cells.Total;

%% Join raster from the same neurons
r1 = data1.Transients.Raster(cells.FinalID1,:);
r2 = data2.Transients.Raster(cells.FinalID2,:);
raster = [r1 r2];

%% Raster from all neurons
rOnly1 = data1.Transients.Raster(cells.OnlyID1,:);
rOnly1 = [rOnly1 zeros(size(rOnly1))];
rOnly2 = data2.Transients.Raster(cells.OnlyID2,:);
rOnly2 = [zeros(size(rOnly2)) rOnly2];
rasterAll = [rOnly1; raster; rOnly2];

%% Plot
% Plot intersection of masks
Set_Figure(strrep([inputname(1) ' & ' inputname(2)],'_','-'))
imshowpair(mask1,mask2)
viscircles(XY.Same,repmat(4,1,cells.NumSame),'Color','w','LineWidth',1,'EnhanceVisibility',false);
viscircles(XY.Only1,repmat(4,1,cells.NumOnly1),'Color','g','LineWidth',1,'EnhanceVisibility',false);
%[x,y] = transformPointsForward(tform,u,v);
viscircles(XY.Only2,repmat(4,1,cells.NumOnly2),'Color','m','LineWidth',1,'EnhanceVisibility',false);
title(strrep([data1.Movie.DataName ' & ' data2.Movie.DataName],'_','-'))