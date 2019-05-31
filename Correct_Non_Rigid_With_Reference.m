function [motion,video_registered,reference] = Correct_Non_Rigid_With_Reference(video,options,reference)
% Jesus Perez-Ortega April-19

% Set default options 
switch(nargin)
    case 1
        reference = mean(video,3);
        options.iterations = [64 32 4];
        options.pyramid_levels = 3;
        options.AccumulatedFieldSmoothing = 1.5;
    case 2
        reference = mean(video,3);
end

% Initialize variables
[h,w,n] = size(video);
video_registered = zeros(h,w,n,class(video));
motion = cell(n,1);

% Perform correction
tic
reference = medfilt2(reference);
for i = 1:n
    % Image to register
    moving = video(:,:,i);
    
    % Identify motion
    motion{i} = imregdemons(medfilt2(moving),reference,options.iterations,...
        'AccumulatedFieldSmoothing',options.AccumulatedFieldSmoothing,...
        'PyramidLevels',options.pyramid_levels,...
        'DisplayWaitBar',false);

    % Apply motion to original image
    video_registered(:,:,i) = imwarp(moving,motion{i});
    
    % Show the state of computation each 100 frames
    if ~mod(i,100)
        t = toc; 
        fprintf('%d/%d, %.1f s\n',i,n,t)
    end
end
t = toc;
fprintf('%d/%d, %.1f s\n',i,n,t)