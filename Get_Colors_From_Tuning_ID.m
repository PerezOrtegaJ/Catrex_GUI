function colors = Get_Colors_From_Tuning_ID(tuning_id)
% Get the color of each cell from its tunning id
%
%       colors = Get_Colors_From_Tuning_ID(tuning_id)
%
% By Jesus Perez-Ortega, August 2019
% Modified Oct 2019

% orientation colors
colors_HSV = [0.0 0.5 0.9;... 
              0.2 0.5 0.9;... 
              0.4 0.5 0.9;... 
              0.6 0.5 0.9;...
              0.0 0.2 0.9;...
              0.2 0.2 0.9;... 
              0.4 0.2 0.9;... 
              0.6 0.2 0.9];
colors_RGB = hsv2rgb(colors_HSV);

% Get colors
n = length(tuning_id);
colors = zeros(n,3);
for i = 1:n
    if tuning_id(i)>0
        % tuned neurons
        colors(i,:) = colors_RGB(tuning_id(i),:);
    else
        % non tuned neurons
        switch tuning_id(i)
            case 0    
                colors(i,:) = [0.8 0.8 0.8];
            case -1
                colors(i,:) = [0.95 0.5 0.95];    % magenta
            case -2
                colors(i,:) = [1.0 0.75 0.5];    % orange
        end
    end
end