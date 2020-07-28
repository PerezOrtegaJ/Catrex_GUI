function neuron_data = Evaluate_Neurons(neuron_data,min_pixels,max_pixels,x,y,outline,overlaping)
% Remove neurons less than n number of pixels
%
%       neuron_data = Remove_Bad_Neurons(neuron_data,num_pixels,x,y,outline)
%
% By Jesus Perez-Ortega, July 2019

%% Remove neurons with less than n number of pixels
id = [neuron_data.num_pixels]<min_pixels;
neuron_data(id) = [];

%% Remove neurons with more than n number of pixels
id = [neuron_data.num_pixels]>max_pixels;
neuron_data(id) = [];

%% Remove neurons from boundaries
id = [neuron_data.x_median]>x-outline;
neuron_data(id) = [];

id = [neuron_data.x_median]<=outline;
neuron_data(id) = [];

id = [neuron_data.y_median]>y-outline;
neuron_data(id) = [];

id = [neuron_data.y_median]<=outline;
neuron_data(id) = [];

%% Remove neuros with >= fraction of overlaped pixels
% Identify ovelaped pixels
mask = zeros(y,x);
n_cells = length(neuron_data);
for i = 1:n_cells
   mask(neuron_data(i).pixels) = mask(neuron_data(i).pixels) + 1;
end
for i = 1:n_cells
   neuron_data(i).overlap = mask(neuron_data(i).pixels)>1;
   neuron_data(i).overlap_fraction = mean(neuron_data(i).overlap); 
end

id = [neuron_data.overlap_fraction]>=overlaping;
neuron_data(id) = [];


