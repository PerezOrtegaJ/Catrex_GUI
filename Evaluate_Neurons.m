function [neuronalData,idsRemoved] = Evaluate_Neurons(neuronalData,minPixels,maxPixels,...
    minCircularity,maxPerimeter,maxEccentricity,x,y,outline)
% Remove neurons less than n number of pixels
%
%       [neuronalData,idsRemoved] = Evaluate_Neurons(neuronalData,minPixels,maxPixels,
%            minCircularity,maxPerimeter,maxEccentricity,x,y,outline)
%
% By Jesus Perez-Ortega, July 2019
% Modified Sep 2019
% Modified Oct 2019

% id to be removed
idsRemoved = zeros(1,length(neuronalData),'logical');

% Neurons with less than n number of pixels
id = [neuronalData.num_pixels]<minPixels;
idsRemoved = idsRemoved | id;

% Neurons with more than n number of pixels
id = [neuronalData.num_pixels]>maxPixels;
idsRemoved = idsRemoved | id;

% Neurons from boundaries
id = [neuronalData.x_median]>x-outline;
idsRemoved = idsRemoved | id;
id = [neuronalData.x_median]<=outline;
idsRemoved = idsRemoved | id;
id = [neuronalData.y_median]>y-outline;
idsRemoved = idsRemoved | id;
id = [neuronalData.y_median]<=outline;
idsRemoved = idsRemoved | id;

% Neurons less than minimum circularity
id = [neuronalData.Circularity]<minCircularity;
idsRemoved = idsRemoved | id;

% Neurons more Eccentricity than maximum eccentricity
id = [neuronalData.Eccentricity]>maxEccentricity;
idsRemoved = idsRemoved | id;

% Neurons more Perimeter than maximum perimeter
id = [neuronalData.Perimeter]>maxPerimeter;
idsRemoved = idsRemoved | id;

% Remove neurons
neuronalData(idsRemoved) = [];
idsRemoved = find(idsRemoved);