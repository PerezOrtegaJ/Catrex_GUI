function [registeredImage,motion,displacement] = Register_Masks(fixed,moving)
% Register grayscale images
%
%       [registeredImage,motion,displacement] = Register_Masks(fixed,moving)
%
% Auto-generated by registrationEstimator app on 20-Feb-2020
% then modified by Jesus Perez-Ortega, Feb 2020

% Default spatial referencing objects
fixedRefObj = imref2d(size(fixed));

% Intensity-based registration
[optimizer, metric] = imregconfig('monomodal');
optimizer.GradientMagnitudeTolerance = 1.00000e-04;
optimizer.MinimumStepLength = 1.00000e-05;
optimizer.MaximumStepLength = 0.01;
optimizer.MaximumIterations = 1000;
optimizer.RelaxationFactor = 0.500000;

% Apply transformation
motion = imregtform(moving,fixed,'similarity',optimizer,metric,...
    'PyramidLevels',3);
registeredImagePre = imwarp(moving,motion,'OutputView',fixedRefObj,...
    'SmoothEdges',true);

% Nonrigid registration
[displacement,registeredImage] = imregdemons(registeredImagePre,fixed,...
    [100 50 25],'AccumulatedFieldSmoothing',1.0,'PyramidLevels',3,'DisplayWaitBar',false);