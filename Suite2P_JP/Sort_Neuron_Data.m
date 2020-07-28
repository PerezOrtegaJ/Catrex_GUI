function neuron_data = Sort_Neuron_Data(neuron_data)
% Sort neurons
%
%       neuron_data = Sort_Neuron_Data(neuron_data)
%
% By Jesus Perez-Ortega, July 2019

[~,id_1] = sort([neuron_data.x_median]);
[~,id_2] = sort([neuron_data(id_1).y_median]);
neuron_data = neuron_data(id_1(id_2));