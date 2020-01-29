classdef GMM < BetterHandle
   % Gaussian mixture model of primitives with no sequential component.
   % 
   % This function no longer models the sequence length...
   % 
   properties (SetAccess = private)
       mu % [N x dim] mean vectors
       RawSigma % [dim x dim x N]
       mixprob
       theta
       vsd % [N x dim] standard deviation (diagonal of Rawsigma)
   end
   
   properties 
       smooth_Sigma = 0;
   end
   
   properties (Dependent = true)
      dim
      Covs
      nclass
   end
    
    methods
        
        %
        %  Object constructor.
        %
        %  mu: [m x dim] category means
        %  Sigma: [dim x dim x m] Covariance matrix
        %  mixprob: [m x 1] mixing probabilities
        %  cell_data: [n x 1 cell] set of stroke sequences
        %
        function this = GMM(mu,Sigma,mixprob,theta)           
           this.mu = mu;
           this.RawSigma = Sigma;
           this.mixprob = mixprob;
           this.theta = theta;         
            
           vsd = zeros(this.nclass,this.dim);
           for i=1:this.nclass
              dg = diag(this.RawSigma(:,:,i));
              vsd(i,:) = sqrt(dg);               
           end
           this.vsd = vsd;
           
        end 
        
        function C = get.Covs(this)
            E = eye(this.dim);
            E = E * this.smooth_Sigma;
            RE = repmat(E,[1 1 this.nclass]);
            C = this.RawSigma + RE;
        end
        
        function nclass = get.nclass(this)
           nclass = size(this.mu,1); 
        end
        
        function d = get.dim(this)
            d = size(this.mu,2);            
        end
        
        % Compute sum log P(O_i) across a set of observation
        % sequences in cell_data
        function [myscore,scores] = prob_observations(this,cell_data,cell_scales)
                       
           nseq = length(cell_data);
           scores = zeros(nseq,1);
           mu = this.mu;
           mixprob = this.mixprob(:)';
           theta = this.theta;
           %for i=1:nseq
           parfor i=1:nseq
              
              D = cell_data{i};
              invscales = 1./cell_scales{i};
              mysd = sqrt((this.vsd.^2) + this.smooth_Sigma);
              ll = get_obs_matrix(D,invscales,mu,mysd,theta);
              lp = log(mixprob);
              nobs = size(D,1);
              k = nobs + 1;
              lpost = ll + repmat(lp,[nobs 1]);
              
              margll = zeros(nobs,1);
              for o=1:nobs
                 margll(o) = logsumexp(lpost(o,:)');
              end
              
              scores(i) = sum(margll);              
           end
           
           myscore = sum(scores);
        end
        
    end
    
    
end

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