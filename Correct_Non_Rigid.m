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

% filter video
video_filtered = Scale(imfilter(Scale(video),Generate_Cell_Template(4),'symmetric'));

% Set first reference
reference = video_filtered(:,:,1);
video_registered(:,:,1) = video(:,:,1);
continues_max = 0;
tic
for i = 2:n
    % Adjust histogram
    image = video_filtered(:,:,i);

    % Get displacement
    [motion_i,new_ref] = imregdemons(image,reference,options.iterations,...
        'AccumulatedFieldSmoothing',options.AccumulatedFieldSmoothing,...
        'PyramidLevels',options.pyramid_levels,...
        'DisplayWaitBar',false);
    
    % Apply motion to original image
    motion{i} = motion_i;
        
    % Ignore if exceeds a maximum displacement 
    max_diff = max(abs(minmax(motion_i(:)')));
    %disp(max_diff)
    if max_diff>options.MaximumDisplacement
        continues_max = continues_max + 1;
        disp(['Maximum displacement detected (frame ' num2str(i) ')'])
        
        % Ignore frame
        video_registered(:,:,i) = video(:,:,i);
        
        % Change reference if maximum difference is continuos
        if continues_max>2
            reference = image;
        end
    else
        % Correct motion
        video_registered(:,:,i) = imwarp(video(:,:,i),motion_i);
        
        reference = new_ref;
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