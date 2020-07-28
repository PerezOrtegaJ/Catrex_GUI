function [ops, stat, F_cell, F_neu] = Get_Signals_And_Neuropil(data,stat)
% computes cell and neuropil fluorescence for surround model of neuropil
%
% Modified by Jesus Perez-Ortega, July 2019

[y,x,frames] = size(data);
n_RIOs = numel(stat); % all ROIs

% Get nonoverlaping pixels
stat = getNonOverlapROIs(stat, y, x);

% create cell masks and cell exclusion areas
[stat, cellPix, cellMasks] = createCellMasks(stat, y, x);

% create surround neuropil masks
[ops, neuropMasks] = createNeuropilMasks(ops, stat, cellPix);

% add surround neuropil masks to stat
for k = 1:n_RIOs
    stat(k).ipix_neuropil = find(squeeze(neuropMasks(k,:,:))>0);
end

% convert masks to sparse matrices for fast multiplication
neuropMasks = sparse(double(neuropMasks(:,:)));
cellMasks   = sparse(double(cellMasks(:,:)));

%% get fluorescence and surround neuropil
tic
data = reshape(data, [], frames);
data = double(data);

% compute cell fluorescence
% each mask is weighted by lam (SUM TO 1)
F_cell = cellMasks * data;

% compute neuropil fluorescence
F_neu = neuropMasks * data;

fprintf('Frame %d done in time %2.2f \n', frames, toc)
