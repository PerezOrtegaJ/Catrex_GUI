function video_registered = Fast_Registration(video,locomotion,fps,nonrigid)
% fast registration taking into account the times where the animal is
% moving
%
%       video_registered = Fast_Registration(video,locomotion,fps,nonrigid)
%
% by Jesus Perez-Ortega, August 2019
% modified Sep 2019

if nargin==3
    nonrigid = false;
end

tic

% Get size of the movie
[y,x,frames] = size(video);

% smooth locomotion at 1 s bin
loco = smooth(locomotion,round(fps));

% Get the number of the images for reference
n_img_avg = round(0.05*frames);

% Define threshold for locomotion
th = 0.3;

% Get reference (average of 5% of images with no motion)
id_no_loco = find(loco<th);
[~,id] = sort(loco(id_no_loco));
n_img_avg = min([n_img_avg length(id)]);
id_no_loco = id_no_loco(id(1:n_img_avg));
reference = mean(video(:,:,id_no_loco),3);
reference = uint8(round(reference));

% Get frames with motion
id_loco = find(loco>th);
video_loco = video(:,:,id_loco);
n = length(id_loco);

% Initialize variables
registered = zeros(y,x,n);
%motion = cell(n,1);

% Get optimizer for registration
% Rigid
[optimizer, metric] = imregconfig('monomodal');
options.optimizer = optimizer;
options.metric = metric;
% Nonrigid
options.iterations = [100 50 25];
options.pyramid_levels = 3;
options.AccumulatedFieldSmoothing = 2;

% Plot summary of motion correction
Set_Figure('Motion correction',[0 0 1000 200])
plot(locomotion); hold on
plot(id_loco,locomotion(id_loco),'.k')
ylabel('locomotion [cm/s]')
title(sprintf('   %d frames will be corrected\n',n))
Set_Label_Time(frames,fps)
drawnow 

fprintf('   %d frames will be corrected\n',n)
ten_perc = round(n/10);
for i = 1:n
    % Image to register
    moving = video_loco(:,:,i);
    
    % Adjust histogram to match
    moving_match = imhistmatch(moving,reference);
    
    % Identify motion
    if nonrigid
        motion = imregdemons(moving_match,reference,options.iterations,...
            'AccumulatedFieldSmoothing',options.AccumulatedFieldSmoothing,...
            'PyramidLevels',options.pyramid_levels,...
            'DisplayWaitBar',false);
    else
        motion = imregtform(moving_match,reference,'translation',...
            options.optimizer,options.metric,...'DisplayOptimization',true,...
            'pyramidlevels',3);
    end
    
    % Apply motion
    if nonrigid
        registered(:,:,i) = imwarp(moving,motion,'nearest');
    else
        registered(:,:,i) = imwarp(moving,motion,'OutputView',imref2d([y x]));
    end
    
    % Show the state of computation each 10% frames
    if ~mod(i,ten_perc)
        t = toc; 
        fprintf('   %d %%, %.1f s\n',round(i/n*100),t)
    end
end

video_registered = video;
video_registered(:,:,id_loco) = registered;

t = toc; 
fprintf('   100%%, %.1f s\n',t)