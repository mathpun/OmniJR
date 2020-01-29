%
% Fit GMM with different numbers of clusters, which
% we will choose using cross-validation.
%
load('init_fit','cell_data','data','cell_scales','scales');

%% append pixel range to stroke shape
ps = defaultps_clustering;
vranges = convert_scale_to_range(scales,ps);
cell_ranges = apply_to_nested(cell_scales,@(x)convert_scale_to_range(x,ps));
fappend = @(x,y) [x repmat(y,[1 ps.em.rep_invscale]) ];
cell_X = multi_apply_to_nested(fappend,cell_data,cell_ranges);
X = fappend(data,vranges);

%% Compute the clustering
int_nclust = ps.em.int_nclust;
nint = numel(int_nclust);
store_labels = cell(nint,1);
store_gm = cell(nint,1);
for iter = 1:nint
    fn = makestr('iter',iter);
    nclust = int_nclust(iter);
    [store_labels{iter},store_gm{iter}] = cluster_data(nclust,cell_X,X);
end

%% Compute MLE parameters from that clustering
cell_prms = cell(nint,1);
for iter=1:nint
    cell_labels = store_labels{iter};
    cell_prms{iter} = compute_prim_struct(cell_data,cell_scales,cell_labels); 
end

%%
save('fit_EM_models_june6','cell_prms','store_labels');