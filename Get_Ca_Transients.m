function [transients,raw,f0,tendence] = Get_Ca_Transients(mov,xy,r_cell,r_aura)
% Get Ca transients by aura filter
%
% Jesus Perez-Ortega March-19

% Data from video
[h,w,n_frames]= size(mov);
n_cells = size(xy,1);

switch(nargin)
    case 3
        r_aura = repmat(4*r_cell,1,n_frames);
    case 2
        r_cell = repmat(4,1,n_frames);
        r_aura = repmat(4*r_cell,1,n_frames);
end

if length(r_cell)==1
    r_cell = repmat(r_cell,1,n_cells);
    r_aura = repmat(r_aura,1,n_cells);
end

% Initialize
image_size = [h,w];
tendence = zeros(1,n_frames);
raw = zeros(n_cells,n_frames);
f0 = zeros(n_cells,n_frames);

% Get raw ransients
tic
for i = 1:n_cells    
    % Create a circle mask from the cell
    cell_mask = Circle_Mask(image_size,xy(i,:),r_cell(i));
    aura_mask = Circle_Mask(image_size,xy(i,:),r_aura(i));
    aura_mask = xor(aura_mask,cell_mask);
    % Get local signal
    for j = 1:n_frames
        % Get frame
        image = mov(:,:,j);
        % Get the raw signal
        raw(i,j) = mean(image(cell_mask));
        % Get the basal level by the cell aura
        f0(i,j) = mean(image(aura_mask));
    end
    % Show the state of computation each 100 frames
    if ~mod(i,10)
        t = toc; 
        fprintf('%d/%d, %.1f s\n',i,n_cells,t)
    end
end

% Get average from whole image
tendence = squeeze(mean(mean(mov)));

t = toc; 
fprintf('%d/%d, %.1f s\n',i,n_cells,t)

% Filter raw transients by substracting the aura
transients = (raw-f0)./f0;

% Adjust minimum value to 0
transients = transients-min(transients,[],2);

% Normalize
% norm = normalize(raw,2);