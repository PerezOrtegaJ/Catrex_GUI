function colors = Orientation_Colors
% Get 8 different colors
%
%       colors = Get_Orientation_Colors
%
% By Jesus Perez-Ortega, July 2019

colors_HSV = [0.0 0.5 0.9;...   % red
              0.2 0.5 0.9;...   % yellow
              0.4 0.5 0.9;...   % green
              0.6 0.5 0.9;...   % blue
              0.0 0.2 0.9;...   % red light
              0.2 0.2 0.9;...   % yellow light
              0.4 0.2 0.9;...   % green light
              0.6 0.2 0.9];     % blue light
colors = hsv2rgb(colors_HSV);
