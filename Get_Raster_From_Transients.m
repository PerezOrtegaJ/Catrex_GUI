function raster = Get_Raster_From_Transients(transients,std_times,method)
% Get raster from transients by using the first derivative given a
% threshold by a given number of standard deviations
%
%   raster = Get_Raster_From_Transients(transients,std_times,method)
%
%            default: std_times = 2 and method = 'foopsi'
%
% Jesus Perez-Ortega April-19
% Modified May 2019

switch nargin 
    case 1
        std_times = 2;
        method = 'foopsi';
    case 2
        method = 'foopsi';
end

% Get number of signals
[n,f] = size(transients);
raster = zeros(n,f);

switch method
    case 'derivative'
        for i = 1:n
            % Get derivative
            inference = [0;diff(transients(i,:))'];
            th = std_times*std(inference);

            % Get binary
            raster(i,inference>th) = 1;
        end
    case 'oasis'
        for i = 1:n
            % Get derivative
            inference = oasisAR2(transients(i,:));
            th = std_times*std(inference);

            % Get binary
            raster(i,inference>th) = 1;
        end
    case 'foopsi'
        for i = 1:n
            % Get derivative
            inference = foopsi_oasisAR2(transients(i,:),[],[],true,true);
            th = std_times*std(inference);

            % Get binary
            raster(i,inference>th) = 1;
        end
end