% Cluster the sub-strokes (in control point space)
% into "nclust" clusters using EM
%
% Input
%   nclust: number of clusters that we want
%   cell_data : [n x 1 cell]  data points in some clustering structure
%   data : [N x dim] rows are data points (optional)
%
%   If data is not provided, we flatten the cell_data structure.
%   Also, this allows us to pass in different "data" if desired...
%   Like we want to fit the model to fewer points
%
% Output
%   cell_label: [n x 1 cell] cluster label for each data point provided
%
function [cell_label,gm] = cluster_data(nclust,cell_data,data)

    % flatten data, if it is not already provided
    if ~exist('data','var')
        data = [];
        for i=1:numel(cell_data)
           data = [data; cell_data{i}]; 
        end        
    end
    
    ps = defaultps_clustering;    
    options = statset('Display','iter',...
                      'UseParallel',true,...
                      'MaxIter',350);
                  
    gm = gmdistribution.fit(...
        data,nclust,...
        'CovType','diagonal',...
        'Regularize',ps.em.regcov,...
        'Replicates',ps.em.replicates,...
        'Options',options);    
    
    % cluster the datapoints according to the gaussian mixture model
    n = numel(cell_data);
    list_sz = zeros(n,1);
    for i=1:n
       list_sz(i) = size(cell_data{i},1); 
    end
    vdata = cell2mat(cell_data);
    vlabels = cluster(gm,vdata);
    cell_label = mat2cell(vlabels,list_sz);
    
end