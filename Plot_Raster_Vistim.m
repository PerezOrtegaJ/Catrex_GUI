function [id_all,cell_tune_id,oi,weights,dist_loco,dist_inter] = Plot_Raster_Vistim(activity,raster,stim,locomotion,fps,name)
% Get neuronal tuning and plot the raster sorted
%
%       [id_all,cell_tune_id,oi,weights,dist_loco,dist_inter] = Plot_Raster_Vistim(activity,raster,stim,locomotion,fps,name)
%
% By Jesus Perez-Ortega, 2019
% Modified Sep 2019

if nargin == 3
    name = '';
end

save = false;

% Get significant tuning neurons
%degrees = [180 135 90 45 0 315 270 225];
degrees = [0 45 90 135 180 225 270 315];
warning off
[oi,~,orientation,weights] = Get_Orientation_Index(activity,stim,degrees);
warning on

% Get significant orientation neurons id
cell_tune_id = zeros(1,length(orientation));
id_significant = [];
for i = [1 5 2 6 3 7 4 8]
    % neurons selective to orientation
    orientation_i = find(orientation==i);
    
    % sort neurons by orientation index
    [~,id_i] = sort(oi(orientation_i),'descend');
    id_significant = [id_significant orientation_i(id_i)];
    cell_tune_id(orientation_i(id_i)) = i;
end

% Get non significant neurons id
[~,non] = find(isnan(orientation));

% correlated with inter-stimulus
inter_stim = Find_Peaks_Or_Valleys(stim,0.1,true,false,0,0,true)>0;
[~,id_inter,distance] = Sort_Raster_By_Distance(activity(non,:),inter_stim,'correlation');
th_corr = 0.2;
n_inter = sum((1-distance)>th_corr);
id_inter = non(id_inter(1:n_inter));
cell_tune_id(id_inter) = -1;

% correlated with locomotion
non = setdiff(non,id_inter);
[~,id_non,distance] = Sort_Raster_By_Distance(activity(non,:),locomotion,'correlation');
th_corr_loco = 0.1;
num_loco = find((1-distance)>=th_corr_loco,1,'last');
id_non = non(id_non);
cell_tune_id(id_non(1:num_loco)) = -2;

% Join significant and non significant
id_all = [id_significant id_inter id_non];
raster = raster(id_all,:);
orientation_sorted = orientation(id_all)';

% Correlation with locomotion and inter-stim
[~,~,~,dist_loco] = Sort_Raster_By_Distance(raster,locomotion,'correlation');
[~,~,~,dist_inter] = Sort_Raster_By_Distance(raster,inter_stim,'correlation');

%% Plots with all neurons
colors_HSV = [0.0 0.5 0.9;... 
              0.2 0.5 0.9;... 
              0.4 0.5 0.9;... 
              0.6 0.5 0.9;...
              0.0 0.2 0.9;...
              0.2 0.2 0.9;... 
              0.4 0.2 0.9;... 
              0.6 0.2 0.9;...
              0.8 0.5 0.9;...
              0.9 0.2 0.9];
orientation_colors = hsv2rgb(colors_HSV);

% raster colors 
% 0, white (no active)
% 1, black (active)
% 2-9, orientation colors
% 10, inter-stimulus correlated
% 11, motion correlated
raster_color = zeros(size(raster));
for i = [1 5 2 6 3 7 4 8]
    raster_color(orientation_sorted==i,:) = i+1;
end
raster_color((1:length(id_inter))+length(id_significant),:) = 10;
raster_color((1:num_loco)+length(id_significant)+length(id_inter),:) = 11;
raster_color(raster>0) = 1;

% Reset the colors
if isempty(id_inter)
    orientation_colors(end-1,:) = [];
end
if isempty(num_loco)
    orientation_colors(end,:) = [];
end
if isempty(id_non)
    final_colors = [0 0 0; orientation_colors];
else
    final_colors = [1 1 1; 0 0 0; orientation_colors];
end

% Set figure
[num_cells,num_frames] = size(raster_color);
Set_Figure(name,[0 0 1200 700]);

% Plot raster
Set_Axes('raster',[0 0.3 0.8 0.7])
axis([0.5 num_frames 0.5 num_cells+0.5]); hold on
imagesc(raster_color);
colormap(gca,final_colors)
box on
set(gca,'XTicklabel','','XTick',[])
title(strrep(name,'_','-'))
ylabel('neuron #')

% Plot coactivity
Set_Axes('',[0 0.25 0.8 0.1])
plot(sum(raster),'k')
set(gca,'xtick',[])
xlim([0 num_frames])
ylabel('coactivity')

% Plot stimulus
axes_stim = Set_Axes('',[0 0.15 0.8 0.1]); hold on
for i = [1 5 2 6 3 7 4 8]
    id_stim = (stim==i)*i;
    area(id_stim,'FaceColor',orientation_colors(i,:))
end
area(0,'FaceColor',orientation_colors(end-1,:))
area(0,'FaceColor',orientation_colors(end,:))
set(gca,'xtick',[],'ytick',[])
ylabel('stimulus')
xlim([0 num_frames])
% this is the only way that I found to print the arrows
string_legend = sprintf(['legend(''\x2192'',''\x2190'',''\x2197'',''\x2199''' ...
    ',''\x2191'',''\x2193'',''\x2196'',''\x2198'',''inter-stimulus'',''locomotion'')']);
eval(string_legend)
pos = axes_stim.Legend.Position;
pos(1) = 0.82;
axes_stim.Legend.Position = pos;

% Plot locomotion
Set_Axes('',[0 0 0.8 0.15])
plot(locomotion,'k')
set(gca,'xtick',[])
ylabel({'locomotion';'cm/s'})
xlim([0 num_frames])
Set_Label_Time(num_frames,fps)

% Plot orientation index
Set_Axes('',[0.74 0.3 0.07 0.7])
Plot_Neurons_Measure(oi(id_all),{'orientation';'index'})
set(gca,'xtick',[])

% Plot correlation inter
Set_Axes('',[0.82 0.3 0.07 0.7])
Plot_Neurons_Measure(1-dist_inter,{'correlation'; '(inter-stimulus)'})
set(gca,'xtick',[])

% Plot correlation with motion
Set_Axes('',[0.9 0.3 0.07 0.7])
Plot_Neurons_Measure(1-dist_loco,{'correlation'; '(locomotion)'})
set(gca,'xtick',[])

if save
    Save_Figure(['raster - ' name]) 
end

% % Plot raster for each kind of stimulus
% after_samples = 4; before_samples = 4;
% for i = 1:max(stim)
%     title_name = ['stimulus ' num2str(i) ' - ' name];
%     % Get indices from each stimulus
%     id = Get_Indices_Before_And_After_Stimulus(stim==i,before_samples,after_samples);
%     % Plot raster
%     Plot_Raster_Motion_Stimulus(r_all(:,id),title_name,locomotion(id),stim(id),fps)
%     Save_Figure(title_name)
% end
% 
% % Get indices from each motion window time
% before_samples = 1; after_samples = 1;
% indices = Get_Indices_Before_And_After_Stimulus(locomotion>0,before_samples,after_samples);
% Plot_Raster_Motion_Stimulus(r_all(:,indices),'locomotion',locomotion(indices),...
%     stim(indices),fps)
% Save_Figure(['locomotion - ' name])