function motion = Detect_Motion_With_Reference(video,reference,options)
% Detect rigid motion from a movie by a given reference
%
%       [motion,reference] = Detect_Motion_With_Reference(video,reference,options)
%
% Jesus Perez-Ortega, April 2019
% Modified, Dec 2019

% Set default options 
if nargin==2
    [optimizer, metric] = imregconfig('monomodal');
    options.optimizer = optimizer;
    options.metric = metric;
end

n = size(video,3);

% Detect motion
motion = cell(1,n);
for i = 1:n
     % Image to register
    moving = video(:,:,i);
    
    % Adjust histogram to match
    %moving = imhistmatch(moving,reference);
    
    motion{i} = imregtform(moving,reference,'rigid',... % 'rigid' or 'translation'
            options.optimizer,options.metric,... 'DisplayOptimization',true,...
            'pyramidlevels',3);
end

