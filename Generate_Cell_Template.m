function template = Generate_Cell_Template(radius)
% Generate templates for cell pattern recognition
%
% Jesus Perez-Ortega April-19

% Generate disk by structure element
se = strel('disk',radius,0);
disk_bin = se.Neighborhood;

% Add disk in a blak square
pre_template = zeros(4*radius+1);
offset = (1:length(disk_bin))+radius;
pre_template(offset,offset) = disk_bin;

% Apply gaussian filter
template = imgaussfilt(pre_template,1);