sca


% Network attack

[table_a,table_b,id_a,id_b] = Get_Intersected_Data(data_GC05_M1123_20190712_A,...
    data_GC05_M1123_20190712_B,'tuned','raster','single');
n = length(id_a);
[~,id] = sort([data_GC05_M1123_20190712_A.Neurons(id_a).SortingID]);

raster_a = data_GC05_M1123_20190712_A.Transients.Raster(id_a,:);
raster_a = raster_a(id,:);


% get colors
tuning_a = [data_GC05_M1123_20190712_A.Neurons(id_a).TuningID];
tuning_a = tuning_a(id);
colors_a = Get_Colors_From_Tuning_ID(tuning_a);



net_a = Get_Significant_Network_From_Raster(raster_a);

% betweenness
DC = rescale(sum(net_a));
CC = betweenness_bin(net_a);
EC = eigenvector_centrality_und(double(net_a));
PC = pagerank_centrality(net_a,0.85);
[KC,kn] = kcoreness_centrality_bu(net_a);

[~,cc_id] = sort(CC,'descend');
[~,dc_id] = sort(DC.*CC,'descend');
[~,ec_id] = sort(EC,'descend');
[~,pc_id] = sort(PC,'descend');
[~,kc_id] = sort(KC,'descend');




[l,e,c,comps,indices] = Network_Resilience(net_a,'attack');
[l_e,e_e,c_e,comps_e,indices_e] = Network_Resilience(net_a,'error');
[l_b,e_b,c_b,comps_b,indices_b] = Network_Resilience(net_a,'custom',kc_id);

% Plot measures
Set_Figure('resilience - error',[0 0 500 600])
subplot(4,1,1)
plot(l_e); hold on
plot(l)
plot(l_b)
legend({'random','degree','betweenness'})
title('L')
subplot(4,1,2)
plot(e_e); hold on 
plot(e)
plot(e_b)
title('E')
subplot(4,1,3)
plot(c_e); hold on
plot(c)
plot(c_b)
title('C')
subplot(4,1,4)
plot(comps_e); hold on
plot(comps)
plot(comps_b)
title('Components')
xlabel('neurons removed')
Save_Figure('Resilience')

Plot_Degree_Distribution(net_a,'visual');
Plot_Hierarchy(net_a,'visual');
Plot_Small_World(net_a)

[~,modularity] =modularity_und(net_rand);

net_rand = makerandCIJ_und(68,634);


% plot degree distribution
figure;histogram(sum(net_a))
title('degree distribution')
xlabel('k')
ylabel('P(k)')


links = sum(net_a);

% Plot network
Set_Figure('network',[0 0 1000 500])
subplot(1,2,1)
imagesc(net_a)
colormap([1 1 1;0 0 0])
pbaspect([1 1 1])
axis off
subplot(1,2,2)
Plot_Network(net_a,'undirected','force',colors_a);
Save_Figure('network')
