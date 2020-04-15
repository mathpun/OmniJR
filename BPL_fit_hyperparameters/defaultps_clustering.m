%
% Default parameters for learning a library of the model
%
function ps = defaultps_clustering()

    ps = struct;

    % FOR CLUSTERING
    
    % General
    ps.ncpt = 5; % number of control points to fit each sub-stroke
    ps.max_ns = 10; % maximum number of strokes we want to model
    ps.max_nsub = 10; % maximum number of sub-strokes per stroke

    % FOR LEARNING TOKEN VARIANCE MODEL
    ps.tvar.min_inv_scale = 0.02; % sub-strokes smaller than this are not considered a match 
    ps.outlier_thresh_sd = 3; % how many standard deviations away from the mean until
        % you are considered an outlier?
    ps.kmatch = 5; % soft-matching function for sub-strokes
    ps.tokenvar_shape_sd = 3; % token-variability of the stroke shape    
    
    % FOR LEARNING PRIMITIVES
    ps.newscale_ss = 105; % Canonical scale for all sub-strokes, when
                       % fitting the clustering model. This is the range of
                       % the longest dimension (x or y)
    ps.minlen_ss = 10; % ncpt; before.. % minimum length of a sub-stroke, otherwise removed
    ps.minsize_table = 5; % minimum size of a cluster to include it  
    ps.em.regcov = (ps.tokenvar_shape_sd)^2; % regularization parameter added to covariance in clustering
    ps.em.replicates = 3; % number of times to run EM with different random starts
    ps.em.int_nclust = 350; % [1000 1250 1500 2000 2500];  number of primitives to consider
    ps.em.rep_invscale = 2; % number of times we should replicate the scale dimension
    ps.em.int_reg_count = [.01 .1 1]; % additive counts when learning a transition matrix    
    
    % FOR LEARNING SCALE MODEL
    ps.scale.min_inv_scale = 0.02; % remove all sub-strokes smaller than this when model fitting
    ps.scale.int_min_group = 1:2:40; % try these values of cutoff between global/specific models
    
    % FOR POSITION MODEL    
    ps.pos.int_nbin = [5 10 15 20 25 30]; % number of bins to try
    ps.pos.int_count = [0.5 1 2 4]; % prior count to try
    ps.pos.int_clump = 1:6; % number of different position models
    ps.pos.xlim = [0 105];  % region in which positions fall into
    ps.pos.ylim = [-105 0];
    
    % FOR OVERLAP MODEL
    ps.overlap.ink_threshold = 0.02; % "ink overlap" scores below this are treated as essentially 0, or no overlap
                                     % roughly based on "estimate_minimal_overlap.m" function                                  
end