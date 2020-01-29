%
% Seach over position model parameters using cross-validation:
%  1) number of bins in histogram
%  2) prior counts in each bin
%  3) number of different position models (clump at index)
%
%  Evaluate and choose the best on the held-out data
%
%
% Input
%   train_start: [n x 2] training positions
%   train_id: [n x 1] order of stroke in sequence
%   test_start: [m x 2] test positions
%   test_id: [m x 1] order of stroke in sequence
%
%
function bestM = model_selection_position(train_start,train_id,test_start,test_id,xlim,ylim)

    % Load training data
    ps = defaultps_clustering;
    if ~exist('xlim','var')
       xlim = ps.pos.xlim;
    end
    if ~exist('ylim','var')
       ylim = ps.pos.ylim;
    end
    
    eval_model = @(nbin_per_side,prior_count,begin_clump) SpatialModel(train_start,train_id,begin_clump,...
        xlim,ylim,...
        nbin_per_side,prior_count);
    int_nbin = ps.pos.int_nbin;
    int_count = ps.pos.int_count;
    int_clump = ps.pos.int_clump;

    % train the models
    n_nbin = numel(int_nbin);
    n_count = numel(int_count);
    n_clump = numel(int_clump);
    M = cell(n_nbin,n_count,n_clump);
    store_nbin = zeros(n_nbin,n_count,n_clump);
    store_count = zeros(n_nbin,n_count,n_clump);
    store_clump = zeros(n_nbin,n_count,n_clump);
    for i=1:n_nbin
        for j=1:n_count
            for k=1:n_clump
                nbin = int_nbin(i);
                count = int_count(j);
                clump = int_clump(k);

                M{i,j,k} = eval_model(nbin,count,clump);
                store_nbin(i,j,k) = nbin;
                store_count(i,j,k) = count;
                store_clump(i,j,k) = clump;
            end
        end
    end

    % Load the validation data
    [test_start,rmv] = trim_position_data(test_start,xlim,ylim);
    test_id(rmv) = [];

    scores = zeros(size(M));
    N = numel(scores);
    for i=1:N
       % fprintf(1,'eval %d of %d\n',i,N);
       scores(i) = M{i}.score(test_start,test_id);
    end

    windx = argmax(scores);
    best_nbin = store_nbin(windx);
    best_count = store_count(windx);
    best_clump = store_clump(windx);

    fprintf(1,'\nChosen parameters\n');
    fprintf(1,'  number of bins: %d\n',best_nbin);
    fprintf(1,'  additive count: %d\n',best_count);
    fprintf(1,'  clump at: %d\n',best_clump);

    % visualization of score surface
    figure
    Z = scores(:,:,int_clump==best_clump);
    if size(Z,1) > 1 && size(Z,2) > 1 
        subplot(2,1,1);
        mesh(int_count,int_nbin,Z);
        xlabel('added count');
        ylabel('number of bins');
        zlabel('predictive log-like');
    end
    
    [bin_indx,count_indx,clump_indx] = ind2sub([n_nbin,n_count,n_clump],windx);
    subplot(2,1,2);
    v = scores(bin_indx,count_indx,:);
    v = v(:);
    plot(int_clump,v,'r-x');
    xlabel('clump begins at');
    ylabel('predictive log-like');
    
    % Plot what the learned model looks like
    bestM = M{windx};
    bestM.plot();

end