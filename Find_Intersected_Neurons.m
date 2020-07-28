function [id_a,id_b] = Find_Intersected_Neurons(neurons_a,neurons_b,width,height,cell_radius)
% Find intersected neurons given two sets of neurons
%
%       [id_a,id_b] = Find_Intersected_Neurons(neurons_A,neurons_B,width,height,cell_radius)
%
% By Jesus Perez-Ortega, July 2019

if isempty(neurons_a) ||  isempty(neurons_b)
    id_a = [];
    id_b = [];
    return
end

% Get mask of each set of neurons
mask_A = rgb2gray(Get_ROIs_Image(neurons_a,width,height));
mask_B = rgb2gray(Get_ROIs_Image(neurons_b,width,height));


% Identify traslation of coordinates
%{
[optimizer, metric] = imregconfig('monomodal');
options.optimizer = optimizer;
options.metric = metric;
motion=imregtform(mask_B,mask_A,'translation',options.optimizer,options.metric,...
        'pyramidlevels',3);
if motion.T(3)>1 || motion.T(6)>1
    mask_B = imwarp(mask_B,motion,'OutputView',imref2d(height,width));
end
%}

% Detect same active neurons
same = regionprops((mask_A>0)&(mask_B>0),'centroid','area');
min_area = cell_radius^2;
id = [same.Area]<min_area;
same(id)=[];
xy_same = [same.Centroid];
xy_same = reshape(xy_same,2,[]);

% Find neurons in A
xy_A=[neurons_a.x_median;neurons_a.y_median];
da = squareform(pdist([xy_same xy_A]','euclidean'));
[~,id_a] = min(da(1:length(same),length(same)+1:end),[],2);

% Find neurons in B
xy_B=[neurons_b.x_median;neurons_b.y_median];
db = squareform(pdist([xy_same xy_B]','euclidean'));
[~,id_b] = min(db(1:length(same),length(same)+1:end),[],2);
