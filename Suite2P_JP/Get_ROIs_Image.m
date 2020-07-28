function ROIs_image = Get_ROIs_Image(neuron_data,x,y)
% Draw ROI clusters from Suite2P
%
% Modified by Jesus Perez-Ortega, July 2019

n_cells = length(neuron_data);

for i = 1:n_cells
    mPix(1:neuron_data(i).num_pixels,i) = neuron_data(i).pixels;
    mLam(1:neuron_data(i).num_pixels,i) = neuron_data(i).weight_pixels;
end
iclust = zeros(y,x);
lam = zeros(y,x);

% tuning colors 
% -2, locomotion correlated
% -1, inter-stimulus correlated
% 0, others
% 1-8, orientation
if isfield(neuron_data,'TuningID')
    colors_HSV = [0.9 0.2 0.9;...
                  0.8 0.5 0.9;...
                  0.0 0.0 0.0;...
                  0.0 0.9 0.9;... 
                  0.2 0.9 0.9;... 
                  0.4 0.9 0.9;... 
                  0.6 0.9 0.9;...
                  0.0 0.5 0.9;...
                  0.2 0.5 0.9;... 
                  0.4 0.5 0.9;... 
                  0.6 0.5 0.9];
    hues = zeros(n_cells,1);
    saturation = zeros(n_cells,1);
    for i = 1:n_cells
        hues(i) = colors_HSV(neuron_data(i).TuningID+3,1);
        saturation(i) = colors_HSV(neuron_data(i).TuningID+3,2);
    end
else
    hues = rand(n_cells, 1);
    saturation = ones(n_cells,1);
end

% Get ROIs
for i = n_cells:-1:1
    ipos = find(mPix(:,i)>0);
    ipix = lam(mPix(ipos,i))+1e-4 < mLam(ipos,i);
    iclust(mPix(ipos(ipix),i)) = i;
    lam(mPix(ipos(ipix),i)) = mLam(ipos(ipix),i);
end

% Get values
hue = zeros(y, x);
hue(iclust>0) = hues(iclust(iclust>0));
hue = reshape(hue, y, x);

sat = zeros(y, x);
sat(iclust>0) = saturation(iclust(iclust>0));
sat = reshape(sat, y, x);

value = max(0, min(0.75 * reshape(lam, y, x)/mean(lam(lam>1e-10)), 1));

% Create image
ROIs_image = hsv2rgb(cat(3,hue,sat,value));