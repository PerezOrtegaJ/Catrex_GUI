function [motion,image_corrected] = Get_Motion_From_Image(image,reference)

[optimizer, metric] = imregconfig('monomodal');
options.optimizer = optimizer;
options.metric = metric;
% options.optimizer.GradientMagnitudeTolerance = 0.001;
% options.optimizer.MinimumStepLength = 0.001;
% options.optimizer.MaximumStepLength = 0.1;
% options.optimizer.MaximumIterations = 100;
% options.optimizer.RelaxationFactor = 0.3;

[h,w] = size(image);

image = rescale(image);
reference = rescale(reference);

motion = imregtform(image,reference,'rigid',...
        options.optimizer,options.metric,...'DisplayOptimization',true,...
        'pyramidlevels',3);
image_corrected = imwarp(image,motion,'OutputView',imref2d([h w]));

% reference - green, image corrected magenta
imshowpair(reference,image_corrected)