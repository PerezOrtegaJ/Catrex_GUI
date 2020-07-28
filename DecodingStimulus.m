% Test decoding neurons


% Data A decoding Data A
% data data_GC04_M1120_20190712
%{
data_type = 'raster';
observation_type = 'single';
[all,all_b,id_all,id_all_b] = Get_Intersected_Data(data_GC04_M1120_20190712_A,data_GC04_M1120_20190712_B,'all',data_type,observation_type);
[tuned,tuned_b,id_tuned,id_tuned_b] = Get_Intersected_Data(data_GC04_M1120_20190712_A,data_GC04_M1120_20190712_B,'tuned',data_type,observation_type);
[inter,inter_b,id_inter,id_inter_b] = Get_Intersected_Data(data_GC04_M1120_20190712_A,data_GC04_M1120_20190712_B,'inter',data_type,observation_type);
[loco,loco_b,id_loco,id_loco_b] = Get_Intersected_Data(data_GC04_M1120_20190712_A,data_GC04_M1120_20190712_B,'locomotion',data_type,observation_type);
[others,others_b,id_others,id_others_b] = Get_Intersected_Data(data_GC04_M1120_20190712_A,data_GC04_M1120_20190712_B,'others',data_type,observation_type);
%}

% data data_GC04_M1120_20190715_A
%{
[all,all_b,id_all,id_all_b] = Get_Intersected_Data(data_GC04_M1120_20190715_A,data_GC04_M1120_20190715_B,'all','raster','single');
[tuned,tuned_b,id_tuned,id_tuned_b] = Get_Intersected_Data(data_GC04_M1120_20190715_A,data_GC04_M1120_20190715_B,'tuned','raster','single');
[inter,inter_b,id_inter,id_inter_b] = Get_Intersected_Data(data_GC04_M1120_20190715_A,data_GC04_M1120_20190715_B,'inter','raster','single');
[loco,loco_b,id_loco,id_loco_b] = Get_Intersected_Data(data_GC04_M1120_20190715_A,data_GC04_M1120_20190715_B,'locomotion','raster','single');
[others,others_b,id_others,id_others_b] = Get_Intersected_Data(data_GC04_M1120_20190715_A,data_GC04_M1120_20190715_B,'others','raster','single');
%}

% data data_GC05_M1123_20190712_A
%{
% Single frame
[all,all_b,id_all,id_all_b] = Get_Intersected_Data(data_GC05_M1123_20190712_A,data_GC05_M1123_20190712_B,'all','raster','single');
[tuned,tuned_b,id_tuned,id_tuned_b] = Get_Intersected_Data(data_GC05_M1123_20190712_A,data_GC05_M1123_20190712_B,'tuned','raster','single');
[inter,inter_b,id_inter,id_inter_b] = Get_Intersected_Data(data_GC05_M1123_20190712_A,data_GC05_M1123_20190712_B,'inter','raster','single');
[loco,loco_b,id_loco,id_loco_b] = Get_Intersected_Data(data_GC05_M1123_20190712_A,data_GC05_M1123_20190712_B,'locomotion','raster','single');
[others,others_b,id_others,id_others_b] = Get_Intersected_Data(data_GC05_M1123_20190712_A,data_GC05_M1123_20190712_B,'others','raster','single');

% Join frames
[all,all_b,id_all,id_all_b] = Get_Intersected_Data(data_GC05_M1123_20190712_A,data_GC05_M1123_20190712_B,'all','inference','join');
[tuned,tuned_b,id_tuned,id_tuned_b] = Get_Intersected_Data(data_GC05_M1123_20190712_A,data_GC05_M1123_20190712_B,'tuned','inference','join');
[inter,inter_b,id_inter,id_inter_b] = Get_Intersected_Data(data_GC05_M1123_20190712_A,data_GC05_M1123_20190712_B,'inter','inference','join');
[loco,loco_b,id_loco,id_loco_b] = Get_Intersected_Data(data_GC05_M1123_20190712_A,data_GC05_M1123_20190712_B,'locomotion','inference','join');
[others,others_b,id_others,id_others_b] = Get_Intersected_Data(data_GC05_M1123_20190712_A,data_GC05_M1123_20190712_B,'others','inference','join');
%}

% Which neurons
%{
% All
neuron = [tuned{:,1:end-1} inter{:,1:end-1} loco{:,1:end-1} others{:,1:end-1}];
id_neuron = [id_tuned id_inter id_loco id_others];

% Tune
neuron = [tuned{:,1:end-1}];

% Inter-stimulus, locomotion and other
neuron = [inter{:,1:end-1} loco{:,1:end-1} others{:,1:end-1}];

% Tune and locomotion
neuron = [tuned{:,1:end-1} loco{:,1:end-1}];

% Tune and inter-stimulus
neuron = [tuned{:,1:end-1} inter{:,1:end-1}];

% Tune and others
neuron = [tuned{:,1:end-1} others{:,1:end-1}];

% Inter-stimulus
neuron = [inter{:,1:end-1}];

% Locomotion
neuron = [loco{:,1:end-1}];

% Others
neuron = [others{:,1:end-1}];
%}

