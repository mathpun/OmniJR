function C = complex_mix_classify(D,mu,Sigma,regcov,thetas)
%
% Classify a set of datapoints, where the control points
% are modeled as a Gaussian and the inverse scale is modeled
% as a Gamma distribution
%
% Input
%   D: [n x dim] data points are rows, where only the last column is the
%   inverse scale
%   mu: [m x dim] mean of each cat
%   Sigma: [dim x dim x m] cov of eachc at
%   thetas : [m x 2] scale distribution
%
% Output
%   C: [m x 1] category assignments
% 
    [n,dim] = size(D);
    [m,dim2] = size(mu);
    [m2,~] = size(thetas);
    assert(m==m2);
    assert(dim2+1==dim);
    
    % mixing probability should be uniform
    mixprob = ones(m,1);
    mixprob = mixprob ./ sum(mixprob);    
    
    % Add regularization
    newSigma = zeros(size(Sigma));
    for c=1:m
       newSigma(:,:,c) = Sigma(:,:,c) + eye(dim2)*regcov; 
    end   
 
    % do classification computation
    fll = @(data,c) primlike(data,c,mu,newSigma,thetas);
    fC = Classifier(fll,mixprob);
    C = fC.classify(D);
    
end