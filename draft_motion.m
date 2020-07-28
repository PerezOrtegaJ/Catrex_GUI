% draft motion correction

%{
% load data
[y,x,n] = size(movie_A);
fps=12.5;
loco = smooth(data_movie_A.VoltageRecording.Locomotion,round(fps));

% Get the number of the images for reference
n_img_avg = round(0.05*n);

% reference
id_no_loco = find(loco<0.1,n_img_avg,'first');
reference = mean(movie_A(:,:,id_no_loco),3);
reference = uint8(round(reference));

% frames with motion
id_loco = find(loco>0.5);
video = movie_A(:,:,id_loco);
n_loco = length(id_loco);
%}

%% 1. Non-rigid (93s - 129 images) horrible
%{
tic
corrected_1 = zeros(y,x,n_loco);
motion_1 = cell(n_loco,1);
for i = 1:n_loco
    % Image to register
    moving = video(:,:,i);
    
    % Identify motion
    [motion_1{i}, corrected_1(:,:,i)] = imregdemons(moving,reference,'DisplayWaitBar',false);

    % Show the state of computation each 10 frames
    if ~mod(i,10)
        t = toc; 
        fprintf('%d/%d, %.1f s\n',i,n_loco,t)
    end
end
t = toc; 
fprintf('%d/%d, %.1f s\n',i,n_loco,t)
%}

%% 2. Non-rigid (23s - 129 images) horrible
%{
tic
corrected_2 = zeros(y,x,n_loco);
motion_2 = cell(n_loco,1);

options.iterations = [64 32 4];
options.pyramid_levels = 3;
options.AccumulatedFieldSmoothing = 1.5;
for i = 1:n_loco
    % Image to register
    moving = video(:,:,i);
    
    % Identify motion
    [motion_2{i}, corrected_2(:,:,i)] = imregdemons(moving,reference,options.iterations,...
        'AccumulatedFieldSmoothing',options.AccumulatedFieldSmoothing,...
        'PyramidLevels',options.pyramid_levels,...
        'DisplayWaitBar',false);
    
    % Show the state of computation each 10 frames
    if ~mod(i,10)
        t = toc; 
        fprintf('%d/%d, %.1f s\n',i,n_loco,t)
    end
end
t = toc; 
fprintf('%d/%d, %.1f s\n',i,n_loco,t)
%}

%% 3. Rigid (118s - 129 images) - bad
%{
tic
corrected_3 = zeros(y,x,n_loco);
motion_3 = cell(n_loco,1);

[optimizer, metric] = imregconfig('monomodal');
options.optimizer = optimizer;
options.metric = metric;
for i = 1:n_loco
    % Image to register
    moving = video(:,:,i);
    
    % Identify motion
    motion_3{i} = imregtform(moving,reference,'rigid',...
        options.optimizer,options.metric,...'DisplayOptimization',true,...
        'pyramidlevels',3);
    
    % Apply motion
    corrected_3(:,:,i) = imwarp(moving,motion_3{i},'OutputView',imref2d([y x]));
    
    % Show the state of computation each 10 frames
    if ~mod(i,10)
        t = toc; 
        fprintf('%d/%d, %.1f s\n',i,n_loco,t)
    end
end
t = toc; 
fprintf('%d/%d, %.1f s\n',i,n_loco,t)
%}


%% 4. Rigid (70s - 129 images) - bad, some crazy frames
%{
tic
corrected_4 = zeros(y,x,n_loco);
motion_4 = cell(n_loco,1);

[optimizer, metric] = imregconfig('monomodal');
options.optimizer = optimizer;
options.metric = metric;
options.optimizer.GradientMagnitudeTolerance = 0.001;
options.optimizer.MinimumStepLength = 0.001;
options.optimizer.MaximumStepLength = 0.1;
options.optimizer.MaximumIterations = 100;
options.optimizer.RelaxationFactor = 0.3;
for i = 1:n_loco
    % Image to register
    moving = video(:,:,i);
    
    % Identify motion
    motion_4{i} = imregtform(moving,reference,'rigid',...
        options.optimizer,options.metric,...'DisplayOptimization',true,...
        'pyramidlevels',3);
    
    % Apply motion
    corrected_4(:,:,i) = imwarp(moving,motion_4{i},'OutputView',imref2d([y x]));
    
    % Show the state of computation each 10 frames
    if ~mod(i,10)
        t = toc; 
        fprintf('%d/%d, %.1f s\n',i,n_loco,t)
    end
end
t = toc; 
fprintf('%d/%d, %.1f s\n',i,n_loco,t)
%}

