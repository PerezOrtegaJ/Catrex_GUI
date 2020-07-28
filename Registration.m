function [registered,motion] = Registration(video,mode)
% Registration based on reference
%
%       [registered,motion] = Registration(video,mode)
%
%        default: mode = 'rigid' (it also could be 'nonrigid')
%
% by Jesus Perez-Ortega, Dec 2019

if nargin==1
    rigid = true;
    mode = 'rigid';
elseif nargin==2
    switch mode
        case 'translation'
            rigid = true;
        case 'rigid'
            rigid = true;
        case 'similarity'
            rigid = true;
        case 'affine'
            rigid = true;
        case 'nonrigid'
            rigid = false;
    end
end

tic

% Get size of the movie
[y,x,frames] = size(video);

if frames>20
    % Get the number of the images for reference
    nAvg = round(0.05*frames);
    % Get reference (average of 5% of images with no motion)
    reference = mean(video(:,:,randi([1 frames],1,nAvg)),3);
    reference = uint8(round(reference));
else
    % Get the first frame as reference
    reference = video(:,:,1);
end

% Initialize variables
registered = zeros(y,x,frames);
motion = cell(frames,1);

% Get optimizer for registration
if rigid
    % Rigid
    [optimizer, metric] = imregconfig('monomodal');
    optimizer.MaximumStepLength = 0.01;
    optimizer.MaximumIterations = 1000;
    optimizer.RelaxationFactor = 0.5;
    options.optimizer = optimizer;
    options.metric = metric;
else
    % Nonrigid
    options.iterations = [100 50 25];
    options.pyramid_levels = 3;
    options.AccumulatedFieldSmoothing = 1; % 2
end

disp('Getting motion correction...')
ten_perc = round(frames/10);
for i = 1:frames
    % Image to register
    moving = video(:,:,i);
    
    % Adjust histogram to match
    %moving = imhistmatch(moving,reference);
    
    % Identify motion
    if rigid
        motion{i} = imregtform(moving,reference,mode,...
            options.optimizer,options.metric,...'DisplayOptimization',true,...
            'pyramidlevels',3);
    else
        motion{i} = imregdemons(moving,reference,options.iterations,...
            'AccumulatedFieldSmoothing',options.AccumulatedFieldSmoothing,...
            'PyramidLevels',options.pyramid_levels,...
            'DisplayWaitBar',false);
    end
    
    % Apply motion
    if rigid
        registered(:,:,i) = imwarp(moving,motion{i},'OutputView',imref2d([y x]));
    else
        registered(:,:,i) = imwarp(moving,motion{i},'nearest');
    end
    
    % Show the state of computation each 10% frames
    if ~mod(i,ten_perc)
        t = toc; 
        fprintf('   %d %%, %.1f s\n',round(i/n*100),t)
    end
end
t = toc; 
fprintf('   100%%, %.1f s\n',t)