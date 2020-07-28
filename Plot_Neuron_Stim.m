function Plot_Neuron_Stim(activity,stim,fps,pre,post,name)
% Plot the activity related with the stimulus
%
%       Plot_Neuron_Stim(activity,stim,fps,pre,post)
%
% By Jesus Perez-Ortega, Sep 2019
% Modified Oct 2019

if nargin==5
    name = inputname(1);
end

% Get number of stimulus
n = max(stim);
columns = min([4 n]);
rows = ceil(n/columns);
samples = length(activity);

Set_Figure(name)
maxValue = 0;
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
    maxValue = max([maxValue max(data(:))]);
    
    subplot(rows,columns,i)
    %Plot_Raster(data,'',true,false,false)
    %Plot_Transients(data,num2str(i),'raster',12.5,false)
    Plot_Transients(data,num2str(i),'basic color',fps,false,pre)
    avg = mean(data);
    plot(avg,'k','linewidth',2)
    plot(avg+std(data)/sqrt(nStims),'--k')
    plot(avg-std(data)/sqrt(nStims),'--k')
    title(name)
    legend([string(num2str((1:nStims)'));'AVG';'SEM'])
    %allMean(:,i) = mean(data);
end

for i = 1:n
    subplot(rows,columns,i)
    %set(gca,'CLim',[0 maxValue])
    set(gca,'ylim',[0 maxValue])
end

% Set_Figure([inputname(1) ' - All'],[0 0 400 400])
% plot(allMean)