%% 5. Rigid, dftregistration (1.6s - 129 images) - bad
%{
tic
corrected_5 = zeros(y,x,n_loco);
motion_5 = cell(n_loco,1);
usfac = 1;
affine_data = eye(3);
fft2_reference = fft2(reference);
for i = 1:n_loco
    % Image to register
    moving = video(:,:,i);
    
    % Identify motion
    output_5 = dftregistration(fft2(moving),fft2_reference,usfac);
    affine_data(6) = output_5(3);
    affine_data(3) = output_5(4);
    motion_5{i} = affine2d(affine_data);
    
    % Apply motion
    corrected_5(:,:,i) = imwarp(moving,motion_5{i},'OutputView',imref2d([y x]));
    
    % Show the state of computation each 10 frames
    if ~mod(i,10)
        t = toc; 
        fprintf('%d/%d, %.1f s\n',i,n_loco,t)
    end
end
t = toc; 
fprintf('%d/%d, %.1f s\n',i,n_loco,t)
%}

%% 6. Rigid, dftregistration (3.7s - 129 images) - bad
%{
tic
corrected_6 = zeros(y,x,n_loco);
motion_6 = cell(n_loco,1);
usfac = 10;
affine_data = eye(3);
fft2_reference = fft2(reference);
for i = 1:n_loco
    % Image to register
    moving = video(:,:,i);
    
    % Identify motion
    output_6 = dftregistration(fft2(moving),fft2_reference,usfac);
    affine_data(6) = output_6(3);
    affine_data(3) = output_6(4);
    motion_6{i} = affine2d(affine_data);
    
    % Apply motion
    corrected_6(:,:,i) = imwarp(moving,motion_6{i},'OutputView',imref2d([y x]));
    
    % Show the state of computation each 10 frames
    if ~mod(i,10)
        t = toc; 
        fprintf('%d/%d, %.1f s\n',i,n_loco,t)
    end
end
t = toc; 
fprintf('%d/%d, %.1f s\n',i,n_loco,t)
%}

%% 7. Rigid, dftregistration (101s - 129 images) - bad, crazi frames
%{
tic
corrected_7 = zeros(y,x,n_loco);
motion_7 = cell(n_loco,1);

[optimizer, metric] = imregconfig('monomodal');
options.optimizer = optimizer;
options.metric = metric;
for i = 1:n_loco
    % Image to register
    moving = video(:,:,i);
    
    % Identify motion
    motion_7{i} = imregtform(moving,reference,'similarity',...
        options.optimizer,options.metric,...'DisplayOptimization',true,...
        'pyramidlevels',3);
    
    % Apply motion
    corrected_7(:,:,i) = imwarp(moving,motion_7{i},'OutputView',imref2d([y x]));
    
    % Show the state of computation each 10 frames
    if ~mod(i,10)
        t = toc; 
        fprintf('%d/%d, %.1f s\n',i,n_loco,t)
    end
end
t = toc; 
fprintf('%d/%d, %.1f s\n',i,n_loco,t)
%}

%% ADJUSTING THE INTENSITY OF THE IMAGE

%% 1B. Non-rigid (94s - 129 images) bad gray intensities
%{
tic
corrected_1B = zeros(y,x,n_loco);
motion_1B = cell(n_loco,1);
for i = 1:n_loco
    % Image to register
    moving = video(:,:,i);
    moving_match = imhistmatch(moving,reference);
    
    % Identify motion
    [motion_1B{i}, corrected_1B(:,:,i)] = imregdemons(moving_match,reference,'DisplayWaitBar',false);

    % Show the state of computation each 10 frames
    if ~mod(i,10)
        t = toc; 
        fprintf('%d/%d, %.1f s\n',i,n_loco,t)
    end
end
t = toc; 
fprintf('%d/%d, %.1f s\n',i,n_loco,t)
%}

