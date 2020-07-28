function [video_registered] = Apply_Rigid_Motion(video,motion,displacement)
% Get rigid motion from video
%
%       [video_registered] = Apply_Rigid_Motion(video,motion)
%
%       Default: displacement = 10 (maximum number of pixel displacement)
%
% By Jesus Perez-Ortega, July 2019

% Set default options 
if nargin== 1
    displacement = 10;
end

% Get size of the video
[h,w,n] = size(video);

% Initialize variables
video_registered = zeros(h,w,n,class(video));
previous_motion = affine2d(eye(3));

% First image
video_registered(:,:,1) = video(:,:,1);

% Perform correction
tic
for i = 2:n
    % Detect displacement bigger than expected
    if max(abs(motion{i}.T([3 6])))>displacement
        disp(['   Maximum displacement detected (frame ' num2str(i) ')'])
        
        % Correct with previous motion detected
        video_registered(:,:,i) = imwarp(video(:,:,i),previous_motion,'OutputView',imref2d([h w]));
    else
        % Correct image
        video_registered(:,:,i) = imwarp(video(:,:,i),motion{i},'OutputView',imref2d([h w]));
        previous_motion = motion{i};
    end
    
    % Show the state of computation each 100 frames
    if ~mod(i,100)
        t = toc; 
        fprintf('   %d/%d, %.1f s\n',i,n,t)
    end
end
t = toc;
fprintf('   %d/%d, %.1f s\n',i,n,t)