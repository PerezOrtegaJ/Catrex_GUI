function XY = Create_Prairie_Stim_Files(xy,nStims,randomStim,path,fileName)
% Create files for prairie to stimulate neurons from specific coordinates
%
%       Create_Prairie_Stim_Files(xy,nStims,randomStim,path,fileName)
%
%       By default: 30 spiral revolutions in 20 ms are for size 8 um
%
% By Jesus Perez-Ortega, Sep 2019

% Parameters od stimulation
period = 1;       % seconds
spiral = 20;      % ms
interDelay = 20;  % ms (min = 0.12 ms)
revs = 30;        % spiral revolutions


%% Marker points file
% Transform coordinates to prairie coordinates
factorX = 7.6;
factorY = 8.3;

% x = xy(:,1)-1;
% X = x*slope+factorX;
% y = 256-xy(:,2);
% Y = y*slope+factorX;

x = xy(:,1);
X = factorX*(2*x/256-1);
y = 256-xy(:,2);
Y = factorY*(2*y/256-1);

XY = [X Y];

% Open file
fileID = fopen(fullfile(path,[fileName '.gpl']),'w');
fprintf(fileID,'<?xml version="1.0" encoding="utf-8"?>\r\n<PVGalvoPointList>\r\n');

% Neuron coordinates
nXY = size(xy,1);
for i = 1:nXY
    fprintf(fileID,['  <PVGalvoPoint X="' num2str(X(i)) '" Y="' num2str(Y(i))...
        '" Name="Neuron ' num2str(i) '" Index="' num2str(i-1)...
        '" ActivityType="MarkPoints" UncagingLaser="Uncaging" UncagingLaserPower="5"'...
        ' Duration="' num2str(spiral) '" IsSpiral="True" SpiralSize="0.39246777833505"'...
        ' SpiralRevolutions="' num2str(revs) '" Z="0" />\r\n']);
end


if randomStim
    % Groups for random stimulation
    for i = 1:nStims
        indices = num2str(0:nXY-1,'%u,');
        indices_stim = num2str(randperm(nXY),'%u,');
        fprintf(fileID,['  <PVGalvoPointGroup Indices="' indices(1:end-1)...
            '" Name="Random group ' num2str(i) '" Index="' num2str(nXY+i-1)...
            '" ActivityType="MarkPoints" Order="Custom" CustomOrder="' indices_stim(1:end-1)...
            '" UncagingLaser="Uncaging" UncagingLaserPower="5" Duration="' num2str(spiral)...
            '" IsSpiral="True" SpiralSize="0.39246777833505" SpiralRevolutions="' num2str(revs) '" Z="0" />\r\n']);
        indicesFinalSequence{i} = indices_stim(1:end-1);
    end
else
    % Single group for same order of stimulation
    indices = num2str(0:nXY-1,'%u,');
    indices_stim = num2str(1:nXY,'%u,');
    fprintf(fileID,['  <PVGalvoPointGroup Indices="' indices(1:end-1)...
        '" Name="Single group" Index="' num2str(nXY+1)...
        '" ActivityType="MarkPoints" Order="Custom" CustomOrder="' indices_stim(1:end-1)...
        '" UncagingLaser="Uncaging" UncagingLaserPower="5" Duration="' num2str(spiral)...
        '" IsSpiral="True" SpiralSize="0.39246777833505" SpiralRevolutions="' num2str(revs) '" Z="0" />\r\n']);
    indicesFinalSequence = indices(1:end-1);
end
fprintf(fileID,'</PVGalvoPointList>');

% Close file
fclose(fileID);


%% Series file

% Compute period of stimulation
% maximum neurons: 49, with period of 1 s (1 Hz) and spiral stim of 20 ms (inter_delay = 0.12 ms)
% maximum neurons: 24, with period of 0.5 s (2 Hz) and spiral stim of 20 ms (inter_delay = 0.12 ms)
% maximum neurons: 16, with period of 0.33 s (3 Hz) and spiral stim of 20 ms (inter_delay = 0.12 ms)
% maximum neurons: 25, with period of 1 s (1 Hz) and spiral stim of 20 ms (inter_delay = 20 ms)
allGroup = nXY*(spiral+interDelay)/1000;
msDelay = 1000*(period-allGroup);

if msDelay<0.12
%     error(['Delay: ' num2str(msDelay) 'ms . Is not possible to achieve this stimulation. '...
%         'Reduce the frequency of the stimulation '...
%         'and/or reduce the number of neurons to stimulate.'])
    
     while msDelay<0.12
         nXY = nXY-1;
         allGroup = nXY*(spiral+interDelay)/1000;
         msDelay = 1000*(period-allGroup);
     end
     XY = XY(1:nXY,:);
     warning(['Is not possible to achieve the stimulation frequency for all neurons. '...
         'This will automatically use the first ' num2str(nXY) ' neurons.'])
end

% Open file
fileID = fopen(fullfile(path,[fileName '.xml']),'w');
fprintf(fileID,'<?xml version="1.0" encoding="utf-8"?>\r\n');
fprintf(fileID,'<PVSavedMarkPointSeriesElements Iterations="1" IterationDelay="0.00">\r\n');

% Neuron groups series
if randomStim
    for i = 1:nStims
        fprintf(fileID,['  <PVMarkPointElement Repetitions="1" UncagingLaser="Uncaging" '...
            'UncagingLaserPower="5" TriggerFrequency="None" TriggerSelection="PFI0" TriggerCount="50" '...
            'AsyncSyncFrequency="None" VoltageOutputCategoryName="None" VoltageRecCategoryName="None" '...
            'parameterSet="CurrentSettings">\r\n']);
        fprintf(fileID,['    <PVGalvoPointElement InitialDelay="' num2str(msDelay) '" InterPointDelay="'... 
            num2str(interDelay) '" Duration="' num2str(spiral) '" SpiralRevolutions="' num2str(revs)...
            '" AllPointsAtOnce="False" Points="Random group '...
            num2str(i) '" Indices="' num2str(indicesFinalSequence{i}) '" />\r\n']);
        fprintf(fileID,'  </PVMarkPointElement>\r\n');
    end
else
    fprintf(fileID,['  <PVMarkPointElement Repetitions="' num2str(nStims) '" UncagingLaser="Uncaging" '...
        'UncagingLaserPower="5" TriggerFrequency="None" TriggerSelection="PFI0" TriggerCount="50" '...
        'AsyncSyncFrequency="None" VoltageOutputCategoryName="None" VoltageRecCategoryName="None" '...
        'parameterSet="CurrentSettings">\r\n']);
    fprintf(fileID,['    <PVGalvoPointElement InitialDelay="' num2str(msDelay) '" InterPointDelay="'...
        num2str(interDelay) '" Duration="' num2str(spiral) '" SpiralRevolutions="' num2str(revs)...
        '" AllPointsAtOnce="False" Points="Single group" '...
        'Indices="' num2str(nXY+1) '" />\r\n']);
    fprintf(fileID,'  </PVMarkPointElement>\r\n');
end
fprintf(fileID,'</PVSavedMarkPointSeriesElements>');

% Close file
fclose(fileID);