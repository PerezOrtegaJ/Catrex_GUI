function [motion, reference] = Correct_Rigid(video,options)
% Jesus Perez-Ortega April-19

% Set default options 
switch(nargin)
    case 1
        [optimizer, metric] = imregconfig('multimodal');
        options.optimizer = optimizer;
        options.metric = metric;
end

% Get size of the video
[h,w,n] = size(video);

% Initialize variables
motion = cell(1,n);
reference = video(:,:,1);
motion{1} = affine2d(eye(3));

% Perform correction
for i = 2:n
    % Get next image
    image = video(:,:,i);
    
    % Correct motion
    motion{i} = imregtform(image,reference,'rigid',...
        options.optimizer,options.metric,...'DisplayOptimization',true,...
        'pyramidlevels',4);
    
    % Correct image
    corrected = imwarp(image,motion{i},'OutputView',imref2d([h w]));
    %reference = (reference + corrected)/2;
    reference = corrected;
end