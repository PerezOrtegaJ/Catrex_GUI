function [motion,average_image] = Correct_Non_Rigid_Recurrent(video,options)
% Jesus Perez-Ortega April-19

% Set default options 
if nargin==2
    options.iterations = [64 32 16];
    options.pyramid_levels = 3;
    options.AccumulatedFieldSmoothing = 2.5;
end
    
% Perform correction
[h,w,n] = size(video);

if n==1
    a = video(:,:,1);
    average_image = a;
    motion = {zeros([size(a) 2])};
elseif n==2
    % Read images
    a = video(:,:,1);
    b = video(:,:,2);
    
    % Get displacement
    [motion_a,registered_a] = imregdemons(a,b,options.iterations,...
        'AccumulatedFieldSmoothing',options.AccumulatedFieldSmoothing,...
        'PyramidLevels',options.pyramid_levels,...
        'DisplayWaitBar',false);
    
    % Get motion and average image
    average_image = registered_a/2+b/2;
    motion = {motion_a zeros([h w 2])};
else
    % Split videos
    video_1 = video(:,:,1:floor(end/2));
    video_2 = video(:,:,floor(end/2)+1:end);
    
    % Recurrent function
    [motion_1,a] = Correct_Non_Rigid(video_1,options);
    [motion_2,b] = Correct_Non_Rigid(video_2,options);
    
    % Get displacement
    [motion_a,registered_a] = imregdemons(a,b,options.iterations,...
        'AccumulatedFieldSmoothing',options.AccumulatedFieldSmoothing,...
        'PyramidLevels',options.pyramid_levels,...
        'DisplayWaitBar',false);


    % Get motion and average image
    average_image = registered_a/2+b/2;
    motion_1 = cellfun(@(x) (x+motion_a),motion_1,'UniformOutput',false);
    motion = [motion_1 motion_2];
end