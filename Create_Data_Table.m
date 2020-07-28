function data_table = Create_Data_Table(raster,stimuli,type)
% Create a data table for train and/or test
%
%       Create_Data_Table(raster,stimuli,type)
%
%       type could be 'single' or 'join' 
%
% By Jesus Perez-Ortega, July 2019

% Get indices for create vectors
switch type
    case 'join'
        vector_id = Find_Peaks_Or_Valleys(stimuli);
        stimuli = Delete_Consecutive_Coactivation(stimuli')';
    case 'single'
        vector_id = Find_Peaks_Or_Valleys(stimuli,0,false);
end

stimuli(stimuli==0) = [];
string_cat = sprintf(['stimuli = categorical(stimuli,1:8,{''\x2192'',''\x2190'',''\x2197'',''\x2199''' ...
    ',''\x2191'',''\x2193'',''\x2196'',''\x2198''});']);
eval(string_cat)
% Create a matrix with all vector peaks
neuron = Get_Peak_Vectors(raster,vector_id,'sum');
%neuron = Get_Peak_Vectors(raster,vector_id,'network','coactivity',1);

% Create a table
data_table = array2table(neuron);
data_table = [data_table table(stimuli,'VariableNames',{'Stim'})];
