function Plot_Voltage_Recording(data)
% Plot the voltage recording from data variable (stimuli, locomotion and laser)
%
%       Plot_Voltage_Recording(data)
%
% By Jesus Perez-Ortega, Feb 2020

% Read data
fps = data.Movie.FPS;
frames = data.Movie.Frames;
name = data.Movie.DataName;

% Plot
Set_Figure(['Locomotion & stimuli - ' name],[0 0 1220 300]);
subplot(2,1,1)
area(data.VoltageRecording.Stimuli)
ylabel('visual stimulation')
Set_Label_Time(frames,fps)
subplot(2,1,2)
area(data.VoltageRecording.Locomotion)
ylabel('locomotion [cm/s]')
Set_Label_Time(frames,fps)