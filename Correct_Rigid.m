function [motion, video_registered] = Correct_Rigid(video,options)
% Jesus Perez-Ortega April-19

% Set default options 
switch(nargin)
    case 1
        [optimizer, metric] = imregconfig('monomodal');
        options.optimizer = optimizer;
        options.metric = metric;
        options.MaximumDisplacement = 20;
end

% Get size of the video
[h,w,n] = size(video);

% filter video
video_filtered = rescale(imfilter(rescale(video),Generate_Cell_Template(4),'symmetric'));

% Initialize variables
motion = cell(n,1);
video_registered = zeros(h,w,n,class(video));
reference = video_filtered(:,:,1);
motion{1} = affine2d(eye(3));
video_registered(:,:,1) = video(:,:,1);

% Perform correction
tic
for i = 2:n
    % Get next image
    image = video_filtered(:,:,i);
    
    % Correct motion
    motion{i} = imregtform(image,reference,'rigid',...
        options.optimizer,options.metric,...'DisplayOptimization',true,...
        'pyramidlevels',3);
    
    max_diff = max(abs(minmax(motion{i}.T(:)')));
    if max_diff>options.MaximumDisplacement
        disp(['Maximum displacement detected (frame ' num2str(i) ')'])
        
        % Ignore frame
        video_registered(:,:,i) = video(:,:,i);
    else
        % Correct image
        video_registered(:,:,i) = imwarp(video(:,:,i),motion{i},'OutputView',imref2d([h w]));
    end
    
    % Show the state of computation each 100 frames
    if ~mod(i,100)
        t = toc; 
        fprintf('%d/%d, %.1f s\n',i,n,t)
    end
end
t = toc;
fprintf('%d/%d, %.1f s\n',i,n,t)