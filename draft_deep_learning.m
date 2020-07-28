% draft deep learning


X = a{:,1:end-1}';
Y = a.Stim';
n_inputs = size(X,1);


pt = cvpartition(a.Stim,'HoldOut',0.2);
pt2 = cvpartition(nnz(test(pt)),'HoldOut',0.5);

% Train data
Xtrain = X(:,training(pt));
Ytrain = Y(:,training(pt));

% Validation data
Xval= X(:,test(pt));
Xval= Xval(:,training(pt2));
Yval= Y(:,test(pt));
Yval= Yval(:,training(pt2));
val_data = {Xval Yval};

% Test data
Xtest= X(:,test(pt));
Xtest= Xtest(:,test(pt2));
Ytest= Y(:,test(pt));
Ytest= Ytest(:,test(pt2));

% define layers
% layers = [
%     sequenceInputLayer(n_inputs,"Name","Neural vector")
%     fullyConnectedLayer(64,"Name","layer 1")
%     fullyConnectedLayer(8,"Name","layer 2")
%     reluLayer("Name","relu")
%     softmaxLayer("Name","softmax")
%     classificationLayer("Name","classoutput")];

% layers = [
%     sequenceInputLayer(n_inputs,"Name","Neural vector")
%     fullyConnectedLayer(8,"Name","layer 1")
%     reluLayer("Name","relu")
%     softmaxLayer("Name","softmax")
%     classificationLayer("Name","classoutput")];

layers = [
    sequenceInputLayer(n_inputs,"Name","Neural vector")
    reluLayer("Name","relu")
    fullyConnectedLayer(n_inputs,"Name","layer 1")
    reluLayer("Name","relu")
    fullyConnectedLayer(8,"Name","layer 1")
    softmaxLayer("Name","softmax")
    classificationLayer("Name","classoutput")];

% set trainign options
options = trainingOptions('sgdm','MaxEpochs',200,'InitialLearnRate',0.0001,...
    'Plots','training-progress','ValidationData',val_data,'ValidationFrequency',10);

% train network
net = trainNetwork(Xtrain,Ytrain,layers,options);


% TEST
pred = classify(net,Xtest);

lossNet = nnz(Ytest~=pred)/length(pred)*100;

