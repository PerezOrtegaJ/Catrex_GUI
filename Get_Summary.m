function [im_std,im_avg,im_min,im_max,im_max_diff] = Get_Summary(movie)
% Get the summary image (standard deviation) from video
% Video variable shoulb be heigh x width x frames
%
% Jesus Perez-Ortega March-19

% Get the size of the video
[h,w,n] = size(movie);

% Get class
if isa(movie,'uint8')
    bit_8 = true;
else
    bit_8 = false;
end

% Avergae of the frames
im_avg = zeros(h,w);
im_min_comp = zeros(h,w);
im_max_comp = zeros(h,w);

for i = 1:n
    frame = movie(:,:,i);
    im_avg = im_avg+double(frame);
    comp(1,:,:) = frame;
    
    % Get minimum
    comp(2,:,:) = im_min_comp;
    im_min_comp = min(comp);
    
    % Get maximum
    comp(2,:,:) = im_max_comp;
    im_max_comp = max(comp);
end
im_avg = im_avg/n;
im_min(:,:) = im_min_comp(1,:,:);
im_max(:,:) = im_max_comp(1,:,:);

% std of the frames
im_std = zeros(h,w);
max_diff = zeros(h,w);
for i = 1:n
    diff_mean = double(movie(:,:,i))-im_avg;
    im_std = im_std+(diff_mean).^2;
    comp_diff(1,:,:) = max_diff;
    comp_diff(2,:,:) = diff_mean;
    max_diff = max(comp_diff);
end
im_max_diff(:,:) = max_diff(1,:,:);

% Adjust images
if bit_8
    im_std = Equalize_Image(uint8(sqrt(im_std/(n-1))));
    im_avg = Equalize_Image(uint8(im_avg));
    im_min = Equalize_Image(uint8(im_min));
    im_max = Equalize_Image(uint8(im_max));
    im_max_diff = Equalize_Image(uint8(im_max_diff));
else
    im_std = Equalize_Image(uint16(sqrt(im_std/(n-1))));
    im_avg = Equalize_Image(uint16(im_avg));
    im_min = Equalize_Image(uint16(im_min));
    im_max = Equalize_Image(uint16(im_max));
    im_max_diff = Equalize_Image(uint16(im_max_diff));
end