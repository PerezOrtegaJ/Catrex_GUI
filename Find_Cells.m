function xy = Find_Cells(xcorr,th,radius)
% Find cells based on cross-correlation image and threshold. Use radius to
% identify cells smaller than 2.5 times the radius specified.
%
% Jesus Perez-Ortega April-19

switch(nargin)
    case 1
        th = 0.5;
        radius = 0;
    case 2
        radius = 0;
end

% Get mask
mask = xcorr>th;

% Detect centroid and area
s = regionprops(mask,'Centroid','MajorAxisLength');

% Extract properties
n = length(s);
xy = zeros(n,2);
major_length = zeros(n,1);
for i = 1:n
    xy(i,:) = s(i).Centroid;
    major_length(i) = s(i).MajorAxisLength;
end

% Avoid xy in boundaries
[h,w] = size(xcorr);
boundaries_left = find(xy(:,1)==1);
boundaries_rigth = find(xy(:,1)==w);
boundaries_top = find(xy(:,2)==1);
boundaries_bottom = find(xy(:,2)==h);
boundaries = unique([boundaries_left;boundaries_rigth;boundaries_top;boundaries_bottom]);
xy(boundaries,:) = [];
major_length(boundaries) = [];
n = size(xy,1);

if radius
    % Find longer "cells"
    longer = find(major_length>radius*2.5);
    n_longer = length(longer);

    % Set coordinates for cells found
    xy_id = setdiff(1:n,longer);
    xy_1 = xy(xy_id,:);

    if n_longer    
        % Create a mask for longer cells with original image
        image_size = [h w];
        longer_mask = zeros(h,w);
        for i = 1:n_longer
            longer_mask = longer_mask | Circle_Mask(image_size,xy(longer(i),:),radius*2);
        end
        % Get improve image
        image_longer = longer_mask.*xcorr;

        % Get mask
        new_mask = image_longer>th*1.2;

        % Find if still longer
        s_longer = regionprops(new_mask,'Centroid','MajorAxisLength','orientation');

        % Extract properties
        n = length(s_longer);
        xy = zeros(n,2);
        major_length = zeros(n,1);
        orientation = zeros(n,1);
        for i = 1:n
            xy(i,:) = s_longer(i).Centroid;
            major_length(i) = s_longer(i).MajorAxisLength;
            orientation(i) = s_longer(i).Orientation;
        end

        % Find if still longer
        longer = find(major_length>2*radius);
        n_longer = length(longer);

        % New coordinates
        xy_id = setdiff(1:n,longer);
        xy_2 = xy(xy_id,:);

        % If still longer divide in 2
        if(n_longer)
            xy_3 = zeros(n_longer*2,2);
            j=1;
            for i = 1:n_longer
                angle = 360-orientation(longer(i));
                [x,y] = pol2cart(angle*pi/180,radius*3/4);
                xy_3(j,:) = [xy(longer(i),1)+x xy(longer(i),2)+y];
                xy_3(j+1,:) = [xy(longer(i),1)-x xy(longer(i),2)-y];
                j=j+2;
            end
            xy = round([xy_1; xy_2; xy_3]);
        else
            xy = round([xy_1; xy_2]);
        end
    else
        xy = round(xy_1);
    end
end