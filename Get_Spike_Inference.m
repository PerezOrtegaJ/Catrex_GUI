function [inference,model] = Get_Spike_Inference(transients,method)
% Get spike inference given a specific method (derivative, oasis or foopsi)
%
%   [inference,model] = Get_Spike_Inference(transients,method)
%
%            default: method = 'foopsi'
%                     method could be 'foopsi', 'oasis' or 'derivative'
%
% By Jesus Perez-Ortega, Nov 2019

if nargin==1
    method = 'foopsi';
end

% Get number of signals
[n,f] = size(transients);
inference = zeros(n,f);
model = zeros(n,f);

switch method
    case 'derivative'
        for i = 1:n
            % Get derivative
            singleInference = [0;diff(transients(i,:))'];

            % Get binary
            inference(i,:) = singleInference;
        end
        model = [];
    case 'oasis'
        tic
        ten_perc = round(n/10);
        for i = 1:n
            % Get oasis model
            [singleModel,singleInference] = oasisAR2(transients(i,:));

            % Get binary from inference
            inference(i,:) = singleInference;
            
            % Get binary from model
            model(i,:) = singleModel;
            
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

            % Get binary from inference
            inference(i,:) = singleInference;
            
            % Get binary from model
            model(i,:) = singleModel;
            
            if ~mod(i,ten_perc)
                t = toc; 
                fprintf('   %d %%, %.1f s\n',round(i/n*100),t)
            end            
        end
end