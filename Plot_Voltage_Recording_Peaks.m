function Plot_Voltage_Recording_Peaks(data,indices,sequence)
% Plot the voltage recording from data variable (stimuli, locomotion and laser)
%
%       Plot_Voltage_Recording_Peaks(data,indices,sequence)
%
% By Jesus Perez-Ortega, Feb 2020
% Modified May 2020

% Read data
fps = data.Movie.FPS;
name = data.Movie.DataName;

% Get time of peaks
id = find(indices>0);
[~,id2] = sort(sequence);
vstim = data.VoltageRecording.Stimuli;
loco = data.VoltageRecording.Locomotion;

% Plot
Set_Figure(['Locomotion & stimuli (peaks)- ' name],[0 0 1220 300]);
subplot(2,1,1)
area(vstim(id(id2)))
ylabel('visual stimulation')
xlim([0 length(id)])
xticks([])
subplot(2,1,2)
area(loco(id(id2)))
ylabel('locomotion [cm/s]')
Set_Label_Time(length(id),fps)