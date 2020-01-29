%% Pre-process the dataset for clustering
load('background_fit','D');
[cell_data,data,cell_scales,scales] = process_for_clustering(D.drawings);
save('init_fit','cell_data','data','cell_scales','scales');

%% Pre-process the validation set
load('background_val','D');
[cell_data,data,cell_scales,scales] = process_for_clustering(D.drawings);
save('init_val','cell_data','data','cell_scales','scales');