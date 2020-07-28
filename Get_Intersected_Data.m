function [table_a,table_b,int_a,int_b] = Get_Intersected_Data(data_a,data_b,neurons_type,data_type,observation_type)
% Get intersected data of neurons
%
%       [table_a,table_b,int_a,int_b] = Get_Intersected_Data(data_a,data_b,neurons_type,data_type,observation_type)
%
%       neurons_type: 'all', 'none', 'tuned', 'inter', 'locomotion' or 'others'
%       data_type: 'raster' or 'inference'
%       observation_type: 'single' or 'join' 
%
% By Jesus Perez-Ortega, July 2019

% Extract parameters
w = data_a.Movie.Width;
h = data_a.Movie.Height;
cell_radius = data_a.ROIs.CellRadius;

switch neurons_type
    case {'all','none'}
        % Intersection of all
        [int_a,int_b] = Find_Intersected_Neurons(data_a.Neurons,data_b.Neurons,w,h,cell_radius);
        
        % No-intersected neurons
        if strcmp(neurons_type,'none')
            int_a = set_diff(1:length(data_a.Neurons),int_a);
            int_b = set_diff(1:length(data_b.Neurons),int_b);
        end
    case {'tuned', 'inter', 'locomotion', 'others'}
        switch neurons_type
            case 'tuned'
                % Intersection of tuned
                id_a = find([data_a.Neurons.TuningID]>0);
                id_b = find([data_b.Neurons.TuningID]>0);
            case 'inter'
                % Intersection of inter-stimulus correlated
                id_a = find([data_a.Neurons.TuningID]==-1);
                id_b = find([data_b.Neurons.TuningID]==-1);
            case 'locomotion'
                % Intersection of locomotion correlated
                id_a = find([data_a.Neurons.TuningID]==-2);
                id_b = find([data_b.Neurons.TuningID]==-2);
            case 'others'
                % Intersection of others neurons
                id_a = find([data_a.Neurons.TuningID]==0);
                id_b = find([data_b.Neurons.TuningID]==0);
        end
        % Get intersection
        [int_a,int_b] = Find_Intersected_Neurons(data_a.Neurons(id_a),...
                    data_b.Neurons(id_b),w,h,cell_radius);
        int_a = id_a(int_a);
        int_b = id_b(int_b);
end

% Create table
switch data_type
    case 'raster'
        table_a = Create_Data_Table(data_a.Transients.Raster(int_a,:),data_a.VoltageRecording.Stimuli,observation_type);
        table_b = Create_Data_Table(data_b.Transients.Raster(int_b,:),data_b.VoltageRecording.Stimuli,observation_type);
    case 'inference'
        table_a = Create_Data_Table(data_a.Transients.Inference(int_a,:),data_a.VoltageRecording.Stimuli,observation_type);
        table_b = Create_Data_Table(data_b.Transients.Inference(int_b,:),data_b.VoltageRecording.Stimuli,observation_type);
    case 'inference_th'
        table_a = Create_Data_Table(data_a.Transients.InferenceTh(int_a,:),data_a.VoltageRecording.Stimuli,observation_type);
        table_b = Create_Data_Table(data_b.Transients.InferenceTh(int_b,:),data_b.VoltageRecording.Stimuli,observation_type);
end