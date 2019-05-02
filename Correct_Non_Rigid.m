function [motion,video_registered] = Correct_Non_Rigid(video,options)
% Motion correction by non-rigid algorithm
%
%       [motion,video_registered] = Correct_Non_Rigid(video,options)
%   
%       default options:
%           options.iterations = [64 16 4];
%           options.pyramid_levels = 3;
%           options.AccumulatedFieldSmoothing = 2.5;
%           options.MaximumDisplacement = 20;
%            
% Jesus Perez-Ortega April-19

% Set default options 
if nargin==1
    options.iterations = [64 16 4];
    options.pyramid_levels = 3;
    options.AccumulatedFieldSmoothing = 2.5;
    options.MaximumDisplacement = 20;
end

% Initialize variables
[h,w,n] = size(video);
video_registered = zeros(h,w,n,class(video));
motion = cell(n,1);

% Set first reference
reference = video(:,:,1);
video_registered(:,:,1) = reference;
continues_max = 0;
for i = 2:n
    % Adjust histogram
    image = video(:,:,i);

    % Get displacement
    [motion_i,registered] = imregdemons(image,reference,options.iterations,...
        'AccumulatedFieldSmoothing',options.AccumulatedFieldSmoothing,...
        'PyramidLevels',options.pyramid_levels,...
        'DisplayWaitBar',false);
    
    % Ignore if exceeds a maximum displacement 
    max_diff = max(abs(minmax(motion_i(:)')));
    if max_diff>options.MaximumDisplacement
        continues_max = continues_max + 1;
        disp(['Maximum displacement detected (frame ' num2str(i) ')'])
        motion{i} = zeros([h w 2]);
        video_registered(:,:,i) = image;
        % Change reference if maximum difference is continuos
        if continues_max>2
            reference = image;
        end
    else
        motion{i} = motion_i;
        reference = registered;
        video_registered(:,:,i) = registered;
        continues_max = 0;
    end
    
    % Show the state of computation each 100 frames
    if ~mod(i,100)
        t = toc; 
        fprintf('%d/%d, %.1f s\n',i,n,t)
    end
end
t = toc;
fprintf('%d/%d, %.1f s\n',i,n,t)