function correlation = Get_Correlation_Image(image,template)
% Get a cross-correlation image between the input image and the template, considering
% symmetric boundaries. The output image is the same size of the input
% image.
%
% Jesus Perez-Ortega April-19

% Get size of images
[h,w] = size(image);
[h_t,w_t] = size(template);

% Get extra size
extra_h = floor(h_t/2)*2;
extra_w = floor(w_t/2)*2;

% Initialize the new image with symmetric boundaries
new_im = zeros(h+extra_h,w+extra_w);

% Get boundaries
bound_top = flipud(image(1:extra_h/2,:));
bound_bottom = flipud(image(end-extra_h/2+1:end,:));
bound_left = fliplr(image(:,1:extra_w/2));
bound_right = fliplr(image(:,end-extra_w/2+1:end));
bound_tl = rot90(image(1:extra_h/2,1:extra_w/2),2);
bound_tr = rot90(image(1:extra_h/2,end-extra_w/2+1:end),2);
bound_bl = rot90(image(end-extra_h/2+1:end,1:extra_w/2),2);
bound_br = rot90(image(end-extra_h/2+1:end,end-extra_w/2+1:end),2);

% Put image
offset_w = (1:w)+extra_w/2;
offset_h = (1:h)+extra_h/2;
new_im(offset_h,offset_w) = image;

% Put the boundaries
new_im(1:extra_h/2,offset_w) = bound_top;
new_im(end-(extra_h/2)+1:end,offset_w) = bound_bottom;
new_im(offset_h,1:extra_w/2) = bound_left;
new_im(offset_h,end-(extra_w/2)+1:end) = bound_right;
new_im(1:extra_h/2,1:extra_w/2) = bound_tl;
new_im(1:extra_h/2,end-extra_w/2+1:end) = bound_tr;
new_im(end-extra_h/2+1:end,1:extra_w/2) = bound_bl;
new_im(end-extra_h/2+1:end,end-extra_w/2+1:end) = bound_br;

% Compute cross correlation
c = normxcorr2(template,new_im);
correlation = c(extra_h+1:end-extra_h,extra_w+1:end-extra_w); 
