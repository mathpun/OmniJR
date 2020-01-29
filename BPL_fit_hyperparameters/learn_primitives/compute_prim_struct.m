%% Compute MLE parameters from that clustering
function model = compute_prim_struct(cell_data,cell_scales,cell_labels)

    ps = defaultps_clustering;
    regcov = ps.em.regcov;

    %% vectorize everything
    ncell = numel(cell_labels);
    cell_count = zeros(ncell,1);
    for i=1:ncell
        cell_count(i) = numel(cell_labels{i});
    end    
    data = cell2mat(cell_data);
    scales = cell2mat(cell_scales);
    label = cell2mat(cell_labels);
    invscales = 1./scales;
    
    %% compute table parameters
    uqtable = 1:max(label); %unique(label);
    ntable = numel(uqtable);
    dim = size(data,2);  
    mu = zeros(ntable,dim);
    Sigma = zeros(dim,dim,ntable);
    vthetas = zeros(ntable,2);
    init_mixprob = zeros(ntable,1);
    for i=1:ntable

        sel = label==i;
        nsel = sum(sel);
        
        this_data = data(sel,:);
        this_invscales = invscales(sel,:);
                
        %% case where we don't have enough data
        if nsel <= 1
             mu(i,:) = 0;             
             Sigma(:,:,i) = eye(dim);
             init_mixprob(i) = 0;            
             vthetas(i,:) = [1 1];
             continue;
        end
        
        %% fit Gaussian to shape component
        mu(i,:) = mean(this_data,1);
        vr = var(this_data,0,1);
        Sigma(:,:,i) = diag(vr);
        init_mixprob(i) = sum(sel);
        
        %% Fit Gamma to scale component
        vthetas(i,:) = gamfit(this_invscales);
        
        assert(~any(isnan(vr)));
        
    end
    init_mixprob = init_mixprob ./ sum(init_mixprob);
    
    %% re-classify the data with the new clusters
    new_labels = complex_mix_classify([data invscales],mu,Sigma,regcov,vthetas);
    cell_new_labels = mat2cell(new_labels,cell_count);
    
    % 
    same_label = mean(label == new_labels);
    fprintf(1,'Percent of labels that are the same: %s\n',makestr(same_label*100));
    
    % compute frequency of each cluster
    tableFreq = zeros(ntable,1);
    for i=1:ntable
        tableFreq(i) = sum(new_labels==uqtable(i));
    end
    mixprob = tableFreq ./ sum(tableFreq);

    % group the data by each table
    table_data = cell(ntable,1);
    table_invscales = cell(ntable,1);
    for i=1:ntable
        table_data{i} = data(new_labels==uqtable(i),:); 
        table_invscales{i} = invscales(new_labels==uqtable(i));
    end
    
    %% compute bigram transitions
    start_count = zeros(ntable,1);
    bigrams = zeros(ntable,ntable);
    for i=1:ncell
       seq = cell_new_labels{i}; 
       nsub = length(seq);

       % count the beginning of the stroke
       ifirst = seq(1);
       start_count(ifirst) = start_count(ifirst) + 1;

       % count the transitions
       for b=2:nsub
           iprev = seq(b-1);
           icurr = seq(b);
           bigrams(iprev,icurr) = bigrams(iprev,icurr) + 1;
       end

       % do not count the end transition
    end
    unigrams = sum([start_count'; bigrams],1);
    unigrams = unigrams(:);
    assert(isequal(tableFreq(:),unigrams));
    
    %% sort primitives from most popular to least
    [~,idx] = sort(tableFreq,1,'descend');  
    
    % store all of the structure that we want
    model = struct;
    model.mu = mu(idx,:);
    model.Sigma = Sigma(:,:,idx);
    model.mixprob = mixprob(idx);
    model.theta = vthetas(idx,:);
    model.table_data = table_data(idx);
    model.table_invscales = table_invscales(idx);
    model.tableFreq = unigrams(idx);
    model.bigrams = bigrams(idx,idx);
    model.start_count = start_count(idx);
    
    assert(isequal(model.tableFreq(:),vec(sum([model.start_count(:)'; model.bigrams],1))));    
end