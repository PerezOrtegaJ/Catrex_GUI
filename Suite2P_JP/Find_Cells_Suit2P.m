function [neuronalData,summary,conv_image,conv_discarded] = Find_Cells_Suit2P(uSmoothed,URaw,cellDiameter,options)
% Pipeline for cell detection from suit2P
%
%       [neuron_data,cells_image] = Find_Cells_Suit2P(U_smoothed,U_raw,cell_diameter,options)
%
% Modified by Jesus Perez-Ortega, July 2019
% Modified Sep 2019

if nargin == 4
    scaling = options.scaling;
    maxIterations = options.max_iterations;
    stopScaling = options.stop_scaling;
    maxNeurons = options.max_neurons;
else
    scaling = 1;
    maxIterations = 5;
    stopScaling = 10;
    maxNeurons = 10000;
end

% Get size of spatial mask
[y,x,n_SVD] = size(uSmoothed);

% reshape U to be (nMaps x Y x X)
uSmoothed = reshape(uSmoothed,[],n_SVD)';
uSmoothed = reshape(uSmoothed,n_SVD,y,x);

% compute neuropil basis functions for cell detection
if cellDiameter<15
    tiles = cellDiameter;
else
    tiles = 1;
end

S = Get_Neuropil_Basis(x,y,tiles);

n_basis = size(S,2);
StU = S'*uSmoothed(:,:)'; % covariance of neuropil with spatial masks
StS = S'*S; % covariance of neuropil basis functions

% regress maps onto basis functions and subtract neuropil contribution
neu = StS\StU;
U_cell = uSmoothed-reshape(neu'*S',size(uSmoothed));

% Get summary image
summary = imadjust(rescale(squeeze(var(U_cell))),[],[],0.1);

% Make cell mask 
sig = ceil(cellDiameter/4); 
dx = repmat(-cellDiameter:cellDiameter,2*cellDiameter+1, 1);
dy = dx';
rs = dx.^2+dy.^2-cellDiameter^2;
dx = dx(rs<=0);
dy = dy(rs<=0);

% initialize cell matrices
mPix = zeros(numel(dx),maxNeurons);
mLam = zeros(numel(dx),maxNeurons);
n_cells = 0;
L = sparse(y*x,0);
LtU = zeros(0,n_SVD);
LtS = zeros(0,n_basis);

