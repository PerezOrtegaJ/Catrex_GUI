function summary = Get_Summary_Image(spatialMask,tiles)
% Get the summary image from spatial masks
%
%   summary = Get_Summary_Image(U_smoothed,cell_diameter,options)
%
% Modified by Jesus Perez-Ortega, July 2019
% Modified Sep 2019

% Get size of spatial mask
[y,x,n_SVD] = size(spatialMask);

% reshape U to be (nMaps x Y x X)
spatialMask = reshape(spatialMask,[],n_SVD)';
spatialMask = reshape(spatialMask,n_SVD,y,x);

% compute neuropil basis functions for cell detection
% tiles = cell diameter
S = Get_Neuropil_Basis(x,y,tiles);

StU = S'*spatialMask(:,:)'; % covariance of neuropil with spatial masks
StS = S'*S; % covariance of neuropil basis functions

% regress maps onto basis functions and subtract neuropil contribution
neu = StS\StU;
U_cell = spatialMask - reshape(neu' * S', size(spatialMask));

% Get summary image
summary = imadjust(rescale(squeeze(var(U_cell))),[],[],0.1);