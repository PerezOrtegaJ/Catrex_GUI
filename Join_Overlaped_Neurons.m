function neuronalData = Join_Overlaped_Neurons(neuronalData,fraction,width,height)
% Join neurons overlaped above 50%
%
%       neuronalData = Join_Overlaped_Neurons(neuronalData,fraction,width,height)
%
% By Jesus Perez-Ortega, Sep 2019

% Get overlaped fraction between each pair of neurons
idPot = find([neuronalData.overlap_fraction]>=fraction);
nPot = numel(idPot);
sim = zeros(nPot);
for a = 1:nPot-1
    for b = a+1:nPot
        [~,jA,jB] = Jaccard_Index(neuronalData(idPot(a)).pixels,neuronalData(idPot(b)).pixels);
        sim(a,b) = max([jA jB]);
    end
end

% Get similarity between cells above fraction of pixels given
sim = sim>=fraction;

% Join neurons
k = 1;
idsRemove = [];
for i = 1:nPot-1
    idJoin = find(sim(i,:));
    nJoins = numel(idJoin);
    if nJoins
        neuronJoined(k) = Join_Neurons(neuronalData(idPot(i)),neuronalData(idPot(idJoin(1))),height,width);
        if nJoins>1
            for j = 2:nJoins
                neuronJoined(k) = Join_Neurons(neuronJoined(k),neuronalData(idPot(idJoin(j))),height,width);
            end
        end
        k = k+1;
        idsRemove = unique([idsRemove idPot(i) idPot(idJoin)]);
    end
end

if k>1
    % Get eccentricity
    neuronJoined = Get_Eccentricity(neuronJoined,width,height);
    nNew = numel(neuronJoined);
    neuronalData(numel(neuronalData)+(1:nNew)) = neuronJoined;
    neuronalData(idsRemove) = [];
end