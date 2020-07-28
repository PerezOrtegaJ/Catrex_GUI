
S1 = GfO01_M1875_20200108_S1;
S2 = GfO01_M1875_20200108_S2;
S3 = GfO01_M1875_20200108_S3;
V4 = GfO01_M1875_20200108_V4;
V5 = GfO01_M1875_20200108_V5;
V6 = GfO01_M1875_20200108_V6;
S7 = GfO01_M1875_20200108_S7;
S8 = GfO01_M1875_20200108_S8;
S9 = GfO01_M1875_20200108_S9;

data14 = Intersect_Data(S1,V4,4);
data15 = Intersect_Data(S1,V5,4);
data16 = Intersect_Data(S1,V6,4);
data24 = Intersect_Data(S2,V4,4);
data25 = Intersect_Data(S2,V5,4);
data26 = Intersect_Data(S2,V6,4);
data34 = Intersect_Data(S3,V4,4);
data35 = Intersect_Data(S3,V5,4);
data36 = Intersect_Data(S3,V6,4);

data47 = Intersect_Data(S1,V4,4);
data48 = Intersect_Data(S1,V5,4);
data49 = Intersect_Data(S1,V6,4);
data57 = Intersect_Data(S2,V4,4);
data58 = Intersect_Data(S2,V5,4);
data59 = Intersect_Data(S2,V6,4);
data67 = Intersect_Data(S3,V4,4);
data68 = Intersect_Data(S3,V5,4);
data69 = Intersect_Data(S3,V6,4);

raster14 = data14.Transients.Raster;
raster15 = data15.Transients.Raster;
raster16 = data16.Transients.Raster;
raster24 = data24.Transients.Raster;
raster25 = data25.Transients.Raster;
raster26 = data26.Transients.Raster;
raster34 = data34.Transients.Raster;
raster35 = data35.Transients.Raster;
raster36 = data36.Transients.Raster;

raster47 = data47.Transients.Raster;
raster48 = data48.Transients.Raster;
raster49 = data49.Transients.Raster;
raster57 = data57.Transients.Raster;
raster58 = data58.Transients.Raster;
raster59 = data59.Transients.Raster;
raster67 = data67.Transients.Raster;
raster68 = data68.Transients.Raster;
raster69 = data69.Transients.Raster;

Plot_Voltage_Recording(data14)
Plot_Voltage_Recording(data15)
Plot_Voltage_Recording(data16)
Plot_Voltage_Recording(data24)
Plot_Voltage_Recording(data25)
Plot_Voltage_Recording(data26)
Plot_Voltage_Recording(data34)
Plot_Voltage_Recording(data35)
Plot_Voltage_Recording(data36)

Plot_Voltage_Recording(data47)
Plot_Voltage_Recording(data48)
Plot_Voltage_Recording(data49)
Plot_Voltage_Recording(data57)
Plot_Voltage_Recording(data58)
Plot_Voltage_Recording(data59)
Plot_Voltage_Recording(data67)
Plot_Voltage_Recording(data68)
Plot_Voltage_Recording(data69)


% Raster ALL
dataALL = Intersect_Data(S1,S2,4);
dataALL = Intersect_Data(dataALL,S3,4);
dataALL = Intersect_Data(dataALL,V4,4);
dataALL = Intersect_Data(dataALL,V5,4);
dataALL = Intersect_Data(dataALL,V6,4);
dataALL = Intersect_Data(dataALL,S7,4);
dataALL = Intersect_Data(dataALL,S8,4);
dataALL = Intersect_Data(dataALL,S9,4);
rasterALL = dataALL.Transients.Raster;

% 258
data258 = Intersect_Data(S2,V5,4);
data258 = Intersect_Data(data258,S8,4);
raster258 = data258.Transients.Raster;
Plot_Voltage_Recording(data258)
id = find(raster258_analysis.Peaks.Indices>0);
[~,id2] = sort(raster258_analysis.Clustering.SequenceSorted);
vstim = data258.VoltageRecording.Stimuli;
figure();area(vstim(id(id2)))
Set_Label_Time(5126,12.34)

% 367
data367 = Intersect_Data(S3,V6,4);
data367 = Intersect_Data(data367,S7,4);
raster367 = data367.Transients.Raster;
Plot_Voltage_Recording(data367)
id = find(raster367_analysis.Peaks.Indices>0);
[~,id2] = sort(raster367_analysis.Clustering.SequenceSorted);
vstim = data367.VoltageRecording.Stimuli;
figure();area(vstim(id(id2)))
Set_Label_Time(4420,12.34)



%{
vstim14 = data14.VoltageRecording.Stimuli;
vstim = data16.VoltageRecording.Stimuli;

hold on; area((vstim>0)*40,'facecolor',[0.8 0.8 0.8],'faceAlpha',0.5)

id = find(raster_GfO01_M1875_20200108_S1_V6_analysis.Peaks.Indices>0);
[~,id2] = sort(raster_GfO01_M1875_20200108_S1_V6_analysis.Clustering.SequenceSorted);

figure();area(vstim(id(id2)))
Set_Label_Time(2189,12.34)

tuning = [data_GfO01_M1875_20200108_S1_V6.Neurons.TuningID];
id = raster_GfO01_M1875_20200108_S1_V6_analysis.Plot.IDstructure;

figure
plot(tuning(id),'.-k')
view([90 -90]);xlim([1 length(id)])
ylabel('tuning')

Set_Figure('Evocked activity')
vstim = data_GfO01_M1875_20200108_S1_V6.VoltageRecording.Stimuli;
for i = find(tuning==1)
    activity = data_GfO01_M1875_20200108_S1_V6.Transients.Raster(i,:);
    avg = Average_Activity_From_Stim(activity,vstim,12,48);
    plot(avg-avg(1),'r'); hold on
end
for i = find(tuning~=1)
    activity = data_GfO01_M1875_20200108_S1_V6.Transients.Raster(i,:);
    avg = Average_Activity_From_Stim(activity,vstim,12,48);
    plot(avg-avg(1),'b');
end
Set_Label_Time(84,12.34,12)

find(raster_GfO01_M1875_20200108_S1_V6_analysis.Plot.Structure(:,16))

%}