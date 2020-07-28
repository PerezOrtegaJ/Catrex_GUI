function voltageRecording = Read_Voltage_Recording(file,period,samples,select)
% Read voltage recording from prairie. It works for names of recordings of
% stimuli, laser and locomotion
%
%       voltageRecording = Read_Voltage_Recording(file,period,samples)
%
%       period = period of each frame
%       samples = samples of the imaging
%
% By Jesus Perez-Ortega, Nov 2019

if nargin==3
    select = 'regular';
end

switch select
    case 'all'
        stim = true;
        loco = true;
        las = true;
    case 'regular'
        stim = true;
        loco = true;
        las = false;
    case 'laser'
        stim = false;
        loco = false;
        las = true;
end    

% Disable warning because the header of the time is "Time (ms)"
warning off
dataTable = readtable(file);
warning on

% Get sample rate
msPeriod = diff(dataTable.Time_ms_(1:2));
sampleRate = 1000/msPeriod;
disp(['   Voltage recording at ' num2str(sampleRate) ' Hz'])

% Visual stimuli
if ismember('stimuli', dataTable.Properties.VariableNames) && stim
    stimuli = dataTable.stimuli;
    stimuli = downsample(round(stimuli*2),round(period*sampleRate));
    stimuli = stimuli(1:samples);
    voltageRecording.Stimuli = stimuli;
    disp('   Visual stimulation loaded')
end

% Locomotion
if ismember('locomotion', dataTable.Properties.VariableNames) && loco
    % Get locomotion in cm/s
    locomotion = dataTable.locomotion;
    diameter = 6;           % cm (diameter of the wheel)
    min_locomotion = min([locomotion; 0.5]);
    max_locomotion = max([locomotion; 4.5]);
    range = max_locomotion-min_locomotion;
    angles = unwrap((locomotion-min_locomotion)/range*2*pi);
    velocity = diff(angles)*diameter/pi*sampleRate;
    velocity = smooth(velocity,100);
    locomotion = downsample(velocity,round(period*sampleRate));
    locomotion = abs(locomotion(1:samples));
    voltageRecording.Locomotion = locomotion;
    disp('   Locomotion loaded')
end

% Laser stimulation
if ismember('laser', dataTable.Properties.VariableNames) && las
    laser = Get_Stimulated_Frames(dataTable.laser,samples,period*sampleRate,msPeriod);
    voltageRecording.Laser = laser;
    disp('   Laser stimulation loaded')
end

% Add file data
voltageRecording.File = file;
voltageRecording.SampleRate = sampleRate;
