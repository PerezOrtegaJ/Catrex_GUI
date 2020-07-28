function [id,tune_id] = Quick_Plot_Raster_Gratings(raster,stimuli,locomotion,frame_period_ms)
%
%       Quick_Plot_Vis_Stim(raster,stimuli,locomotion,frame_period)

samples = size(raster,2);
name = inputname(1);

stim = downsample(round(stimuli*2),frame_period_ms);
stim = stim(1:samples);

% Get locomotion in cm/s
min_locomotion = min([locomotion; 0.5]);
max_locomotion = max([locomotion; 4.5]);
range = max_locomotion-min_locomotion;
diameter = 6;           % cm (diameter of the wheel)
sample_rate = 1000;     % Hz
angles = unwrap((locomotion-min_locomotion)/range*2*pi);
velocity = diff(angles)*diameter/pi*sample_rate; % cm/s
velocity = smooth(velocity,100);
loco = downsample(velocity,frame_period_ms);
loco = abs(loco(1:samples));

[id,tune_id] = Plot_Raster_Vistim(raster,stim,loco,1000/frame_period_ms,name);