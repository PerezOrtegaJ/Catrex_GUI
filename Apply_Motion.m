function mov = Apply_Motion(mov,motion,mode)
% Apply a given motion to a video
%
%       mov = Apply_Motion(mov,motion,mode)
%
%       default: mode = 'rigid' (it also could be 'nonrigid')
%
% By Jesus Perez-Ortega, Dec 2019


if nargin==2
    rigid = true;
elseif nargin==3
    switch mode
        case 'rigid'
            rigid = true;
        case 'nonrigid'
            rigid = false;
    end
end

% Get size
[y,x,frames] = size(mov);

% Apply motion
tic
if frames>1
    disp('Applying motion...')
end
ten_perc = round(frames/10);
for i = 1:frames
    if rigid
        mov(:,:,i) = imwarp(mov(:,:,i),motion,'OutputView',imref2d([y x]));
    else
        mov(:,:,i) = imwarp(mov(:,:,i),motion,'nearest');
    end
    if ~mod(i,ten_perc)
        t = toc; 
        fprintf('   %d %%, %.1f s\n',round(i/frames*100),t)
    end
end
if frames>1
    disp('   Done')
end