%% 2B. Non-rigid (23s - 129 images) bad gray intensities
%{
tic
corrected_2B = zeros(y,x,n_loco);
motion_2B = cell(n_loco,1);

options.iterations = [64 32 4];
options.pyramid_levels = 3;
options.AccumulatedFieldSmoothing = 1.5;
for i = 1:n_loco
    % Image to register
    moving = video(:,:,i);
    moving_match = imhistmatch(moving,reference);
    
    % Identify motion
    [motion_2B{i}, corrected_2B(:,:,i)] = imregdemons(moving_match,reference,options.iterations,...
        'AccumulatedFieldSmoothing',options.AccumulatedFieldSmoothing,...
        'PyramidLevels',options.pyramid_levels,...
        'DisplayWaitBar',false);
    
    % Show the state of computation each 10 frames
    if ~mod(i,10)
        t = toc; 
        fprintf('%d/%d, %.1f s\n',i,n_loco,t)
    end
end
t = toc; 
fprintf('%d/%d, %.1f s\n',i,n_loco,t)
%}

%% 3B. Rigid (123s - 129 images) - Good
%{
tic
corrected_3B = zeros(y,x,n_loco);
motion_3B = cell(n_loco,1);

[optimizer, metric] = imregconfig('monomodal');
options.optimizer = optimizer;
options.metric = metric;
for i = 1:n_loco
    % Image to register
    moving = video(:,:,i);
    moving_match = imhistmatch(moving,reference);
    
    % Identify motion
    motion_3B{i} = imregtform(moving_match,reference,'rigid',...
        options.optimizer,options.metric,...'DisplayOptimization',true,...
        'pyramidlevels',3);
    
    % Apply motion
    corrected_3B(:,:,i) = imwarp(moving,motion_3B{i},'OutputView',imref2d([y x]));
    
    % Show the state of computation each 10 frames
    if ~mod(i,10)
        t = toc; 
        fprintf('%d/%d, %.1f s\n',i,n_loco,t)
    end
end
t = toc; 
fprintf('%d/%d, %.1f s\n',i,n_loco,t)
%}


%% 4B. Rigid (58s - 129 images) - bad, some crazy frames
%{
tic
corrected_4B = zeros(y,x,n_loco);
motion_4B = cell(n_loco,1);

[optimizer, metric] = imregconfig('monomodal');
options.optimizer = optimizer;
options.metric = metric;
options.optimizer.GradientMagnitudeTolerance = 0.001;
options.optimizer.MinimumStepLength = 0.001;
options.optimizer.MaximumStepLength = 0.1;
options.optimizer.MaximumIterations = 100;
options.optimizer.RelaxationFactor = 0.3;
for i = 1:n_loco
    % Image to register
    moving = video(:,:,i);
    moving_match = imhistmatch(moving,reference);
    
    % Identify motion
    motion_4B{i} = imregtform(moving_match,reference,'rigid',...
        options.optimizer,options.metric,...'DisplayOptimization',true,...
        'pyramidlevels',3);
    
    % Apply motion
    corrected_4B(:,:,i) = imwarp(moving,motion_4B{i},'OutputView',imref2d([y x]));
    
    % Show the state of computation each 10 frames
    if ~mod(i,10)
        t = toc; 
        fprintf('%d/%d, %.1f s\n',i,n_loco,t)
    end
end
t = toc; 
fprintf('%d/%d, %.1f s\n',i,n_loco,t)
%}

%% 5B. Rigid, dftregistration (1.8s - 129 images) - bad
%{
tic
corrected_5B = zeros(y,x,n_loco);
motion_5B = cell(n_loco,1);
usfac = 1;
affine_data = eye(3);
fft2_reference = fft2(reference);
for i = 1:n_loco
    % Image to register
    moving = video(:,:,i);
    moving_match = imhistmatch(moving,reference);

    % Identify motion
    output_5B = dftregistration(fft2(moving_match),fft2_reference,usfac);
    affine_data(6) = output_5B(3);
    affine_data(3) = output_5B(4);
    motion_5B{i} = affine2d(affine_data);
    
    % Apply motion
    corrected_5B(:,:,i) = imwarp(moving,motion_5B{i},'OutputView',imref2d([y x]));
    
    % Show the state of computation each 10 frames
    if ~mod(i,10)
        t = toc; 
        fprintf('%d/%d, %.1f s\n',i,n_loco,t)
    end
end
t = toc; 
fprintf('%d/%d, %.1f s\n',i,n_loco,t)
%}

