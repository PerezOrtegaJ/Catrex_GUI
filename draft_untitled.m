% Analize data from the first time of visual stimulation

% S3 V4 S5

S3 = GC06_M1963_20191112_S03;
V4 = GC06_M1963_20191112_V04;
S5 = GC06_M1963_20191112_S05;

% Intersection
int34 = Intersect_Data(S3,V4);
rint34 = int34.Transients.Raster;
Plot_Voltage_Recording(int34)
Plot_Voltage_Recording_Peaks(int34,rint34_analysis)

% Union
data345 = Union_Data(S3,V4);
data345 = Union_Data(data345,S5);
union345 = data345.Transients.Raster;
Plot_Voltage_Recording(data345)
Plot_Voltage_Recording_Peaks(data345,union345_analysis)




% Intersection
data345 = Intersect_Data(S3,V4);
data345 = Intersect_Data(data345,S5);
intersection345 = data345.Transients.Raster;
Plot_Voltage_Recording(data345)
Plot_Voltage_Recording_Peaks(data345,intersection345_analysis)

% Union
data345 = Union_Data(S3,V4);
data345 = Union_Data(data345,S5);
union345 = data345.Transients.Raster;
Plot_Voltage_Recording(data345)
Plot_Voltage_Recording_Peaks(data345,union345_analysis)

% Mix
data345 = Union_Data(S3,V4);
data345 = Intersect_Data(data345,S5);
mix345 = data345.Transients.Raster;
Plot_Voltage_Recording(data345)
Plot_Voltage_Recording_Peaks(data345,mix345_analysis)




id = find(raster345_analysis.Peaks.Indices>0);
[~,id2] = sort(raster345_analysis.Clustering.SequenceSorted);
vstim = data345.VoltageRecording.Stimuli;
loco = data345.VoltageRecording.Locomotion;
Set_Figure('Stim peaks',[0 0 1220 300])
subplot(2,1,1)
area(vstim(id(id2)))
xticks([])
subplot(2,1,2)
area(loco(id(id2)))
Set_Label_Time(length(id),12.5)



id = find(raster_GC05_M1123_20190712_A_analysis.Peaks.Indices>0);
[~,id2] = sort(raster_GC05_M1123_20190712_A_analysis.Clustering.SequenceSorted);
vstim = data_GC05_M1123_20190712_A.VoltageRecording.Stimuli;
loco = data_GC05_M1123_20190712_A.VoltageRecording.Locomotion;
%vstim(vstim>4) = vstim(vstim>4)-4;
Set_Figure('Stim peaks',[0 0 1220 300])
subplot(2,1,1)
area(vstim(id(id2)))
xticks([])
subplot(2,1,2)
area(loco(id(id2)))
Set_Label_Time(length(id),12.5)


tuning = [data_GC05_M1123_20190712_A.Neurons.TuningID];
%tuning(tuning>4) = tuning(tuning>4)-4;
id = raster_GC05_M1123_20190712_A_analysis.Plot.IDstructure;
figure
plot(tuning(id),'.-k')
view([90 -90]);xlim([1 length(id)])
ylabel('tuning')

vstim = data_GC05_M1123_20190712_A.VoltageRecording.Stimuli;
activity = data_GC05_M1123_20190712_A.Transients.Filtered(99,:);
Plot_Neuron_Stim(activity,vstim,12.5,12,48)




