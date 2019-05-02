function Plot_Single_Transient(transient,filtered,f0,number,name,fps,cursor)
% Plot Ca transients
%
% Jesus Perez-Ortega March-19

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

n = length(transient);

% Get derivative
derivative = smooth(diff(filtered))';
th = 1*std(derivative);

% Get binary
id = find(derivative>th);
active = ones(1,length(id));

% Set figure
Set_Figure(['Cell transient - ' name],[0 0 1300 500]);

% Plot basal
subplot(5,1,1)
plot(f0,'color',[0 0.4 0]); hold on
title(['Cell #' num2str(number)])
if cursor
    plot([cursor cursor],minmax(f0),'r')
end
xlim([1 n])
set(gca,'xtick',[])
ylabel('F_0')

% Plot raw
subplot(5,1,2)
plot(transient,'color',[0 0.4 0]); hold on
if cursor
    plot([cursor cursor],minmax(transient),'r')
end
xlim([1 n])
set(gca,'xtick',[])
ylabel('F')

% Plot filtered
subplot(5,1,3)
plot(filtered,'color',[0 0.4 0]); hold on
plot(id,filtered(id),'.','color','k','markersize',5)
if cursor
    plot([cursor cursor],minmax(filtered),'r')
end
xlim([1 n])
set(gca,'xtick',[])
ylabel('\DeltaF/F_0')

% Plot derivative
subplot(5,1,4)
plot(derivative,'color',[0 0.4 0]); hold on
plot([1 n],[th th],'r--')
if cursor
    plot([cursor cursor],minmax(derivative),'r')
end
xlim([1 n])
ylabel('d(\DeltaF/F_0)/dt')

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