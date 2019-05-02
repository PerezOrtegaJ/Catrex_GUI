function [motion,reference] = Correct_Non_Rigid_With_Reference(video,reference,options)
% Jesus Perez-Ortega April-19

% Set default options 
switch(nargin)
    case 1
        reference = mean(video,3);
        options.iterations = [32 16 8];
        options.pyramid_levels = 3;
        options.AccumulatedFieldSmoothing = 2.5;
    case 2
        options.iterations = [32 16 8];
        options.pyramid_levels = 3;
        options.AccumulatedFieldSmoothing = 2.5;
end

n = size(video,3);

% Perform correction
motion = cell(1,n);
for i = 1:n
   moving = imhistmatch(video(:,:,i),reference);
   motion{i} = imregdemons(moving,reference,options.iterations,...
        'AccumulatedFieldSmoothing',options.AccumulatedFieldSmoothing,...
        'PyramidLevels',options.pyramid_levels,...
        'DisplayWaitBar',false);
end