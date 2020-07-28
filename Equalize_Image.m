function [equalized,min_im,max_im]= Equalize_Image(image,std_or_minmax)
% Equalize 8-bit image rescaling, using LUT or n standard deviations
%
% Jesus Perez-Ortega April-19

if(nargin==1)
    std_or_minmax = 0;
else
    std_or_minmax = double(std_or_minmax);
end

% Get min and max
min_im = min(image(:));
max_im = max(image(:));

% If the image has the same min and max value
if min_im == max_im
    equalized = image;
    return
end

% Identify the class of the image
if isa(image,'uint8')
    max_value = 2^8-1;
    depth = 8;
elseif isa(image,'uint16')
    max_value = 2^16-1;
    depth = 16;
else
    max_value = 2^32-1;
    depth = 32;
end

% Change class to double
image = double(image);
min_im = double(min_im);
max_im = double(max_im);

% Initialize variable
adjust_image = false;

% Get min and max from input argument
if length(std_or_minmax)==2
    set_min = std_or_minmax(1);
    set_max = std_or_minmax(2);
    
    % Activate flag to adjust image
    adjust_image = true;
else
    % Get min and max from standard deviations
    if std_or_minmax
        % Get min and max
        set_min = round(mean(image(:))-std_or_minmax*std(image(:)));
        set_max = round(mean(image(:))+std_or_minmax*std(image(:)));

        % Compare if min and max are out of the current range
        if set_min<min_im
            set_min = min_im;
        end
        if set_max>max_im
            set_max = max_im;
        end

        % Activate flag to adjust image
        adjust_image = true;
    end
end

if adjust_image
    % Adjust image by LUT
    switch(depth)
        case 8
            equalized = imadjust(uint8(image),[set_min set_max]/max_value,[],1);
        case 16
            equalized = imadjust(uint16(image),[set_min set_max]/max_value,[],1);
        case 32
            equalized = imadjust(uint32(image),[set_min set_max]/max_value,[],1);
    end
else
    % Rescale the values of the image
    equalized = rescale(image,0,max_value);
    switch(depth)
        case 8
            equalized = uint8(equalized);
        case 16
            equalized = uint16(equalized);
        case 32
            equalized = uint32(equalized);
    end
end