% Create table
%{
tic
neurons = array2table(neuron);
neurons = [neurons tuned(:,end)];

for i = 1:10
    [error_train(i),error_test(i),models{i}] = Get_KNN_Errors(neurons);
    %[error_train(i),error_test(i),models{i}] = Get_KNN_Errors(neurons(:,[selected true]));
end
disp(['neurons: ' num2str(size(neurons,2)-1)])
disp(['train: ' num2str(mean(error_train)*100)])
disp(['test: ' num2str(mean(error_test)*100)])
toc
%}


% first half vs second half
%{
neurons = array2table(neuron);
neurons = [neurons all(:,end)];
neurons1 = neurons(1:20,:);
neurons2 = neurons(21:40,:);
neurons3 = neurons(41:60,:);
neurons4 = neurons(61:end,:);
% neurons1 = neurons(1:1000,:);
% neurons2 = neurons(1001:2000,:);
% neurons3 = neurons(2001:3000,:);
% neurons4 = neurons(3001:end,:);


for i = 1:10
    model_knn = fitcknn(neurons1,'Stim','numneighbors',1,'distance','jaccard');
    error_test1(i) = loss(model_knn,neurons1);
    error_test2(i) = loss(model_knn,neurons2);
    error_test3(i) = loss(model_knn,neurons3);
    error_test4(i) = loss(model_knn,neurons4);
end
disp(['1: ' num2str(mean(error_test1)*100)])
disp(['2: ' num2str(mean(error_test2)*100)])
disp(['3: ' num2str(mean(error_test3)*100)])
disp(['4: ' num2str(mean(error_test4)*100)])
%}


% Create table
tic
neurons = array2table(neuron);
neurons = [neurons all(:,end)];

for i = 1:10
    models{i} = fitcknn(neurons,'Stim','numneighbors',1,'distance','correlation','standardize','on');
end
toc


% Which neurons B
%{
% All
neuron = [tuned_b{:,1:end-1} inter_b{:,1:end-1} loco_b{:,1:end-1} others_b{:,1:end-1}];
id_neuron_b = [id_tuned_b id_inter_b id_loco_b id_others_b];

% Tune
neuron = [tuned_b{:,1:end-1}];

% Inter-stimulus, locomotion and other
neuron = [inter_b{:,1:end-1} loco_b{:,1:end-1} others_b{:,1:end-1}];

% Tune and locomotion
neuron = [tuned_b{:,1:end-1} loco_b{:,1:end-1}];

% Tune and inter-stimulus
neuron = [tuned_b{:,1:end-1} inter_b{:,1:end-1}];

% Tune and others
neuron = [tuned_b{:,1:end-1} others_b{:,1:end-1}];

% Inter-stimulus
neuron = [inter_b{:,1:end-1}];

% Locomotion
neuron = [loco_b{:,1:end-1}];

% Others
neuron = [others_b{:,1:end-1}];
%}

% Test on B
%
neurons_b = array2table(neuron);
neurons_b = [neurons_b all_b(:,end)];
for i = 1:10
    error_test_b(i) = loss(models{i},neurons_b);
    %error_test_b(i) = loss(models{i},neurons_b(:,[selected true]));
end
disp(['test B: ' num2str(mean(error_test_b)*100)])
%}

neurons_b = array2table(neuron);
neurons_b = [neurons_b tuned_b(:,end)];
y_real = double([neurons_b.Stim]);
y_real(y_real>4) = y_real(y_real>4)-4;
for i = 1:10
    y_pred = double(predict(models{i},neurons_b));
    y_pred(y_pred>4) = y_pred(y_pred>4)-4;
    [cm,cl] = confusionmat(y_real,y_pred);
    tp = sum(diag(cm))/frames;
    error_test_b(i) = 1-tp;
end
disp(['test B: ' num2str(mean(error_test_b)*100)])




% Feature selection
%{
af = @(x_train,y_train,x_test,y_test)nnz(y_test ~= predict(fitcknn(...
    x_train,y_train,'NumNeighbors',1,'distance','jaccard'),x_test));
selected = sequentialfs(af,neurons{:,1:end-1},neurons{:,end},'options',statset('Display','iter'));


neurons_selected = data_GC04_M1120_20190712_A.Neurons(id_neuron(selected));

model_fs = fitcknn(neurons(:,[selected true]),'Stim','NumNeighbors',1,...
    'distance','jaccard');
disp(['error: ' num2str(resubLoss(models{8}))]);
%}


%{
% Test on A data
y_real = a_test.Stim;
y_pred = predict(model_knn,a_test);
error_a = loss(model_knn,a_test);
[cm_a,cl_a]=confusionmat(y_real,y_pred);

% Test on B data
model_knn = models{6};
y_real = neurons_b.Stim;
y_pred = predict(model_knn,neurons_b);
error_b = loss(model_knn,neurons_b);
[cm_b,cl_b]=confusionmat(y_real,y_pred);
confusionchart(cm_b,cl_b);
title(['Loss: ' num2str(error_b*100) '%'])

% Plot
Set_Figure('Confusion matrix',[0 0 1000 500])
subplot(1,2,1)
confusionchart(cm_a,cl_a);
title(['Loss: ' num2str(error_a*100) '%'])
subplot(1,2,2)

%}
