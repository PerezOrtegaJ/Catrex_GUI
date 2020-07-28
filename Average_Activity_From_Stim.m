function avg = Average_Activity_From_Stim(activity,stim,pre,post)
% Get the average of activity related to the stimulus
%
%       avg = Average_Activity_From_Stim(activity,stim,pre,post)
%
% By Jesus Perez-Ortega, Feb 2020

% Get number of stimulus
n = max(stim);
samples = length(activity);
for i = 1:n
    during = stim==i;
    indices = Find_Peaks_Or_Valleys(during,0.5,true,true);
    
    nStims = max(indices);
    data = [];
    minFrames = samples;
    for j = 1:nStims
        id = find(indices==j);

        % Add extra frames before and after stimulus
        ini = id(1)-pre;
        fin = id(end)+post;
        
        % Check if there are samples before and after stimulus
        if ini<1
            error('The number of samples pre stimulus are not reachable.')
        end
        if fin>samples
            error('The number of samples post stimulus are not reachable.')
        end
        
        % Get total number of frames
        nFrames = numel(ini:fin);
        data(j,1:nFrames) = activity(ini:fin)-min(activity(ini:fin));
        
        % Get minimum number of frames
        minFrames = min([minFrames nFrames]);
    end
    data = data(:,1:minFrames);
    avg(i,:) = mean(data);
end
