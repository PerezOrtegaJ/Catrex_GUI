function neuron = Join_Neurons(neuronA,neuronB,height,width)
% Join neuronal data of 2 neurons
%
%       Join_Neurons(neuronA,neuronB)
%
% By Jesus Perez-Ortega, Sep 2019
% Modified Oct 2019

% Pixels
neuron.pixels = union(neuronA.pixels,neuronB.pixels);

% Weights
imA = zeros(height,width);
imA(neuronA.pixels) = neuronA.weight_pixels;
imB = zeros(height,width);
imB(neuronB.pixels) = neuronB.weight_pixels;
im = imA*neuronA.num_pixels+imB*neuronB.num_pixels;
im = im/sum(im(:));
id = find(im>0);
neuron.weight_pixels = im(id);

% xy pixels
x = ceil(id/height);
y = mod(id,height);
y(y==0) = height;
neuron.x_pixels = x;
neuron.y_pixels = y;

% Number of pixels 
neuron.num_pixels = numel(id);

% Median of pixels
neuron.x_median = round(median(neuron.x_pixels));
neuron.y_median = round(median(neuron.y_pixels));

% Median of pixels
neuron.overlap = [];
neuron.overlap_fraction = [];


