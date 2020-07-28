function [error_train,error_test,model_knn] = Get_KNN_Errors(data,holdout)
% Get the errors from knn model
%
%       [error_training,error_test,model_knn] = Get_KNN_Errors(data,holdout)
%
%       default: holdout = 0.2
%
% By Jesus Perez-Ortega, July 2019

if nargin == 1
    holdout = 0.2;
end

% Create the training and test data from A
pt = cvpartition(data.Stim,'HoldOut',holdout);
a_train = data(training(pt),:);
a_test = data(test(pt),:);

% Create model
model_knn = fitcknn(a_train,'Stim','numneighbors',1,'distance','correlation','standardize','on');
%model_knn = fitcknn(a_train,'Stim','numneighbors',1,'distance','jaccard');

% Training error
error_train = resubLoss(model_knn);

% Test error
error_test = loss(model_knn,a_test);
