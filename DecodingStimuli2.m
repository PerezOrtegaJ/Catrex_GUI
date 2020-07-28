% Decoding stimuli 2

[table_a,table_b,id_a,id_b] = Get_Intersected_Data(data_GC05_M1123_20190712_A,...
    data_GC05_M1123_20190712_B,'tuned','inference_th','join');
n = length(id_a);
[~,id] = sort([data_GC05_M1123_20190712_A.Neurons(id_a).SortingID]);

weights_a = [data_GC05_M1123_20190712_A.Neurons(id_a).WeightsOrientation]';
weights_a = weights_a(id,:);
weights_norm_a = weights_a./max(weights_a')';

raster_a = table_a{:,1:end-1}';
raster_a = raster_a(id,:);
raster_b = table_b{:,1:end-1}';
raster_b = raster_b(id,:);

stim_a = double([table_a.Stim]);
stim_b = double([table_b.Stim]);

% using weights of orientation
[~,error] = Predict_Stim(raster_a,weights_norm_a,stim_a,true,'A predict A');
disp(['A. Loss: ' num2str(error*100)])

[~,error] = Predict_Stim(raster_b,weights_norm_a,stim_b,true,'A predict B');
disp(['B. Loss: ' num2str(error*100)])

% decoding attack
%
% deleting by orientation selectivity
oi = [data_GC05_M1123_20190712_A.Neurons(id_a).OrientationIndex]';
oi = oi(id);

BC = betweenness_bin(net_a);
[~,cc_id] = sort(BC,'descend');

[~,id_oi] = sort(oi,'descend');




indices = randperm(68); 
all_nodes = 1:n;
for i=1:n-1
    disp(['neurons removed: ' num2str(i)])
    
    % Delete elements from matrix
    id = setdiff(all_nodes,indices(1:i));
    
    % A
    [~,error_a1(i)] = Predict_Stim(raster_a(id,:),weights_norm_a(id,:),stim_a,false,'A predict A');
    disp(['A. Loss: ' num2str(error*100)])
    
    % B
    [~,error_b1(i)] = Predict_Stim(raster_b(id,:),weights_norm_a(id,:),stim_b,false,'A predict B');
    disp(['B. Loss: ' num2str(error*100)])
end

Set_Figure('attack by orientation index + -> -',[0 0 500 300])
plot(error_a1); hold on
plot(error_b1)
% plot(error_a2,'--')
% plot(error_b2,'--')
legend({'same data','30 min after','A','B'})
title('Prediction error')
ylabel('error')
xlabel('neurons removed')
%}

