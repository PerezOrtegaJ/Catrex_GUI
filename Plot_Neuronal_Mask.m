function Plot_Neuronal_Mask(neurons,x,y,name)
% Plot a mask for neurons
%
%       Plot_Neuronal_Mask(neurons,x,y,name)
%
% By Jesus Perez-Ortega, July 2019

% get mask
mask = Get_ROIs_Image(neurons,x,y);

% Plot mask
Set_Figure([name ' - Mask'],[0 0 600 600])
imshow(mask,'InitialMagnification','fit')
title(strrep([name '-mask'],'_','-'))