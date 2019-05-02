function [motion,reference] = Correct_Rigid_With_Reference(video,reference,options)
% Jesus Perez-Ortega April-19

% Set default options 
switch(nargin)
    case 1
        reference = mean(video,3);
        [optimizer, metric] = imregconfig('multimodal');
        options.optimizer = optimizer;
        options.metric = metric;
    case 2
        [optimizer, metric] = imregconfig('multimodal');
        options.optimizer = optimizer;
        options.metric = metric;
end

n = size(video,3);

% Perform correction
motion = cell(1,n);
for i = 1:n
   motion{i} = imregtform(video(:,:,i),reference,'rigid',...
       options.optimizer,options.metric,'PyramidLevels',4);
end