for iter = 1:maxIterations
    
    % residual is smoothed at every iteration
    us = my_conv2_circ(U_cell, sig, [2 3]);
    V = double(squeeze(mean(us.^2,1)));
    
    % compute log variance at each location
    um = squeeze(mean(U_cell.^2,1));
    um = my_conv2_circ(um, sig, [1 2]);
    V = double(V./um);

    % do the morphological opening trick
    % take the running max of the running min
    % this normalizes the brightness of the image
    %if iter==1
        lbound = -my_min2(-my_min2(V,cellDiameter),cellDiameter);
    %end
    
    V = V - lbound;
    
    if iter==1        
        % find indices of all maxima  in plus minus 1 range
        % use the median of these peaks to decide stopping criterion
        maxV    = -my_min(-V, 1, [1 2]);
        ix      = (V > maxV-1e-10);
        
        % threshold is the mean peak, times a potential scaling factor
        pks = V(ix);
        Th  = scaling * median(pks(pks>1e-4));
        conv_image = V;
    end
    
    % just in case this goes above original value
    V = min(V, conv_image);
    
    % find local maxima in a +- d neighborhood
    maxV = -my_min(-V, cellDiameter, [1 2]);
    
    % find indices of these maxima above a threshold
    ix  = (V > maxV-1e-10) & (V > Th);
    ind = find(ix);
    if iter==1
       Nfirst = numel(ind); 
    elseif numel(ind)<Nfirst/stopScaling
        break;
    end
    new_codes = normc(us(:, ind));
    ncells = n_cells;
    LtU(ncells+size(new_codes,2), n_SVD) = 0;
    
    % each source needs to be iteratively subtracted off
    for i = 1:size(new_codes,2)
        n_cells = n_cells + 1;
        [ipix, ipos] = getIpix(ind(i), dx, dy, x, y);
        Usub = U_cell(:, ipix);
        lam = max(0, new_codes(:, i)' * Usub);        
        
        % threshold pixels
        lam(lam<max(lam)/5) = 0;        
        mPix(ipos,n_cells) = ipix;
        mLam(ipos,n_cells) = lam;
        
        % extract biggest connected region of lam only
        mLam(:,n_cells)   = normc(getConnected(mLam(:,n_cells), rs)); % ADD normc HERE and BELOW!!!
        lam             = mLam(ipos,n_cells) ;
        L(ipix,n_cells)   = lam;
        LtU(n_cells, :)   = uSmoothed(:,ipix) * lam;
        LtS(n_cells, :)   = lam' * S(ipix,:);
    end    
    
    % ADD NEUROPIL INTO REGRESSION HERE    
    LtL     = full(L'*L);
    codes   = ([LtL LtS; LtS' StS]+ 1e-3 * eye(n_cells+n_basis))\[LtU; StU];
    neu     = codes(n_cells+1:end,:);    
    codes   = codes(1:n_cells,:);
    
    % subtract off everything
    U_cell = uSmoothed - reshape(neu' * S', size(uSmoothed)) - reshape(double(codes') * L', size(uSmoothed));    
    
    % re-estimate masks
    L   = sparse(y*x, n_cells);
    for j = 1:n_cells        
        ipos = find(mPix(:,j)>0);
        ipix = mPix(ipos,j);        
        Usub = U_cell(:, ipix)+ codes(j, :)' * mLam(ipos,j)';
        lam = max(0, codes(j, :) * Usub);
        
        % threshold pixels
        lam(lam<max(lam)/5) = 0;
        mLam(ipos,j) = lam;

        % extract biggest connected region of lam only
        mLam(:,j) = normc(getConnected(mLam(:,j), rs));
        lam = mLam(ipos,j);
        L(ipix,j) = lam;
        LtU(j, :) = uSmoothed(:,ipix) * lam;
        LtS(j, :) = lam' * S(ipix,:);
        U_cell(:, ipix) = Usub - (Usub * lam)* lam';
    end
    
    % Print findings
    fprintf('   %d total ROIs, iteration %d\n', n_cells, iter)
end
conv_discarded = V;

%% Refine ROIs
%
% this runs only the mask re-estimation step, on non-smoothed PCs
% (because smoothing is done during clustering to help)

% reshape U to be (nMaps x Y x X)
URaw =  reshape(URaw, [], n_SVD)';
URaw = reshape(URaw, n_SVD, y, x);

% regress maps onto basis functions and subtract neuropil contribution
StU     = S'*URaw(:,:)'; % covariance of neuropil with spatial masks
neu     = StS\StU;

% set to 0 the masks, to be re-estimated
mLam    = zeros(numel(dx), 1e4);
L       = sparse(y*x, n_cells); 

for iter = 1:3
    % subtract off everything
    U_cell = URaw-reshape(neu'*S',size(URaw))-reshape(double(codes')*L',size(URaw));    
    
    % re-estimate masks
    L   = sparse(y*x, n_cells);
    for j = 1:n_cells        
        ipos = find(mPix(:,j)>0);
        ipix = mPix(ipos,j);        
        
        Usub = U_cell(:, ipix)+ codes(j, :)' * mLam(ipos,j)';
        lam = max(0, codes(j, :) * Usub);
        % threshold pixels
        lam(lam<max(lam)/5) = 0;
        mLam(ipos,j) = lam;

        % extract biggest connected region of lam only
        mLam(:,j) = normc(getConnected(mLam(:,j), rs));
        lam = mLam(ipos,j);
        L(ipix,j) = lam;
        U_cell(:, ipix) = Usub - (Usub * lam)* lam';
    end
    
    % ADD NEUROPIL INTO REGRESSION HERE    
    U_cell = U_cell + reshape(neu' * S', size(URaw));    
    StU     = S'*U_cell(:,:)'; % covariance of neuropil with spatial masks
    neu     = StS\StU;
end
%}

mLam  =  mLam(:, 1:n_cells);
mPix  =  mPix(:, 1:n_cells);
mLam = bsxfun(@rdivide, mLam, sum(mLam,1));

% Get neuron data
for i = 1:n_cells
    % Get pixels from cell
    ipos = find(mPix(:,i)>0 & mLam(:,i)>1e-6);
    ipix = mPix(ipos,i);
    [ypix, xpix] = ind2sub([y x], ipix);
    
    % write data
    neuronalData(i).pixels = ipix;
    neuronalData(i).weight_pixels = mLam(ipos,i);
    neuronalData(i).x_pixels = xpix;
    neuronalData(i).y_pixels = ypix;
    neuronalData(i).num_pixels = numel(ipix);
    neuronalData(i).x_median = round(median(neuronalData(i).x_pixels));
    neuronalData(i).y_median = round(median(neuronalData(i).y_pixels));
end

% Get overlaping
neuronalData = Get_Overlaping(neuronalData,x,y);

% Get eccentricity
neuronalData = Get_Eccentricity(neuronalData,x,y);

% Sort neurons
neuronalData = Sort_Neuron_Data(neuronalData);