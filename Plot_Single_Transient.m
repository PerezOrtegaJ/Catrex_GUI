function Plot_Single_Transient(raw,filtered,f0,inference,model,raster,number,name,fps,cursor,stimuli,locomotion)
% Plot single Ca transients
%
%       Plot_Single_Transient(raw,filtered,f0,inference,model,raster,number,name,fps,cursor,stimuli,locomotion)
%
% By Jesus Perez-Ortega, Nov 2019
% Modified Dec 2019

switch nargin
    case 6
        cursor = 0;
        fps = 1;
        name = [];
        number = [];
        stimuli = [];
        locomotion = [];
    case 7
        cursor = 0;
        fps = 1;
        name = [];
        stimuli = [];
        locomotion = [];
    case 8
        cursor = 0;
        fps = 1;
        stimuli = [];
        locomotion = [];
    case 9
        cursor = 0;
        stimuli = [];
        locomotion = [];
    case 10
        stimuli = [];
        locomotion = [];
    case 11
        locomotion = [];
end

if isempty(locomotion)
    nPlots = 4;
else
    nPlots = 5;
end

n = length(raw);
maxY = max([raw f0]);

id = find(raster);
active = ones(1,length(id));

% Get PSNR
PSNR = max((raw-f0))/std(f0);

% Set figure
Set_Figure(['Cell transient - ' name],[0 0 1000 600]);

% Plot basal and raw
subplot(nPlots,1,1)
area((stimuli>0)*max(raw),'facecolor',[0.8 0.8 0.8],'LineStyle','none'); hold on
plot(raw,'color',[0 0.5 0])
plot(f0,'color',[0.5 0.8 0.5])
if cursor
    plot([cursor cursor],minmax(raw),'r')
end
xlim([1 n])
ylim([0 maxY])
set(gca,'xtick',[])
ylabel('F_0 & F_{raw}')
title(['Cell #' num2str(number)  ' (PSNR= ' num2str(PSNR) ')'])

% Plot filtered
subplot(nPlots,1,2)
area((stimuli>0)*max([filtered model]),'facecolor',[0.8 0.8 0.8],'LineStyle','none'); hold on
plot(filtered,'color',[0 0.5 0])
plot(model,'color',[1 0.5 0])
plot(id,model(id),'.','color','k','markersize',5)
if cursor
    plot([cursor cursor],minmax(filtered),'r')
end
xlim([1 n])
set(gca,'xtick',[])
ylabel('\DeltaF/F_0')

% Plot inference
if ~isempty(inference)
    subplot(nPlots,1,3)
    area((stimuli>0)*max(inference),'facecolor',[0.8 0.8 0.8],'LineStyle','none'); hold on
    plot(inference,'k')
    if cursor
        plot([cursor cursor],minmax(inference),'r')
    end
    xlim([1 n])
    set(gca,'xtick',[])
    ylabel('spike inference')
end

% Plot binary signal
if ~isempty(id)
    subplot(nPlots,1,4)
    area((stimuli>0)*2,'facecolor',[0.8 0.8 0.8],'LineStyle','none'); hold on
    plot(id,active,'.','color','k','markersize',5)
    if cursor
        plot([cursor cursor],[0 2],'r')
    end
    set(gca,'ytick',1,'yticklabel',{'active'})
    ylim([0 2])
    xlim([1 n])
end

if ~isempty(locomotion)
    set(gca,'xtick',[])
    
    % Plot locomotion signal
    subplot(nPlots,1,5)
    plot(locomotion,'color',[0 0 0.5]);hold on
    if cursor
        plot([cursor cursor],[0 2],'r')
    end
    xlim([1 n])
    ylabel('locomotion (cm/s)')
end
Set_Label_Time(n,fps)