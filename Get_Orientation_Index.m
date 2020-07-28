function [oi,p,orientation,weights,semStim,allPoints] = Get_Orientation_Index(raster,stimuli,degrees)
% Get the the orientation index of a neuron. The values ranges between 0-1
%
%       [oi,p,orientation,meanStim,semStim,allPoints] = Get_Orientation_Index(raster,stimuli,degrees)
%
% circular variance (Ringach et al., 2002)
% selectivity = 1 - circular variance
%
% Jesus Perez-Ortega May 2019
% Modified Sep 2019
% Modified Nov 2019


% Get the number of cells
nCells = size(raster,1);

angles = []; spikes = [];

% All except 0
stims = setdiff(unique(stimuli),0);
nStims = length(stims);

% Trick for single stimulus (this should be modified)
if nStims==1
    %th = 1.5; % threshold to say if a neuron is evoked
    [tuned,oi,weights,p] = Get_Evocked_Neurons(raster,stimuli);
    orientation = nan(1,nCells);
    orientation(tuned) = stims;
    semStim = [];
    allPoints = [];
else
    % Get the count of spikes at each trial from each stimulus
    for i = 1:nStims
        % Get indices from each stimulus
        during = stimuli==stims(i);
        indices = Find_Peaks_Or_Valleys(during,0.5,true,true);

        % Get the sum of spikes at each trial
        spikes_i = Get_Peak_Vectors(raster,indices,'average')';
        count = size(spikes_i,2);

        % Concatenate vectors
        spikes = [spikes spikes_i];

        % Get the angle
        angles = [angles; repmat(degrees(i),count,1)];

        if count==1
            weights(:,i) = spikes_i;
            semStim(:,i) = nan(size(spikes_i));
        else
            % Get mean spikes per stimulus and sem
            weights(:,i) = mean(spikes_i');
            semStim(:,i) = std(spikes_i')/sqrt(count);
        end
    end

    % Compute selectivity of each cell
    % Get the exponential values
    exps = exp(angles.*2*pi/180*1i);

    % Compute selectivity
    for i = 1:nCells
        cell_spikes = sum(spikes(i,:));
        points = transpose(spikes(i,:)'.*exps);
        if cell_spikes
            [p(i), h1(i)] = Hotelling_T2_Test([real(points);imag(points)]',0.05);
            oi(i) = abs(sum(points))/cell_spikes;
        else
            p(i) = 1;
            h1(i) = false;
            oi(i) = 0;
        end
        allPoints(i,:) = points; 
    end

    % Identify the significant orientation
    orientation = nan(1,nCells);
    [~,selective_stim] = max(weights');
    orientation(h1) = selective_stim(h1);
end


% Trick for single stimulus (OLD)
% if nStims==1
%     stims(2) = mod(stims+1,8);
%     % Create a dummy stimulation wth the same pattern
%     dummy = (circshift(stimulus,randi(length(stimulus)/2))>0)*stims(2);
%     
%     % Find time without stimulation
%     noStimID = find(stimulus==0);
%     noStimSize = length(noStimID);
%         
%     while ~isempty(dummy) && noStimSize
%         if length(dummy)<noStimSize
%             fin = length(dummy);
%         else
%             fin = noStimSize;
%         end
%         
%         % Assign dummy data
%         stimulus(noStimID(1:fin)) = dummy(1:fin);
%         dummy(1:fin) = [];
% 
%         % Find time without stimulation
%         noStimID = find(stimulus==0);
%         noStimSize = length(noStimID);
%     end
%     
%     % All except 0
%     stims = setdiff(unique(stimulus),0);
%     nStims = length(stims);
% end