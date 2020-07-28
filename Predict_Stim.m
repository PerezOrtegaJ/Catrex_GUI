function [predicted,error] = Predict_Stim(raster,weights,targets,plot_figure,name)
% Predict stimulus from orientation weights
%
%       [predicted,error] = Predict_Stim(raster,weights,targets,plot_figure,name)
%
%       default: plot_figure = false; name = ''
%
% By Jesus Perez-Ortega, Aug 2019

if nargin==3
    plot_figure = false;
    name = '';
elseif nargin==4
    name = '';
end

predicted=[];
frames=size(raster,2);
for i = 1:frames
    single_data = raster(:,i);
    
    % Make prediction
    y_preds(i,:) = sum(single_data.*weights);
    [~,predicted(i)] = max(y_preds(i,:));
end

[cm,cl] = confusionmat(targets,predicted);
tp = sum(diag(cm))/frames;
error = 1-tp;

if plot_figure
    Set_Figure([name ' - confusion matrix'],[0 0 500 500])
    confusionchart(cm,cl);
    title([name ' - loss: ' num2str(error*100) '%'])

    % ROC
%     plotroc(dummyvar(targets)',y_preds')
%     plotroc(dummyvar(targets)',dummyvar(predicted)')
end