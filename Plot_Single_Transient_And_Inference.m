function Plot_Single_Transient_And_Inference(raw,filtered,f0,number,name,fps,cursor)
% Plot single Ca transients and get the spike inference
%
%       Plot_Single_Transient_And_Inference(raw,filtered,f0,number,name,fps,cursor)
%
% Jesus Perez-Ortega March-19
% Modified Oct 2019

switch(nargin)
    case 3
        cursor = 0;
        number = [];
        fps = 1;
    case 4
        cursor = 0;
        fps = 1;
    case 5
        cursor = 0;
end

n = length(raw);
maxY = max([raw f0]);

% smooth signal
%filtered = smooth(filtered,13)';

% Get inference and binary data
[inference,mdl] = Get_Spike_Inference(filtered);
%inference = inference*std(filtered);
th = mean(inference)+2*std(inference);
disp(['avg: ' num2str(mean(inference))])

%th = .2;
id = find(inference>th);
active = ones(1,length(id));

% Get PSNR
PSNR = max((raw-f0))/std(f0);

% Set figure
Set_Figure(['Cell transient - ' name],[0 0 1300 500]);

% Plot basal
subplot(5,1,1)
plot(f0,'color',[0 0.4 0]); hold on
title(['Cell #' num2str(number)  ' (PSNR= ' num2str(PSNR) ')'])
if cursor
    plot([cursor cursor],minmax(f0),'r')
end
xlim([1 n])
ylim([0 maxY])
set(gca,'xtick',[])
ylabel('F_0')

% Plot raw
subplot(5,1,2)
plot(raw,'color',[0 0.4 0]); hold on
if cursor
    plot([cursor cursor],minmax(raw),'r')
end
xlim([1 n])
ylim([0 maxY])
set(gca,'xtick',[])
ylabel('F')

% Plot filtered
subplot(5,1,3)
plot(filtered,'color',[0 0.4 0]); hold on
plot(mdl,'color',[0.4 0 0])
plot(id,mdl(id),'.','color','k','markersize',5)
if cursor
    plot([cursor cursor],minmax(filtered),'r')
end
xlim([1 n])
set(gca,'xtick',[])
ylabel('\DeltaF/F_0')

% Plot inference
subplot(5,1,4)
plot(inference,'color',[0 0.4 0]); hold on
%plot([1 n],[th th],'r--')
if cursor
    plot([cursor cursor],minmax(inference),'r')
end
xlim([1 n])
ylabel('spike inference')

% Plot binary signal
subplot(5,1,5)
plot(id,active,'.','color','k','markersize',5); hold on
if cursor
    plot([cursor cursor],[0 2],'r')
end
set(gca,'ytick',1,'yticklabel',{'active'})
ylim([0 2])
xlim([1 n])
Set_Label_Time(n,fps)