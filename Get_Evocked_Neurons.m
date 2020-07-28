function [tuned,oi,weights,p] = Get_Evocked_Neurons(activity,stimuli)
% Identify the neurons that are more active during the stimulation versus
% without stimulation
%
%       [tuned,oi,weights,p] = Get_Evocked_Neurons(activity,stimuli)
%
% By Jesus Perez-Ortega, Nov 2019

% Get number of cells
nCells = size(activity,1);

% Get indices from each stimulus
stimID = Find_Peaks_Or_Valleys(stimuli,0.1,true,true);
noStimID = Find_Peaks_Or_Valleys(stimuli,0.5,true,false,0,0,true);

% Get the average of evoked spikes
spikesStim = Get_Peak_Vectors(activity,stimID,'average')';
avgStim = mean(spikesStim');

% Get the average of spontaneous spikes
spikesNoStim = Get_Peak_Vectors(activity,noStimID,'average')';
avgNoStim = mean(spikesNoStim');

% Get weigths
weights = [avgStim; avgNoStim]';

% Compute selectivity
for i = 1:nCells
    cell_spikes = sum(spikesStim(i,:))+sum(spikesNoStim(i,:));
    if cell_spikes
        [tuned(i),p(i)] = ttest2(spikesStim(i,:),spikesNoStim(i,:));
        oi(i) = sum(spikesStim(i,:))/cell_spikes;
    else
        p(i) = 1;
        tuned(i) = false;
        oi(i) = 0;
    end
end

% Get only significant cell to the stimulation
tuned(diff(weights')>0) = 0;
tuned = logical(tuned);
