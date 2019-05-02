%% Add ROIs
function xy_updated = Add_ROIs(xy,xy_new,radius)

% Add new coordinates
xy_updated = [xy; xy_new];
n = size(xy_updated,1);

% Get the distance between coordinates
distance = squareform(pdist(xy_updated))+eye(n)*radius;

% find wheter distance is less than radius
[x,y] = find(distance<radius);

if ~isempty(x)
    keep = setdiff(1:n,max([x y]'));
    xy_updated = xy_updated(keep,:);
end

% reorder
[~,id_1] = sort(xy_updated(:,1));
[~,id_2] = sort(xy_updated(id_1,2));
xy_updated = xy_updated(id_1(id_2),:);
