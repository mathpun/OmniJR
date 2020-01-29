classdef Classifier < BetterHandle
    %CLASSIFIER Classify a dataset into a discrete
    % number of categories
    
    properties
        mixprob
        f_ll
    end
    
    properties (Dependent = true)
        nclass 
    end
    
    methods        
       
        % setup the classifier 
        %
        % compute_ll:
        %  function of two arguments, where the first is a data 
        %  matrix where rows are observations, and the second
        %  is a scalar indicating which class we should score
        %
        %  The output is a [n x 1] vector of the log-likelihood of each row
        %
        function this = Classifier(compute_ll,mixprob)            
            sum_mix = sum(mixprob);
            assert(aeq(sum_mix,1));
            this.mixprob = mixprob(:);
            this.f_ll = compute_ll;
        end
        
        function y = get.nclass(this)
           y = numel(this.mixprob); 
        end
        
        %
        % Compute posterior distribution of categories
        % 
        % Input
        %  data: [n x dim] row are datapoints
        %
        % Output
        %   lpost: [n x nclass] rows are proportional to the log-posterior probabilities
        function lpost = prop_posterior(this,data)
           n = size(data,1);          
           ll = zeros(n,this.nclass);
           lp = zeros(n,this.nclass);
           fll = this.f_ll;
           mp = this.mixprob;
           for c=1:this.nclass
               ll(:,c) = fll(data,c);
               lp(:,c) = log(mp(c));
           end
           lpost = ll + lp;           
        end
        
        %
        % Copute
        % log P(x) = log sum_c P(x|c)
        %
        % mll: [n x 1] marginal log-likelihood for each data point
        %
        function mll = marginal_like(this,data)
           lpost = this.prop_posterior(data);
           n = size(data,1);
           mll = zeros(n,1);
           for i=1:n
              mll(i) = logsumexp(lpost(i,:)'); 
           end           
        end
        
        %
        % Most likely class
        %
        % C: [n x 1] class for each datapoints
        %
        function C = classify(this,data)
           lpost = this.prop_posterior(data);
           n = size(data,1);
           C = zeros(n,1);
           for i=1:n
              C(i) = argmax(lpost(i,:));
           end            
        end
        
        %
        % Soft-Most likely classes
        % 
        % C: [n x k] k most likely classes for each datapoint
        % 
        function C = kclassify(this,data,k)
           lpost = this.prop_posterior(data);
           n = size(data,1);
           C = zeros(n,k);
           for i=1:n
              [~,indx] = sort(vec(lpost(i,:)),1,'descend');
              C(i,:) = indx(1:k);
           end            
        end
        
    end
    
end