%% 6B. Rigid, dftregistration (3.8s - 129 images) - bad
%{
tic
corrected_6B = zeros(y,x,n_loco);
motion_6B = cell(n_loco,1);
usfac = 10;
affine_data = eye(3);
fft2_reference = fft2(reference);
for i = 1:n_loco
    % Image to register
    moving = video(:,:,i);
    moving_match = imhistmatch(moving,reference);
    
    % Identify motion
    output_6B = dftregistration(fft2(moving_match),fft2_reference,usfac);
    affine_data(6) = output_6B(3);
    affine_data(3) = output_6B(4);
    motion_6B{i} = affine2d(affine_data);
    
    % Apply motion
    corrected_6B(:,:,i) = imwarp(moving,motion_6B{i},'OutputView',imref2d([y x]));
    
    % Show the state of computation each 10 frames
    if ~mod(i,10)
        t = toc; 
        fprintf('%d/%d, %.1f s\n',i,n_loco,t)
    end
end
t = toc; 
fprintf('%d/%d, %.1f s\n',i,n_loco,t)
%}

%% 7B. Rigid (157s - 129 images) - bad, still crazi frames
%{
tic
corrected_7B = zeros(y,x,n_loco);
motion_7B = cell(n_loco,1);

[optimizer, metric] = imregconfig('monomodal');
options.optimizer = optimizer;
options.metric = metric;
for i = 1:n_loco
    % Image to register
    moving = video(:,:,i);
    moving_match = imhistmatch(moving,reference);
    
    % Identify motion
    motion_7B{i} = imregtform(moving_match,reference,'similarity',...
        options.optimizer,options.metric,...'DisplayOptimization',true,...
        'pyramidlevels',3);
    
    % Apply motion
    corrected_7B(:,:,i) = imwarp(moving,motion_7B{i},'OutputView',imref2d([y x]));
    
    % Show the state of computation each 10 frames
    if ~mod(i,10)
        t = toc; 
        fprintf('%d/%d, %.1f s\n',i,n_loco,t)
    end
end
t = toc; 
fprintf('%d/%d, %.1f s\n',i,n_loco,t)
%}

%% 8B. Rigid (129s - 129 images) - good, but some intensities are weird
%{
tic
corrected_8B = zeros(y,x,n_loco);
motion_8B = cell(n_loco,1);

[optimizer, metric] = imregconfig('monomodal');
options.optimizer = optimizer;
options.metric = metric;
for i = 1:n_loco
    % Image to register
    moving = video(:,:,i);
    moving_match = imhistmatch(moving,reference);
    
    % Identify motion
    motion_8B{i} = imregtform(moving_match,reference,'affine',...
        options.optimizer,options.metric,...'DisplayOptimization',true,...
        'pyramidlevels',3);
    
    % Apply motion
    corrected_8B(:,:,i) = imwarp(moving,motion_8B{i},'OutputView',imref2d([y x]));
    
    % Show the state of computation each 10 frames
    if ~mod(i,10)
        t = toc; 
        fprintf('%d/%d, %.1f s\n',i,n_loco,t)
    end
end
t = toc; 
fprintf('%d/%d, %.1f s\n',i,n_loco,t)
%}

%% WINNER 9B. Rigid translational (32s - 129 images) - GOOD AND FAST 
% 63s - 258 images
%
tic
corrected_9B = zeros(y,x,n_loco);
motion_9B = cell(n_loco,1);

[optimizer, metric] = imregconfig('monomodal');
options.optimizer = optimizer;
options.metric = metric;
for i = 1:n_loco
    % Image to register
    moving = video(:,:,i);
    moving_match = imhistmatch(moving,reference);
    
    % Identify motion
    motion_9B{i} = imregtform(moving_match,reference,'translation',...
        options.optimizer,options.metric,...'DisplayOptimization',true,...
        'pyramidlevels',3);
    
    % Apply motion
    corrected_9B(:,:,i) = imwarp(moving,motion_9B{i},'OutputView',imref2d([y x]));
    
    % Show the state of computation each 10 frames
    if ~mod(i,10)
        t = toc; 
        fprintf('%d/%d, %.1f s\n',i,n_loco,t)
    end
end
t = toc; 
fprintf('%d/%d, %.1f s\n',i,n_loco,t)

movie_registered = movie_A;
movie_registered(:,:,id_loco) = corrected_9B;
%}






