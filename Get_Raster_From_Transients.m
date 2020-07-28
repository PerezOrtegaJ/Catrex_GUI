function [raster,inference,inferenceTh,model,modelTh] = Get_Raster_From_Transients(transients,stdTimes,method)
% Get raster from transients by using the first derivative given a
% threshold by a given number of standard deviations
%
%   [raster,inference,inferenceTh,model,modelTh] = Get_Raster_From_Transients(transients,stdTimes,method)
%
%            default: std_times = 2 and method = 'foopsi'
%                     method could be 'foopsi', 'oasis' or 'derivative'
%
% Jesus Perez-Ortega, April 2019
% Modified Aug 2019
% Modified Sep 2019

switch nargin 
    case 1
        stdTimes = 2;
        method = 'foopsi';
    case 2
        method = 'foopsi';
end

% Get number of signals
[n,f] = size(transients);
raster = zeros(n,f);
inference = zeros(n,f);
inferenceTh = zeros(n,f);
model = zeros(n,f);
modelTh = zeros(n,f);

switch method
    case 'derivative'
        for i = 1:n
            % Get derivative
            singleInference = [0;diff(transients(i,:))'];
            th = stdTimes*std(singleInference);

            % Get binary
            raster(i,singleInference>th) = 1;
            inference(i,:) = singleInference;
            inferenceTh(i,singleInference>th) = singleInference(singleInference>th);
        end
        model = [];
        modelTh = [];
    case 'oasis'
        tic
        ten_perc = round(n/10);
        for i = 1:n
            % Get oasis model
            [singleModel,singleInference] = oasisAR2(transients(i,:));

            % Get binary from inference
            th = stdTimes*std(singleInference);
            raster(i,singleInference>th) = 1;
            inference(i,:) = singleInference;
            inferenceTh(i,singleInference>th) = singleInference(singleInference>th);
            
            % Get binary from model
            th = stdTimes*std(singleModel);
            model(i,:) = singleModel;
            modelTh(i,singleModel>th) = singleModel(singleModel>th);
            
            if ~mod(i,ten_perc)
                t = toc; 
                fprintf('   %d %%, %.1f s\n',round(i/n*100),t)
            end   
        end
    case 'foopsi'
        tic
        ten_perc = round(n/10);
        for i = 1:n
            % Get foopsi model
            [singleModel,singleInference] = foopsi_oasisAR2(transients(i,:),[],[],true,true);
            th = stdTimes*std(singleInference);

            % Get binary from inference
            raster(i,singleInference>th) = 1;
            inference(i,:) = singleInference;
            inferenceTh(i,singleInference>th) = singleInference(singleInference>th);
            
            % Get binary from model
            th = stdTimes*std(singleModel);
            model(i,:) = singleModel;
            modelTh(i,singleModel>th) = singleModel(singleModel>th);
            
            if ~mod(i,ten_perc)
                t = toc; 
                fprintf('   %d %%, %.1f s\n',round(i/n*100),t)
            end            
        end
end