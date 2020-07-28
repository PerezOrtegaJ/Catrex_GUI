function [neurons,id,regions] = Find_Intersected_Neurons_With_Mask(neurons,mask,radius)
% Find intersected neurons given a mask and a minimum coincident pixels
%
%       [neurons,id,same] = Find_Intersected_Neurons_With_Mask(neurons,mask,radius)
%
% By Jesus Perez-Ortega, Dec 2019
% modified Feb 2020

% Detect same active neurons
%mask = imerode(mask,strel('disk', ceil(radius/4)));
regions = regionprops(mask,'centroid','area');
id = [regions.Area]<radius^2;
regions(id)=[];
xySame = reshape([regions.Centroid],2,[]);
nSame = size(xySame,2);
areasSame = [regions.Area];

% Find intersected neurons
xy = [neurons.x_median; neurons.y_median];
da = squareform(pdist([xySame xy]','euclidean'));
[~,id] = min(da(1:nSame,nSame+1:end),[],2);
%id = unique(id);
neurons = neurons(id);

% Output same
same.XY = xySame;
same.Areas = areasSame;
same.N = nSame;