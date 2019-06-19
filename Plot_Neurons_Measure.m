function Plot_Neurons_Measure(data,name)
% Plot measure for neurons in vertical manner
%
%       Plot_Neurons_Measure(data,name)
%
% By Jesus Perez-Ortega, June 2019

Set_Figure(name,[0 0 100 400]);
plot(data,'.-k')
view([90 -90]);xlim([1 length(data)])
ylabel(name)