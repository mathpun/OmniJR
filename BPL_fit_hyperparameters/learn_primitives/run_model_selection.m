%
% Input
%  nval: number of data points to use, where more
%    leads to a more accurate estimate
%
%
function run_model_selection(nval)

    % FILE NAME where models are stored
    load('fit_EM_models_june6','cell_prms');
    
    ps = defaultps_clustering();
    nn = numel(cell_prms);
    ncat = zeros(nn,1);
    for i=1:nn
       ncat(i) = size(cell_prms{i}.mu,1); 
    end    

    % Load validation data
    load('init_val','cell_data','cell_scales')
    val_cell_data = cell_data;
    val_cell_scales = cell_scales;
    clear cell_data cell_scales
    nt = numel(val_cell_data);
    perm = randperm(nt);
    sel = perm(1:nval);
    val_cell_data = val_cell_data(sel);
    val_cell_scales = val_cell_scales(sel);
    
    % Load training data
    load('init_fit','cell_data','cell_scales');
    full_train_cell_data = cell_data;
    full_train_cell_scales = cell_scales;
    clear cell_data cell_scales
    nt = numel(full_train_cell_data);
    perm = randperm(nt);
    sel = perm(1:nval);
    train_cell_data = full_train_cell_data(sel);
    train_cell_scales = full_train_cell_scales(sel);
    
    % Contruct the various models
    regcov = ps.em.regcov;
    int_reg_count = ps.em.int_reg_count;
    m = numel(cell_prms);
    R = numel(int_reg_count);
    cellHMM = cell(m,R);
    cellGMM = cell(m,1);
    for i=1:m
        prims = cell_prms{i};
        % Learn GMMs
        cellGMM{i} = GMM(prims.mu,prims.Sigma,prims.mixprob,prims.theta);        
        cellGMM{i}.smooth_Sigma = regcov;   
        
        for j=1:R           
           % Learn HMMs
           cellHMM{i,j} = GHMM(prims.mu,prims.Sigma,prims.bigrams,prims.start_count,prims.theta);
           cellHMM{i,j}.smooth_bigrams = int_reg_count(j);
           cellHMM{i,j}.smooth_Sigma = regcov;            
        end
    end
    
    score_hmm_val = zeros(m,R);
    score_gmm_val = zeros(m,1);
    score_gmm_train = zeros(m,1);
    
    % Select the best HMM regularization based on validation performance
    for i=1:numel(cellHMM) 
        M = cellHMM{i};
        score_hmm_val(i) = M.prob_observations(val_cell_data,val_cell_scales)./nval;
    end
    [vscore_hmm_val,vHMM] = choose_best_reg(cellHMM,score_hmm_val);
    vscore_hmm_train = zeros(m,1);
    for i=1:m
       vscore_hmm_train(i) = vHMM{i}.prob_observations(train_cell_data,train_cell_scales)./nval; 
    end
    
    % Compute score for each GMM model
    for i=1:numel(cellGMM)       
        M = cellGMM{i};
        score_gmm_val(i) = M.prob_observations(val_cell_data,val_cell_scales)./nval;
        score_gmm_train(i) = M.prob_observations(train_cell_data,train_cell_scales)./nval;
    end
    %save('temp');
    
    % Plot the results
    figure(1)
    clf
    hold on
    plot(ncat,vscore_hmm_train,'rx-');
    plot(ncat,vscore_hmm_val,'ro--');
    plot(ncat,score_gmm_train,'bx-');
    plot(ncat,score_gmm_val,'bo--');
    xlabel('number of categories');
    ylabel('log-score per sequence');
    title('Predictive performance');
    legend({'HMM train','HMM test','GMM train','GMM test'});
    
    fprintf(1,'Best HMM model\n');
    [best_hmm_score,windx_hmm] = max(vscore_hmm_val);
    bestHMM = vHMM{windx_hmm};
    fprintf(1,'  score = %s\n',num2str(best_hmm_score,6));
    fprintf(1,'  primitives = %d\n',bestHMM.nclass);
    fprintf(1,'  regularization = %s\n',num2str(bestHMM.smooth_bigrams,3));
    
    fprintf(1,'\n\nBest GMM model\n');
    [best_gmm_score,windx_gmm] = max(score_gmm_val);
    bestGMM = cellGMM{windx_gmm};
    fprintf(1,'  score = %s\n',num2str(best_gmm_score,6));
    fprintf(1,'  primitives = %d\n',bestGMM.nclass);
    
    save('primitive_model_june6','bestHMM','bestGMM','vHMM','cellGMM','val_cell_data','train_cell_data');
    
end

%
% For each model, choose the best regularization parameter
%
% where regularization changes by column
%
% Input
%  cellM: matrix of models
%  scoreM: score of each model
function [vscore,vM] = choose_best_reg(cellM,scoreM)
    [nrow ncol] = size(cellM);    
    vM = cell(nrow,1);
    vscore = zeros(nrow,1);
    for r=1:nrow
       srow = scoreM(r,:);
       [myscore,windx] = max(srow);
       
       % select the best model
       vM{r} = cellM{r,windx};
       vscore(r) = myscore;
    end
end