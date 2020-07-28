function motion = Get_Rigid_Motion(video,options)
% Get rigid motion from video
%
%       motion = Get_Rigid_Motion(video,options)
%
%       Default: [optimizer, metric] = imregconfig('monomodal');
%                options.optimizer = optimizer;
%                options.metric = metric;
%
% By Jesus Perez-Ortega, July 2019

% Set default options 
switch(nargin)
    case 1
        [optimizer, metric] = imregconfig('monomodal');
        options.optimizer = optimizer;
        options.metric = metric;
end

% Get size of the video
n = size(video,3);

% Initialize variables
motion = cell(n,1);
reference = video(:,:,1);
motion{1} = affine2d(eye(3));

% Perform correction
tic
for i = 2:n
    % Get next image
    image = video(:,:,i);
    
    % Correct motion
    motion{i} = imregtform(image,reference,'rigid',...
        options.optimizer,options.metric,...'DisplayOptimization',true,...
        'pyramidlevels',3);
    
    % Show the state of computation each 100 frames
    if ~mod(i,100)
        t = toc; 
        fprintf('%d/%d, %.1f s\n',i,n,t)
    end
end
t = toc;
fprintf('%d/%d, %.1f s\n',i,n,t)