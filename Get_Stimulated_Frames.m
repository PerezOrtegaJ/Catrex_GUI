function laser = Get_Stimulated_Frames(laserSignal,frames,msPeriodFrames,msPeriodVoltage)
% Get the active frames from laser stimulation
%
%       laser = Get_Stimulated_Frames(laserSignal,frames,msPeriodFrames,msPeriodVoltage)
%
%
% By Jesus Perez-Ortega, Oct 2019

% Find the times from signal
activeLaser = find(round(laserSignal*100)/100)*msPeriodVoltage;

% Find frame times
frameTimes = msPeriodFrames:msPeriodFrames:(frames*msPeriodFrames);

% Identify each 
idFrames = [];
for i = 1:length(activeLaser)
    idFrames = union(idFrames,find(frameTimes>activeLaser(i),1,'first'));
end
laser = zeros(frames,1);
laser(idFrames) = 1;
