function Test_Cells_Radius(image,radiuses)
% Plot cross correlation between image and as many raiuses defined of 
% Gaussian template
%
%
% By Jesus Perez-Ortega, Oct 2019

n = length(radiuses);
columns = min([6 n]);
rows = ceil(n/columns);

Set_Figure('Correlation')
for i= 1:n
    radius = radiuses(i);
    template = Generate_Cell_Template(radius);
    xcorr = Get_Correlation_Image(image,template);
    subplot(rows,columns,i)
    imshow(rescale(xcorr))
    title(['radius ' num2str(radius)])
end