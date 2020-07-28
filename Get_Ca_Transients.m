function [transients,raw,f0,field] = Get_Ca_Transients(mov,xy,rCell,rAura)
% Get Ca transients by aura filter
%
%       [transients,raw,f0,field] = Get_Ca_Transients(mov,xy,rCell,rAura)
%
% Jesus Perez-Ortega March-19
% Modified Oct 2019

% Data from video
[h,w,frames]= size(mov);

nCells = size(xy,1);

disp(['Computing ' num2str(nCells) ' transients...'])

switch(nargin)
    case 3
        rAura = repmat(4*rCell,1,frames);
    case 2
        rCell = repmat(4,1,frames);
        rAura = repmat(4*rCell,1,frames);
end

if length(rCell)==1
    rCell = repmat(rCell,1,nCells);
end

if length(rAura)==1
    rAura = repmat(rAura,1,nCells);
end

% Initialize
imageSize = [h,w];

% Get raw transients
tic

% Get average from whole image
field = squeeze(mean(mean(mov)));

% Create masks
cellsMask = zeros(nCells,h*w);
aurasMask = zeros(nCells,h*w);
for i = 1:nCells    
    % Create a circle mask from the cell
    cell_mask = Circle_Mask(imageSize,xy(i,:),rCell(i));
    aura_mask = Circle_Mask(imageSize,xy(i,:),rAura(i));
    aura_mask = xor(aura_mask,cell_mask);
    
    cellsMask(i,:) = cell_mask(:);
    aurasMask(i,:) = aura_mask(:);
end

% Delete ROIs pixels from auras
cells_pix = sum(cellsMask,1)==0;
aurasMask = bsxfun(@times,aurasMask,cells_pix);

% Make 1 the sum of pixels
n_cells_pix = sum(cellsMask,2);
cellsMask = cellsMask./n_cells_pix;
n_auras_pix = sum(aurasMask,2);
aurasMask = aurasMask./n_auras_pix;

% Get transients
mov = single(reshape(mov,[],frames));

% Get the raw signal
raw = cellsMask*mov;
raw(isnan(raw)) = 0;

% Get the basal level by the cell aura
f0 = aurasMask*mov;
f0(isnan(f0)) = 0;

% Filter raw transients by substracting the aura
transients = (raw-f0)./f0;

% Adjust minimum value to 0
transients = transients-min(transients,[],2);
t=toc; disp(['   Done (' num2str(t) ' seconds)'])