function video_registered = Fast_Rigid_Registration(video,locomotion,fps)
% fast rigid registration taking into account the times where the animal is
% moving
%
%       video_registered = Fast_Rigid_Registration(video,locomotion,fps)
%
% by Jesus Perez-Ortega, August 2019

tic

% Get size of the movie
[y,x,frames] = size(video);

% smooth locomotion at 1 s bin
loco = smooth(locomotion,round(fps));

% Get the number of the images for reference
n_img_avg = round(0.05*frames);

% Get reference (average of 5% of images with no motion)
id_no_loco = find(loco<0.1,n_img_avg,'first');
reference = mean(video(:,:,id_no_loco),3);
reference = uint8(round(reference));

% Get frames with motion
id_loco = find(loco>0.3);
video_loco = video(:,:,id_loco);
n = length(id_loco);

% Initialize variables
registered = zeros(y,x,n);
motion = cell(n,1);

% Get optimizer for registration
[optimizer, metric] = imregconfig('monomodal');
options.optimizer = optimizer;
options.metric = metric;

ten_perc = round(n/10);
for i = 1:n
    % Image to register
    moving = video_loco(:,:,i);
    
    % Adjust histogram to match
    moving_match = imhistmatch(moving,reference);
    
    % Identify motion
    motion{i} = imregtform(moving_match,reference,'translation',...
        options.optimizer,options.metric,...'DisplayOptimization',true,...
        'pyramidlevels',3);
    
    % Apply motion
    registered(:,:,i) = imwarp(moving,motion{i},'OutputView',imref2d([y x]));
    
    % Show the state of computation each 10 frames
    if ~mod(i,ten_perc)
        t = toc; 
        fprintf('   %d %%, %.1f s\n',round(i/n*100),t)
    end
end

video_registered = video;
video_registered(:,:,id_loco) = registered;

t = toc; 
fprintf('   100%%, %.1f s\n',t)