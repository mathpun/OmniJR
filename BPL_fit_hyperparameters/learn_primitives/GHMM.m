classdef GHMM < BetterHandle
    % GHMM Hidden Markov Model with Gaussian observation 
    %  distribution for shape, and Gamma observation
    %  for scale
    %
    % m - states
    %
    % Smoothing parameters
    properties
        smooth_bigrams=0;
        smooth_Sigma=0;
        start_count % prob. of beginning in each of the m states
    end
    
    properties (SetAccess = private)
        mu 
        RawSigma
        vsd
        bigrams % transition model between the m states
        theta % scale model
    end   
    
    properties (Dependent = true)
       Covs 
       logTmat 
       logStart
       nclass
       dim
    end      
    
    methods         
        
        %
        %  Object constructor.
        %
        %  mu: [m x dim] category means
        %  RawSigma: [dim x dim x m] Covariance matrix
        %  bigrams: [m x m] transition counts between categories
        %  start_count: [m x 1] start distribution
        %
        function this = GHMM(mu,RawSigma,bigrams,start_count,theta)
           this.mu = mu;
           this.RawSigma = RawSigma;
           this.bigrams = bigrams;
           this.start_count = start_count;
           this.theta = theta;
           
           vsd = zeros(this.nclass,this.dim);
           for i=1:this.nclass
              dg = diag(RawSigma(:,:,i));
              vsd(i,:) = sqrt(dg);               
           end
           this.vsd = vsd;
           
        end
        
        function m = get.nclass(this)
            m = size(this.mu,1);            
        end
        
        function mydim = get.dim(this)
           mydim = size(this.mu,2); 
        end
        
        function C = get.Covs(this)
            E = eye(this.dim);
            E = E * this.smooth_Sigma;
            RE = repmat(E,[1 1 this.nclass]);
            C = this.RawSigma + RE;
        end
        
        function logB = get.logTmat(this)
            B = this.bigrams + this.smooth_bigrams;      
            mp1 = size(B,2);
            rsum = sum(B,2);
            rsum = rsum(:);
            dv = repmat(rsum,[1 mp1]); 
            B = B ./ dv;
            logB = log(B);
        end
        
        function logp = get.logStart(this)
            p = this.start_count;
            p = p ./ sum(p);
            logp = log(p(:));
        end
               
        % Input
        %  cell_data: [nseq x 1 cell] set of sequences, each of which 
        %    is [T x dim] where rows are observations
        %
        %  Tmat: [m+1 x m+1] transition matrix between categories, where
        %     the last row/col is the start/end transitions
        %  mu: [m x dim] category means
        %  Sigma: [dim x dim x m] Covariance matrix
        %
        % Output
        %   myscore: [scalar] log P(O) across sequences
        %   scores: [nseg x 1] log P(O) each sequence
        %
        function [myscore,scores] = prob_observations(this,cell_data,cell_scales)
                    
            % process transitions
            logTmat = this.logTmat;    
            logStart = this.logStart;

            % for each sequence
            nseq = numel(cell_data);
            scores = zeros(nseq,1);
            mymu = this.mu;
            Sigma = this.Covs;
            mytheta = this.theta;
            parfor i=1:nseq

               D = cell_data{i};               
               invscales = 1./cell_scales{i};
               T = size(D,1);

               % pre-compute observation matrix
               mysd = sqrt((this.vsd.^2) + this.smooth_Sigma);
               ll = get_obs_matrix(D,invscales,mymu,mysd,mytheta);

               % forward-algorithm
               logY = ll(1,:)' + logStart; % base case
               for t=2:T % recursion
                  logY = take_step(t,logTmat,ll,logY);
               end

               % final marginalization
               scores(i) = logsumexp(logY(:));
               

            end            
            myscore = sum(scores);

        end
       
    end
    
end

% Pre-compute observation matrix
%
% Input
%
%   D: [n x dim] data points are rows
%   invscales : [n x 1] inverse scale data
%   mu: [m x dim] mean of each cat
%   Sigma: [dim x dim x m] cov of eachc at
%   theta: [m x 2] gamma parameters for each scale
%
% Output
%   ll: [n x m] log-likelihood for each datapoint (row) by each category
%       (col)
function ll = get_obs_matrix(D,invscales,mu,vsd,theta)

    [n,dim] = size(D);
    [m,dim2] = size(mu);
    assert(dim==dim2);
    
    sz = [m dim2];
    muvec = mu(:);
    sdvec = vsd(:);
    ll = zeros(n,m);
    for i=1:n
        dat = repmat(D(i,:),[m 1]);
        dat = dat(:)';
        llvec =  mvnormpdfln(dat,muvec',sdvec');
        llvec = reshape(llvec,sz);
        ll(i,:) = sum(llvec,2);
        ll(i,:) = ll(i,:) + vec(log( gampdf(invscales(i),theta(:,1),theta(:,2)) ))';
    end    
    
    %ll2 = slow_get_obs_matrix(D,invscales,mu,Sigma,theta);
    %assert(aeq(ll,ll2));
    
end

% Pre-compute observation matrix
%
% Input
%
%   D: [n x dim] data points are rows
%   invscales : [n x 1] inverse scale data
%   mu: [m x dim] mean of each cat
%   Sigma: [dim x dim x m] cov of eachc at
%   theta: [m x 2] gamma parameters for each scale
%
% Output
%   ll: [n x m] log-likelihood for each datapoint (row) by each category
%       (col)
function ll = slow_get_obs_matrix(D,invscales,mu,Sigma,theta)

    [n,dim] = size(D);
    [m,dim2] = size(mu);
    assert(dim==dim2);
    
    ll = zeros(n,m);
    for c=1:m
        mymu = mu(c,:);
        mySig = Sigma(:,:,c);
        mytheta = theta(c,:);
        ll(:,c) = mvnormpdfln(D',mymu',[],mySig);
        ll(:,c) = ll(:,c) + vec(log( gampdf(invscales(:)',mytheta(1),mytheta(2)) ));
    end
    
end

%
% Recursive step in forward-algorithm
%
% Input
%  t: time step index
%  logTmat: [m x m]
%  ll: [T x m] observation probs.
%  logY: [m x 1] is Y_i = P(O_0,...,O_t-1,S_t-1=i)
%
% Output
%  logf: [m x 1] is Y_i = P(O_0,...,O_t,S_t=i)
%
function logf = take_step(t,logTmat,ll,logY)
    
    logY = logY(:);
    N = size(logTmat,1);
    
    logf = zeros(N,1);
    for i=1:N        
         mr = ll(t,i) + logTmat(:,i) + logY;
         logf(i) = logsumexp(mr);
    end
end