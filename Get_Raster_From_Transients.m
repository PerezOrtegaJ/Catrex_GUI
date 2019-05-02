function raster = Get_Raster_From_Transients(transients,std_times)
% Get raster from transients by using the first derivative given a
% threshold by a given number of standard deviations
%
%   raster = Get_Raster_From_Transients(transients,std_times)
%
% Jesus Perez-Ortega April-19

if nargin == 1
    std_times = 2.5;
end

% Get number of signals
[n,f] = size(transients);
raster = zeros(n,f);
for i = 1:n
    % Get derivative
    derivative = smooth(diff(transients(i,:)))';
    th = std_times*std(derivative);

    % Get binary
    raster(i,derivative>th) = 1;
end